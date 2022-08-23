using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace UnityEngine.Rendering.Universal
{
    /// <summary>
    /// Settings required for performing a blit screen pass.
    /// </summary>
    [System.Serializable]
    public class BlitScreenRenderSettings
    {
        public RenderPassEvent renderPassEvent = RenderPassEvent.AfterRenderingOpaques;

        public Material blitMaterial = null;
        public int blitMaterialPassIndex = -1;
    }
}
