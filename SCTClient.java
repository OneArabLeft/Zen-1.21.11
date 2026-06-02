package com.sct.mixin;

import com.sct.SCTClient;
import net.minecraft.client.render.WorldRenderer;
import net.minecraft.entity.Entity;
import org.spongepowered.asm.mixin.Mixin;
import org.spongepowered.asm.mixin.injection.At;
import org.spongepowered.asm.mixin.injection.Inject;
import org.spongepowered.asm.mixin.injection.callback.CallbackInfoReturnable;

@Mixin(WorldRenderer.class)
public class WorldRendererMixin {

    @Inject(method = "canDrawEntityOutline", at = @At("HEAD"), cancellable = true)
    private void sct$canDrawEntityOutline(Entity entity, CallbackInfoReturnable<Boolean> cir) {
        if (SCTClient.highlighter != null &&
            (SCTClient.highlighter.isBoss(entity) || SCTClient.highlighter.isPlayer(entity))) {
            cir.setReturnValue(true);
        }
    }
}
