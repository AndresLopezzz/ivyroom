import { QueryCtx, MutationCtx } from "./_generated/server";
import { Doc, Id } from "./_generated/dataModel";

/** El usuario de la sesion, o error si no hay token valido. */
export async function currentUser(ctx: QueryCtx): Promise<Doc<"users">> {
  const identity = await ctx.auth.getUserIdentity();
  if (!identity) throw new Error("No has iniciado sesión");
  const user = await ctx.db
    .query("users")
    .withIndex("by_token", (q) =>
      q.eq("tokenIdentifier", identity.tokenIdentifier),
    )
    .unique();
  if (!user) throw new Error("Usuario no registrado");
  return user;
}

export async function ownCloset(
  ctx: QueryCtx,
  userId: Id<"users">,
): Promise<Doc<"closets"> | null> {
  return ctx.db
    .query("closets")
    .withIndex("by_owner", (q) => q.eq("ownerId", userId))
    .unique();
}

/**
 * Puede ver el armario: es el dueno o su correo esta invitado.
 *
 * Es la unica puerta de lectura de datos ajenos; todas las consultas del
 * visor pasan por aqui.
 */
export async function assertCanView(
  ctx: QueryCtx,
  user: Doc<"users">,
  closetId: Id<"closets">,
): Promise<Doc<"closets">> {
  const closet = await ctx.db.get(closetId);
  if (!closet) throw new Error("Ese armario no existe");
  if (closet.ownerId === user._id) return closet;
  const invite = await ctx.db
    .query("invites")
    .withIndex("by_closet_email", (q) =>
      q.eq("closetId", closetId).eq("email", user.email),
    )
    .unique();
  if (!invite) throw new Error("No tienes acceso a este armario");
  return closet;
}

export async function deleteFiles(
  ctx: MutationCtx,
  ids: (Id<"_storage"> | undefined)[],
) {
  for (const id of ids) {
    if (!id) continue;
    try {
      await ctx.storage.delete(id);
    } catch {
      // Ya borrado: no importa.
    }
  }
}
