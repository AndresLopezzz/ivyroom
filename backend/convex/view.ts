import { query } from "./_generated/server";
import { v } from "convex/values";
import { assertCanView, currentUser } from "./lib";

/**
 * Un armario completo para el modo visor: prendas con las URLs de sus
 * imagenes, outfits guardados y looks.
 *
 * Solo lectura. Lo puede pedir el dueno o un correo invitado.
 */
export const closet = query({
  args: { closetId: v.id("closets") },
  handler: async (ctx, { closetId }) => {
    const user = await currentUser(ctx);
    const closet = await assertCanView(ctx, user, closetId);
    const owner = await ctx.db.get(closet.ownerId);

    const garments = [];
    for (const g of await ctx.db
      .query("garments")
      .withIndex("by_closet_local", (q) => q.eq("closetId", closetId))
      .collect()) {
      garments.push({
        localId: g.localId,
        data: g.data,
        imageUrl: await ctx.storage.getUrl(g.imageId),
        thumbUrl: await ctx.storage.getUrl(g.thumbId),
      });
    }

    const outfits = (
      await ctx.db
        .query("outfits")
        .withIndex("by_closet_local", (q) => q.eq("closetId", closetId))
        .collect()
    ).map((o) => ({ localId: o.localId, data: o.data }));

    const looks = [];
    for (const l of await ctx.db
      .query("looks")
      .withIndex("by_closet_local", (q) => q.eq("closetId", closetId))
      .collect()) {
      looks.push({
        localId: l.localId,
        data: l.data,
        photoUrl: l.photoId ? await ctx.storage.getUrl(l.photoId) : null,
      });
    }

    return {
      ownerName: owner?.name ?? owner?.email ?? "",
      lastSyncAt: closet.lastSyncAt ?? null,
      garments,
      outfits,
      looks,
    };
  },
});
