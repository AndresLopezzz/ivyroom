import { httpRouter } from "convex/server";
import { httpAction } from "./_generated/server";
import {
  createRemoteJWKSet,
  importJWK,
  jwtVerify,
  SignJWT,
  type JWTPayload,
} from "jose";

// Sesion propia de la app.
//
// El ID token de Google dura una hora, y renovarlo en Android ensena el aviso
// "Accediendo como..." cada vez. Asi que Google se usa solo para entrar: se
// cambia aqui por un token nuestro de 30 dias, que la app renueva sin que el
// usuario vea nada. Convex lo valida con la clave publica de /.well-known.

// Client ID *web* de Google Cloud: `npx convex env set GOOGLE_CLIENT_ID ...`
const GOOGLE_CLIENT_ID = process.env.GOOGLE_CLIENT_ID!;
export const SESSION_AUDIENCE = "ivyroom";
const SESSION_DAYS = 30;

const googleKeys = createRemoteJWKSet(
  new URL("https://www.googleapis.com/oauth2/v3/certs"),
);

function issuer(): string {
  // CONVEX_SITE_URL lo pone Convex: es la URL publica de las acciones HTTP.
  return process.env.CONVEX_SITE_URL!;
}

async function sign(claims: JWTPayload & { sub: string }) {
  const jwk = JSON.parse(process.env.JWT_PRIVATE_KEY!);
  const key = await importJWK(jwk, "RS256");
  return new SignJWT({
    email: claims.email,
    name: claims.name,
    picture: claims.picture,
  })
    .setProtectedHeader({ alg: "RS256", kid: jwk.kid })
    .setSubject(claims.sub)
    .setIssuer(issuer())
    .setAudience(SESSION_AUDIENCE)
    .setIssuedAt()
    .setExpirationTime(`${SESSION_DAYS}d`)
    .sign(key);
}

function json(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json" },
  });
}

const http = httpRouter();

http.route({
  path: "/.well-known/jwks.json",
  method: "GET",
  handler: httpAction(async () => {
    return new Response(process.env.JWKS!, {
      headers: {
        "Content-Type": "application/json",
        "Cache-Control": "public, max-age=3600",
      },
    });
  }),
});

/** Google ID token -> sesion de 30 dias. */
http.route({
  path: "/auth/google",
  method: "POST",
  handler: httpAction(async (_ctx, req) => {
    let idToken: string;
    try {
      idToken = (await req.json()).idToken;
    } catch {
      return json({ error: "Petición inválida" }, 400);
    }
    try {
      const { payload } = await jwtVerify(idToken, googleKeys, {
        issuer: ["https://accounts.google.com", "accounts.google.com"],
        audience: GOOGLE_CLIENT_ID,
      });
      if (!payload.sub || !payload.email) {
        return json({ error: "La cuenta de Google no tiene correo" }, 400);
      }
      return json({
        token: await sign({ ...payload, sub: payload.sub }),
      });
    } catch {
      return json({ error: "El token de Google no es válido" }, 401);
    }
  }),
});

/**
 * Sesion vigente -> sesion nueva de 30 dias.
 *
 * Mientras la app se abra al menos una vez al mes, no vuelve a pedir Google
 * nunca.
 */
http.route({
  path: "/auth/refresh",
  method: "POST",
  handler: httpAction(async (_ctx, req) => {
    const auth = req.headers.get("Authorization") ?? "";
    const token = auth.replace(/^Bearer\s+/i, "");
    try {
      const jwks = JSON.parse(process.env.JWKS!);
      const key = await importJWK(jwks.keys[0], "RS256");
      const { payload } = await jwtVerify(token, key, {
        issuer: issuer(),
        audience: SESSION_AUDIENCE,
      });
      return json({ token: await sign({ ...payload, sub: payload.sub! }) });
    } catch {
      return json({ error: "La sesión caducó" }, 401);
    }
  }),
});

export default http;
