import { mutation, query } from "./_generated/server";
import { v } from "convex/values";
import { currentUser, ownCloset } from "./lib";

/** Correos invitados a ver mi armario. */
export const list = query({
  args: {},
  handler: async (ctx) => {
    const user = await currentUser(ctx);
    const closet = await ownCloset(ctx, user._id);
    if (!closet) return [];
    const rows = await ctx.db
      .query("invites")
      .withIndex("by_closet", (q) => q.eq("closetId", closet._id))
      .collect();
    return rows.map((r) => ({ id: r._id, email: r.email }));
  },
});

export const add = mutation({
  args: { email: v.string() },
  handler: async (ctx, { email }) => {
    const user = await currentUser(ctx);
    const closet = await ownCloset(ctx, user._id);
    if (!closet) throw new Error("No tienes armario todavía");
    const clean = email.trim().toLowerCase();
    if (!/^[^@\s]+@[^@\s]+\.[^@\s]+$/.test(clean)) {
      throw new Error("Ese correo no parece válido");
    }
    if (clean === user.email) throw new Error("Ese es tu propio correo");
    const existing = await ctx.db
      .query("invites")
      .withIndex("by_closet_email", (q) =>
        q.eq("closetId", closet._id).eq("email", clean),
      )
      .unique();
    if (existing) return existing._id;
    return ctx.db.insert("invites", { closetId: closet._id, email: clean });
  },
});

export const remove = mutation({
  args: { id: v.id("invites") },
  handler: async (ctx, { id }) => {
    const user = await currentUser(ctx);
    const closet = await ownCloset(ctx, user._id);
    const invite = await ctx.db.get(id);
    if (!closet || !invite || invite.closetId !== closet._id) return;
    await ctx.db.delete(id);
  },
});
