import { mutation } from "./_generated/server";
import { ownCloset } from "./lib";

/**
 * Abre sesion: registra al usuario si es nuevo, le crea su armario y
 * devuelve los armarios que otros han compartido con el.
 *
 * Es una mutacion y no una consulta porque la primera vez escribe.
 */
export const session = mutation({
  args: {},
  handler: async (ctx) => {
    const identity = await ctx.auth.getUserIdentity();
    if (!identity) throw new Error("No has iniciado sesión");
    const email = (identity.email ?? "").toLowerCase();
    if (!email) throw new Error("La cuenta de Google no tiene correo");

    let user = await ctx.db
      .query("users")
      .withIndex("by_token", (q) =>
        q.eq("tokenIdentifier", identity.tokenIdentifier),
      )
      .unique();
    const profile = {
      email,
      name: identity.name ?? undefined,
      picture: identity.pictureUrl ?? undefined,
    };
    if (!user) {
      // El mismo Google con otro emisor (sesion propia vs token de Google
      // directo) tiene otro tokenIdentifier. El correo es lo que identifica
      // a la persona; se adopta la fila existente.
      user = await ctx.db
        .query("users")
        .withIndex("by_email", (q) => q.eq("email", email))
        .first();
      if (user) {
        await ctx.db.patch(user._id, {
          tokenIdentifier: identity.tokenIdentifier,
        });
      }
    }
    if (!user) {
      const id = await ctx.db.insert("users", {
        tokenIdentifier: identity.tokenIdentifier,
        ...profile,
      });
      user = (await ctx.db.get(id))!;
    } else {
      await ctx.db.patch(user._id, profile);
    }

    let closet = await ownCloset(ctx, user._id);
    if (!closet) {
      const id = await ctx.db.insert("closets", { ownerId: user._id });
      closet = (await ctx.db.get(id))!;
    }

    const invites = await ctx.db
      .query("invites")
      .withIndex("by_email", (q) => q.eq("email", email))
      .collect();
    const shared = [];
    for (const inv of invites) {
      const c = await ctx.db.get(inv.closetId);
      if (!c) continue;
      const owner = await ctx.db.get(c.ownerId);
      shared.push({
        closetId: c._id,
        ownerName: owner?.name ?? owner?.email ?? "Alguien",
        ownerEmail: owner?.email ?? "",
        ownerPicture: owner?.picture ?? null,
      });
    }

    return {
      email,
      name: profile.name ?? null,
      picture: profile.picture ?? null,
      closetId: closet._id,
      lastSyncAt: closet.lastSyncAt ?? null,
      shared,
    };
  },
});
