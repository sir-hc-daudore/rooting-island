namespace UnityEngine.Rendering.Universal
{
    /// <summary>
    /// Renderer Feature class for BlitRenderPass.
    /// 
    /// Used for managing within a Render Pipeline configuration.
    /// </summary>
    public class BlitScreenRenderFeature : ScriptableRendererFeature
    {
        // Initial configuration
        //[SerializeField]
        public BlitScreenRenderSettings settings = new BlitScreenRenderSettings();
        BlitScreenRenderPass blitPass;

        public override void Create()
        {
            blitPass = new BlitScreenRenderPass(name);
        }

        public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
        {
            if(settings.blitMaterial == null)
            {
                // Blit can't be executed
                Debug.LogWarningFormat("{0}: Missing Blit Material, pass won't execute.", GetType().Name);
                return;
            }

            // Set up pass
            blitPass.renderPassEvent = settings.renderPassEvent;
            blitPass.settings = settings;

            // Add render pass to queue
            renderer.EnqueuePass(blitPass);
        }
    }
}
