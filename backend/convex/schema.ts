import { defineSchema, defineTable } from "convex/server";
import { v } from "convex/values";

// El movil es la fuente de verdad: su base local manda y aqui se guarda una
// copia que sube la app. Por eso las filas llevan `localId` (el id de la base
// del movil) y los datos van como objeto libre: el esquema de la app puede
// crecer sin migrar nada aqui.
export default defineSchema({
  users: defineTable({
    // `tokenIdentifier` = issuer + sub de Google: estable aunque cambie el
    // correo.
    tokenIdentifier: v.string(),
    email: v.string(),
    name: v.optional(v.string()),
    picture: v.optional(v.string()),
  })
    .index("by_token", ["tokenIdentifier"])
    .index("by_email", ["email"]),

  // Un armario por dueno. Existe aparte del usuario para que invitar y
  // compartir apunten a "un armario" y no a "una persona".
  closets: defineTable({
    ownerId: v.id("users"),
    lastSyncAt: v.optional(v.number()),
  }).index("by_owner", ["ownerId"]),

  // Correos de Google que pueden ver un armario, en minusculas.
  invites: defineTable({
    closetId: v.id("closets"),
    email: v.string(),
  })
    .index("by_closet", ["closetId"])
    .index("by_email", ["email"])
    .index("by_closet_email", ["closetId", "email"]),

  garments: defineTable({
    closetId: v.id("closets"),
    localId: v.number(),
    data: v.any(),
    // Ruta relativa en el movil. Si cambia, la imagen cambio y hay que
    // volver a subirla; si no, se reutiliza la ya subida.
    imageKey: v.string(),
    imageId: v.id("_storage"),
    thumbId: v.id("_storage"),
  }).index("by_closet_local", ["closetId", "localId"]),

  outfits: defineTable({
    closetId: v.id("closets"),
    localId: v.number(),
    data: v.any(),
  }).index("by_closet_local", ["closetId", "localId"]),

  // Lo planificado y lo puesto, con la foto del look si la hay.
  looks: defineTable({
    closetId: v.id("closets"),
    localId: v.number(),
    data: v.any(),
    photoKey: v.optional(v.string()),
    photoId: v.optional(v.id("_storage")),
  }).index("by_closet_local", ["closetId", "localId"]),
});
