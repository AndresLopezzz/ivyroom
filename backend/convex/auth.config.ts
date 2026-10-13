// La app entra con Google una sola vez y cambia el ID token de Google por una
// sesion propia de 30 dias (ver http.ts). Esa sesion es la que llega aqui en
// cada llamada, firmada con nuestra clave y validada con la publica que se
// sirve en /.well-known/jwks.json.
//
// Se acepta tambien el ID token de Google directo, con el Client ID *web*
// como audiencia: sin `applicationID`, cualquier token de Google emitido
// para otra app serviria aqui.
export default {
  providers: [
    {
      type: "customJwt",
      issuer: process.env.CONVEX_SITE_URL,
      jwks: process.env.CONVEX_SITE_URL + "/.well-known/jwks.json",
      algorithm: "RS256",
      applicationID: "ivyroom",
    },
    {
      type: "customJwt",
      issuer: "https://accounts.google.com",
      jwks: "https://www.googleapis.com/oauth2/v3/certs",
      algorithm: "RS256",
      applicationID: process.env.GOOGLE_CLIENT_ID,
    },
  ],
};
