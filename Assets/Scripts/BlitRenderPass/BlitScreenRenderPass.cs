using UnityEngine;
using UnityEngine.Rendering.Universal;

namespace UnityEngine.Rendering.Universal
{
    public class BlitScreenRenderPass : ScriptableRenderPass
    {
        internal BlitScreenRenderSettings settings;

        RenderTargetIdentifier source;
        RenderTargetIdentifier destination;

        string profilerTag;

        public BlitScreenRenderPass(string tag)
        {
            this.profilerTag = tag;
        }

        public override void OnCameraSetup(CommandBuffer cmd, ref RenderingData renderingData)
        {
            RenderTextureDescriptor blitTargetDescriptor = renderingData.cameraData.cameraTargetDescriptor;
            blitTargetDescriptor.depthBufferBits = 0;

            var renderer = renderingData.cameraData.renderer;

            source = renderer.cameraColorTarget;

            destination = renderer.cameraColorTarget;
        }

        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            // Get a command buffer for performing blit
            CommandBuffer cmd = CommandBufferPool.Get(profilerTag);

            // Add the actual blit to the command buffer
            Blit(cmd, source, destination, settings.blitMaterial, settings.blitMaterialPassIndex);

            // Execute and clear
            context.ExecuteCommandBuffer(cmd);
            CommandBufferPool.Release(cmd);
        }

        public override void FrameCleanup(CommandBuffer cmd)
        {
            base.FrameCleanup(cmd);
        }
    }
}
