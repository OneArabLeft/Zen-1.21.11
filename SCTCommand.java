package com.sct.mixin;

import com.sct.SCTClient;
import net.minecraft.client.render.entity.EntityRenderer;
import net.minecraft.entity.Entity;
import org.spongepowered.asm.mixin.Mixin;
import org.spongepowered.asm.mixin.injection.At;
import org.spongepowered.asm.mixin.injection.Inject;
import org.spongepowered.asm.mixin.injection.callback.CallbackInfoReturnable;

@Mixin(EntityRenderer.class)
public abstract class EntityRendererMixin<T extends Entity> {

    /**
     * Override the outline colour for entities we want to glow.
     * Boss → slayer-type colour (red/purple/etc).
     * Carry player → yellow.
     */
    @Inject(method = "getTeamColor", at = @At("HEAD"), cancellable = true)
    private void sct$glowColor(T entity, CallbackInfoReturnable<Integer> cir) {
        if (SCTClient.highlighter == null) return;
        if (SCTClient.highlighter.isBoss(entity) || SCTClient.highlighter.isPlayer(entity)) {
            cir.setReturnValue(SCTClient.highlighter.glowColor(entity));
        }
    }
}
