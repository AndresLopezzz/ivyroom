import { mutation, query } from "./_generated/server";
import { v } from "convex/values";
import { currentUser, deleteFiles, ownCloset } from "./lib";

/**
 * Que imagenes tiene ya el servidor, por id local.
 *
 * La app lo compara con lo suyo y solo sube lo que cambio: con un armario
 * grande, subirlo todo en cada sincronizacion se comeria el giga gratuito de
 * transferencia en pocos dias.
 */
export const manifest = query({
  args: {},
  handler: async (ctx) => {
    const user = await currentUser(ctx);
    const closet = await ownCloset(ctx, user._id);
    if (!closet) return { garments: {}, looks: {} };
    const garments: Record<string, string> = {};
    for (const g of await ctx.db
      .query("garments")
      .withIndex("by_closet_local", (q) => q.eq("closetId", closet._id))
      .collect()) {
      garments[String(g.localId)] = g.imageKey;
    }
    const looks: Record<string, string> = {};
    for (const l of await ctx.db
      .query("looks")
      .withIndex("by_closet_local", (q) => q.eq("closetId", closet._id))
      .collect()) {
      if (l.photoKey) looks[String(l.localId)] = l.photoKey;
    }
    return { garments, looks };
  },
});

/** URL de un solo uso para subir un fichero. */
export const generateUploadUrl = mutation({
  args: {},
  handler: async (ctx) => {
    await currentUser(ctx);
    return ctx.storage.generateUploadUrl();
  },
});

const garmentArg = v.object({
  localId: v.number(),
  data: v.any(),
  imageKey: v.string(),
  // Solo si la imagen cambio y se acaba de subir.
  imageId: v.optional(v.id("_storage")),
  thumbId: v.optional(v.id("_storage")),
});

const lookArg = v.object({
  localId: v.number(),
  data: v.any(),
  photoKey: v.optional(v.string()),
  photoId: v.optional(v.id("_storage")),
});

const outfitArg = v.object({ localId: v.number(), data: v.any() });

/**
 * Deja el armario del servidor igual que el del movil.
 *
 * Recibe la foto completa de los metadatos (pocos KB por prenda) y borra lo
 * que ya no esta, ficheros incluidos. Es idempotente: si una subida se corta
 * a medias, la siguiente sincronizacion lo deja bien.
 */
export const push = mutation({
  args: {
    garments: v.array(garmentArg),
    outfits: v.array(outfitArg),
    looks: v.array(lookArg),
  },
  handler: async (ctx, args) => {
    const user = await currentUser(ctx);
    const closet = await ownCloset(ctx, user._id);
    if (!closet) throw new Error("No tienes armario todavía");
    const closetId = closet._id;

    // ---- prendas
    const existingGarments = new Map(
      (
        await ctx.db
          .query("garments")
          .withIndex("by_closet_local", (q) => q.eq("closetId", closetId))
          .collect()
      ).map((g) => [g.localId, g]),
    );
    for (const g of args.garments) {
      const old = existingGarments.get(g.localId);
      existingGarments.delete(g.localId);
      if (old) {
        const patch: Record<string, unknown> = { data: g.data };
        if (g.imageId && g.thumbId) {
          patch.imageId = g.imageId;
          patch.thumbId = g.thumbId;
          patch.imageKey = g.imageKey;
          await deleteFiles(ctx, [old.imageId, old.thumbId]);
        }
        await ctx.db.patch(old._id, patch);
      } else if (g.imageId && g.thumbId) {
        await ctx.db.insert("garments", {
          closetId,
          localId: g.localId,
          data: g.data,
          imageKey: g.imageKey,
          imageId: g.imageId,
          thumbId: g.thumbId,
        });
      }
      // Nueva y sin imagen subida: se ignora hasta la proxima vez.
    }
    for (const gone of existingGarments.values()) {
      await deleteFiles(ctx, [gone.imageId, gone.thumbId]);
      await ctx.db.delete(gone._id);
    }

    // ---- outfits
    const existingOutfits = new Map(
      (
        await ctx.db
          .query("outfits")
          .withIndex("by_closet_local", (q) => q.eq("closetId", closetId))
          .collect()
      ).map((o) => [o.localId, o]),
    );
    for (const o of args.outfits) {
      const old = existingOutfits.get(o.localId);
      existingOutfits.delete(o.localId);
      if (old) await ctx.db.patch(old._id, { data: o.data });
      else await ctx.db.insert("outfits", { closetId, ...o });
    }
    for (const gone of existingOutfits.values()) await ctx.db.delete(gone._id);

    // ---- looks
    const existingLooks = new Map(
      (
        await ctx.db
          .query("looks")
          .withIndex("by_closet_local", (q) => q.eq("closetId", closetId))
          .collect()
      ).map((l) => [l.localId, l]),
    );
    for (const l of args.looks) {
      const old = existingLooks.get(l.localId);
      existingLooks.delete(l.localId);
      const photo =
        l.photoKey === undefined
          ? { photoKey: undefined, photoId: undefined }
          : l.photoId
            ? { photoKey: l.photoKey, photoId: l.photoId }
            : { photoKey: old?.photoKey, photoId: old?.photoId };
      if (old) {
        if (old.photoId && old.photoId !== photo.photoId) {
          await deleteFiles(ctx, [old.photoId]);
        }
        await ctx.db.patch(old._id, { data: l.data, ...photo });
      } else {
        await ctx.db.insert("looks", {
          closetId,
          localId: l.localId,
          data: l.data,
          ...photo,
        });
      }
    }
    for (const gone of existingLooks.values()) {
      await deleteFiles(ctx, [gone.photoId]);
      await ctx.db.delete(gone._id);
    }

    await ctx.db.patch(closetId, { lastSyncAt: Date.now() });
    return null;
  },
});
