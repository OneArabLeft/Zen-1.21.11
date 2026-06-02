package com.sct.hud;

import com.sct.SCTClient;
import com.sct.config.SCTConfig;
import com.sct.feature.CarrySession;
import com.sct.feature.SlayerTimer;
import com.sct.feature.SlayerType;
import net.minecraft.client.MinecraftClient;
import net.minecraft.client.gui.DrawContext;

/**
 * Zen-style HUD with:
 *  - Pulsing boss spawn banner (top centre)
 *  - Kill-recorded flash (centre)
 *  - Carry status widget (draggable, bottom-right by default)
 *    showing player, type, kills/paid, coins, timer, progress bar
 */
public class CarryHud {

    // ── Spawn alert ───────────────────────────────────────────────
    private SlayerType alertType;
    private long       alertStart;
    private static final long ALERT_MS = 5_500;

    // ── Kill flash ────────────────────────────────────────────────
    private CarrySession killSession;
    private long         killStart;
    private static final long KILL_MS  = 3_200;

    // ── Drag ─────────────────────────────────────────────────────
    private boolean dragging;
    private int     dragOffX, dragOffY;

    public void triggerSpawnAlert(SlayerType t) {
        alertType = t; alertStart = System.currentTimeMillis();
    }
    public void triggerKillFlash(CarrySession s) {
        killSession = s; killStart = System.currentTimeMillis();
    }

    // ── Master render ─────────────────────────────────────────────

    public void render(DrawContext ctx, MinecraftClient mc) {
        if (!SCTConfig.carryEnabled || mc.player == null) return;
        renderBossAlert(ctx, mc);
        renderKillFlash(ctx, mc);
        if (SCTConfig.hudEnabled) renderWidget(ctx, mc);
    }

    // ─────────────────────────────────────────────────────────────
    //  Boss spawn alert banner
    // ─────────────────────────────────────────────────────────────

    private void renderBossAlert(DrawContext ctx, MinecraftClient mc) {
        if (alertType == null || !SCTConfig.bossSpawnAlert) return;
        long el = System.currentTimeMillis() - alertStart;
        if (el > ALERT_MS) { alertType = null; return; }

        float alpha = el < 350    ? el / 350f
                    : el > ALERT_MS - 1000 ? 1f - (el - (ALERT_MS - 1000)) / 1000f
                    : 1f;
        int a   = (int)(alpha * 255);
        int W   = mc.getWindow().getScaledWidth();
        int bw  = 290, bh = 50, bx = (W - bw) / 2, by = 10;

        int tc = alertType.color;
        int tr = (tc>>16)&0xFF, tg = (tc>>8)&0xFF, tb = tc&0xFF;

        // Backdrop
        ctx.fill(bx,     by,     bx+bw,   by+bh,   argb((int)(a*.72f), 0, 0, 0));
        // Coloured left bar
        ctx.fill(bx,     by,     bx+4,    by+bh,   argb(a, tr, tg, tb));
        // Top edge glow
        ctx.fill(bx+4,   by,     bx+bw,   by+1,    argb((int)(a*.55f), tr, tg, tb));
        // Bottom edge
        ctx.fill(bx,     by+bh-1, bx+bw, by+bh,   argb((int)(a*.3f), tr, tg, tb));

        // Pulsing title
        String title = "⚠  BOSS SPAWNED  ⚠";
        String sub   = alertType.displayName;
        int tw = mc.textRenderer.getWidth(title), sw = mc.textRenderer.getWidth(sub);
        int pCol = pulseColor(a, el, 200, tr, tg, tb);

        ctx.drawText(mc.textRenderer, title, (W-tw)/2, by+10, pCol, true);
        ctx.drawText(mc.textRenderer, sub,   (W-sw)/2, by+28, argb(a, 255, 255, 255), false);
    }

    // ─────────────────────────────────────────────────────────────
    //  Kill recorded flash
    // ─────────────────────────────────────────────────────────────

    private void renderKillFlash(DrawContext ctx, MinecraftClient mc) {
        if (killSession == null) return;
        long el = System.currentTimeMillis() - killStart;
        if (el > KILL_MS) { killSession = null; return; }

        float alpha = el > KILL_MS - 600 ? 1f - (el - (KILL_MS - 600)) / 600f : 1f;
        int a = (int)(alpha * 255);
        int W = mc.getWindow().getScaledWidth();
        int H = mc.getWindow().getScaledHeight();

        String coins = killSession.getCoinsEach() > 0
            ? "  §6+" + SlayerType.formatCoins(killSession.getCoinsEach()) : "";
        String line  = "§a✔ §fKill recorded  §e" + killSession.getPlayer()
            + "  §a" + killSession.getKilled() + "§7/§c" + killSession.getPaid() + coins;
        int tw = mc.textRenderer.getWidth(line);
        int tx = (W - tw) / 2, ty = H / 2 + 38;

        ctx.fill(tx-6, ty-3, tx+tw+6, ty+12, argb((int)(a*.5f), 0, 0, 0));
        ctx.drawText(mc.textRenderer, line, tx, ty, argb(a, 255, 255, 255), true);
    }

    // ─────────────────────────────────────────────────────────────
    //  Carry status widget
    // ─────────────────────────────────────────────────────────────

    private void renderWidget(DrawContext ctx, MinecraftClient mc) {
        CarrySession active = SCTClient.carries.getActive();
        if (active == null) return;

        int W = mc.getWindow().getScaledWidth();
        int H = mc.getWindow().getScaledHeight();

        boolean hasCoins  = active.getCoinsEach() > 0;
        boolean hasTimer  = SCTClient.timer.bossIsUp() || SCTClient.timer.lastKillMs() > 0;

        int ww = 204;
        int wh = 46 + (hasCoins ? 11 : 0) + (hasTimer ? 11 : 0);

        int wx = SCTConfig.hudX < 0 ? W - ww - 8 : Math.max(0, Math.min(SCTConfig.hudX, W - ww));
        int wy = SCTConfig.hudY < 0 ? H - wh - 8 : Math.max(0, Math.min(SCTConfig.hudY, H - wh));

        int tc = active.getType().color;
        int tr = (tc>>16)&0xFF, tg = (tc>>8)&0xFF, tb_ = tc&0xFF;

        // Shadow
        ctx.fill(wx-1, wy-1, wx+ww+1, wy+wh+1, 0x66000000);
        // Background
        ctx.fill(wx,   wy,   wx+ww,   wy+wh,   0xEE0D0D0D);
        // Top colour stripe
        ctx.fill(wx,   wy,   wx+ww,   wy+2,    argb(255, tr, tg, tb_));
        // Subtle side border
        ctx.fill(wx,   wy+2, wx+1,    wy+wh,   argb(100, tr, tg, tb_));

        int tx = wx + 7, ty = wy + 5;

        // Player name
        ctx.drawText(mc.textRenderer, "§fCarrying: §e" + active.getPlayer(), tx, ty, 0xFFFFFF, false);
        ty += 11;

        // Slayer type (coloured)
        ctx.drawText(mc.textRenderer, "§7" + active.getType().displayName, tx, ty,
                0xFF000000 | tc, false);
        ty += 11;

        // Kills / Paid
        ctx.drawText(mc.textRenderer,
            "§aKills: §f" + active.getKilled() + " §7/ §c" + active.getPaid(),
            tx, ty, 0xFFFFFF, false);
        ty += 11;

        // Coins earned / owed
        if (hasCoins) {
            ctx.drawText(mc.textRenderer,
                "§6" + SlayerType.formatCoins(active.coinsEarned())
                + " §7/ §6" + SlayerType.formatCoins(active.totalOwed()),
                tx, ty, 0xFFFFFF, false);
            ty += 11;
        }

        // Slayer timer
        if (hasTimer) {
            String timerStr;
            long alive = SCTClient.timer.bossAliveMs();
            long last  = SCTClient.timer.lastKillMs();
            if (alive >= 0)
                timerStr = "§cBoss: §f" + SlayerTimer.formatMs(alive);
            else
                timerStr = "§7Last: §f" + SlayerTimer.formatMs(last)
                    + (SCTClient.timer.averageKillMs() > 0
                        ? " §7avg §f" + SlayerTimer.formatMs(SCTClient.timer.averageKillMs())
                        : "");
            ctx.drawText(mc.textRenderer, timerStr, tx, ty, 0xFFFFFF, false);
            ty += 11;
        }

        // Progress bar
        int pbx = wx + 4, pby = wy + wh - 7, pbw = ww - 8;
        ctx.fill(pbx, pby, pbx+pbw, pby+4, 0xFF222222);
        int fc = active.isDone() ? 0xFF00FF55 : 0xFF009FFF;
        ctx.fill(pbx, pby, pbx + (int)(pbw * active.progress()), pby+4, fc);
        // Percent label
        String pct = (int)(active.progress() * 100) + "%";
        ctx.drawText(mc.textRenderer, "§7" + pct, pbx + pbw + 3, pby - 1, 0xAAAAAA, false);

        // Boss-up pulsing dot (top-right corner of widget)
        if (active.isBossUp()) {
            long ms = System.currentTimeMillis() - active.getBossUpTime();
            int pulse = (int)(140 + 115 * Math.sin(ms / 280.0 * Math.PI));
            ctx.fill(wx+ww-11, wy+4, wx+ww-5, wy+10, argb(255, pulse, 0, 0));
        }

        // Session count badge (if more than 1)
        int total = SCTClient.carries.all().size();
        if (total > 1) {
            String badge = "+" + (total - 1) + " more";
            ctx.drawText(mc.textRenderer, "§7" + badge, wx+ww - mc.textRenderer.getWidth(badge) - 4,
                    wy + wh - 16, 0x777777, false);
        }
    }

    // ── Drag support ─────────────────────────────────────────────

    public boolean onMousePress(double mx, double my, MinecraftClient mc) {
        if (!SCTConfig.hudEnabled) return false;
        CarrySession active = SCTClient.carries.getActive();
        if (active == null) return false;
        int W = mc.getWindow().getScaledWidth(), H = mc.getWindow().getScaledHeight();
        boolean hasCoins = active.getCoinsEach() > 0;
        boolean hasTimer = SCTClient.timer.bossIsUp() || SCTClient.timer.lastKillMs() > 0;
        int ww = 204, wh = 46 + (hasCoins ? 11 : 0) + (hasTimer ? 11 : 0);
        int wx = SCTConfig.hudX < 0 ? W - ww - 8 : SCTConfig.hudX;
        int wy = SCTConfig.hudY < 0 ? H - wh - 8 : SCTConfig.hudY;
        if (mx >= wx && mx <= wx+ww && my >= wy && my <= wy+wh) {
            dragging = true; dragOffX = (int)mx - wx; dragOffY = (int)my - wy;
            return true;
        }
        return false;
    }

    public void onMouseDrag(double mx, double my) {
        if (!dragging) return;
        SCTConfig.hudX = (int)mx - dragOffX;
        SCTConfig.hudY = (int)my - dragOffY;
    }

    public void onMouseRelease() {
        if (dragging) { dragging = false; SCTConfig.save(); }
    }

    // ── Colour helpers ────────────────────────────────────────────

    private static int argb(int a, int r, int g, int b) {
        return ((a&0xFF)<<24)|((r&0xFF)<<16)|((g&0xFF)<<8)|(b&0xFF);
    }

    /** Returns a colour that pulses between the given RGB and white at the given period. */
    private static int pulseColor(int alpha, long elapsed, int periodMs, int r, int g, int b) {
        double t = 0.5 + 0.5 * Math.sin((elapsed / (double)periodMs) * Math.PI);
        int pr = (int)(r + (255 - r) * t);
        int pg = (int)(g + (255 - g) * t);
        int pb = (int)(b + (255 - b) * t);
        return argb(alpha, pr, pg, pb);
    }
}
