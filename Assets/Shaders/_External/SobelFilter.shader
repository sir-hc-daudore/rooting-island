Shader "Unlit/SobelFilter"
{
	Properties 
	{
	    [HideInInspector]_MainTex ("Base (RGB)", 2D) = "white" {}
        _Delta("Line Thickness", Range(0.0005, 0.0025)) = 0.001
        _DepthLineIntensity("Depth Line Intensity", Range(0, 1)) = 1
        _DepthRemapValues("Depth Sobel parameters", Vector) = (0.0, 0.00016666, 0.0, 1.0)
        _OpaqueLineIntensity("Opaque Line Intensity", Range(0, 1)) = 1
        _OpaqueRemapValues("Opaque Sobel parameters", Vector) = (0.0, 0.03, 0.0, 1.0)
        _NoiseStrenght("Noise Strenght", Range(0, 1)) = 1
        _NoiseTexture("Noise Texture (RG)", 2D) = "black" {}
		[Toggle(RAW_OUTLINE)]_Raw ("Outline Only", Float) = 0
		[Toggle(POSTERIZE)]_Poseterize ("Posterize", Float) = 0
		_PosterizationCount ("Posterization Count", int) = 8
	}
	SubShader 
	{
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		Pass
		{
            Name "Sobel Filter"
            HLSLPROGRAM
            //#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/UnityInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            
            #pragma shader_feature RAW_OUTLINE
            #pragma shader_feature POSTERIZE
            
            TEXTURE2D(_CameraDepthTexture);
            SAMPLER(sampler_CameraDepthTexture); 
            
            TEXTURE2D(_CameraOpaqueTexture);
            SAMPLER(sampler_CameraOpaqueTexture);

            TEXTURE2D(_NoiseTexture);
            SAMPLER(sampler_NoiseTexture);
            
#ifndef RAW_OUTLINE
            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
#endif
            float _Delta;
            float _DepthLineIntensity;
            float _OpaqueLineIntensity;
            float _NoiseStrenght;
            int _PosterizationCount;
            float4 _DepthRemapValues;
            float4 _OpaqueRemapValues;
            
            struct Attributes
            {
                float4 positionOS       : POSITION;
                float2 uv               : TEXCOORD0;
            };

            struct Varyings
            {
                float2 uv        : TEXCOORD0;
                float4 vertex : SV_POSITION;
                UNITY_VERTEX_OUTPUT_STEREO
            };
            
            float SampleDepth(float2 uv)
            {
#if defined(UNITY_STEREO_INSTANCING_ENABLED) || defined(UNITY_STEREO_MULTIVIEW_ENABLED)
                return SAMPLE_TEXTURE2D_ARRAY(_CameraDepthTexture, sampler_CameraDepthTexture, uv, unity_StereoEyeIndex).r;
#else
                return SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, sampler_CameraDepthTexture, uv);
#endif
            }

            float SampleOpaque(float2 uv)
            {
#if defined(UNITY_STEREO_INSTANCING_ENABLED) || defined(UNITY_STEREO_MULTIVIEW_ENABLED)
                return SAMPLE_TEXTURE2D_ARRAY(_CameraOpaqueTexture, sampler_CameraOpaqueTexture, uv, unity_StereoEyeIndex).r;
#else
                return SAMPLE_DEPTH_TEXTURE(_CameraOpaqueTexture, sampler_CameraOpaqueTexture, uv);
#endif
            }

            float2 SampleNoiseOffset(float2 uv) 
            {
                float4 rawOffset = SAMPLE_TEXTURE2D(_NoiseTexture, sampler_NoiseTexture, uv);

                float2 offset = rawOffset.xy + float2(-0.5f, -0.5f);

                return normalize(offset);
            }
            
            float sobelDepth (float2 uv) 
            {
                float2 delta = float2(_Delta, _Delta);
                
                float hr = 0;
                float vt = 0;
                
                hr += SampleDepth(uv + float2(-1.0, -1.0) * delta) *  1.0;
                hr += SampleDepth(uv + float2( 1.0, -1.0) * delta) * -1.0;
                hr += SampleDepth(uv + float2(-1.0,  0.0) * delta) *  2.0;
                hr += SampleDepth(uv + float2( 1.0,  0.0) * delta) * -2.0;
                hr += SampleDepth(uv + float2(-1.0,  1.0) * delta) *  1.0;
                hr += SampleDepth(uv + float2( 1.0,  1.0) * delta) * -1.0;
                
                vt += SampleDepth(uv + float2(-1.0, -1.0) * delta) *  1.0;
                vt += SampleDepth(uv + float2( 0.0, -1.0) * delta) *  2.0;
                vt += SampleDepth(uv + float2( 1.0, -1.0) * delta) *  1.0;
                vt += SampleDepth(uv + float2(-1.0,  1.0) * delta) * -1.0;
                vt += SampleDepth(uv + float2( 0.0,  1.0) * delta) * -2.0;
                vt += SampleDepth(uv + float2( 1.0,  1.0) * delta) * -1.0;
                
                return sqrt(hr * hr + vt * vt);
            }

            float sobelOpaque(float2 uv)
            {
                float2 delta = float2(_Delta, _Delta);

                float hr = 0;
                float vt = 0;

                hr += SampleOpaque(uv + float2(-1.0, -1.0) * delta) * 1.0;
                hr += SampleOpaque(uv + float2(1.0, -1.0) * delta) * -1.0;
                hr += SampleOpaque(uv + float2(-1.0, 0.0) * delta) * 2.0;
                hr += SampleOpaque(uv + float2(1.0, 0.0) * delta) * -2.0;
                hr += SampleOpaque(uv + float2(-1.0, 1.0) * delta) * 1.0;
                hr += SampleOpaque(uv + float2(1.0, 1.0) * delta) * -1.0;

                vt += SampleOpaque(uv + float2(-1.0, -1.0) * delta) * 1.0;
                vt += SampleOpaque(uv + float2(0.0, -1.0) * delta) * 2.0;
                vt += SampleOpaque(uv + float2(1.0, -1.0) * delta) * 1.0;
                vt += SampleOpaque(uv + float2(-1.0, 1.0) * delta) * -1.0;
                vt += SampleOpaque(uv + float2(0.0, 1.0) * delta) * -2.0;
                vt += SampleOpaque(uv + float2(1.0, 1.0) * delta) * -1.0;

                return sqrt(hr * hr + vt * vt);
            }

            float map(float lh1, float rh1, float lh2, float rh2, float value) {
                float t = (value - lh1) / (rh1 - lh1);
                return t * (rh2 - lh2) + lh2;
            }
            
            Varyings vert(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
                output.vertex = vertexInput.positionCS;
                output.uv = input.uv;
                
                return output;
            }
            
            half4 frag (Varyings input) : SV_Target 
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float2 textureOffset = 
                    normalize(SAMPLE_TEXTURE2D(_NoiseTexture, sampler_NoiseTexture, input.uv).xy);
                float2 offset = float2(
                    map(0.0f, 1.0f, -1.0f, 1.0f, textureOffset.x),
                    map(0.0f, 1.0f, -1.0f, 1.0f, textureOffset.y));
                float2 uv = input.uv + offset * _NoiseStrenght;
                
                //float s = pow(1 - saturate(sobel(input.uv)), 50);
                float sDepth = 1 - round(
                    map(_DepthRemapValues.x, _DepthRemapValues.y, _DepthRemapValues.z, _DepthRemapValues.w,
                        sobelDepth(uv).x));
                float sOpaque = 1 - round(
                    map(_OpaqueRemapValues.x, _OpaqueRemapValues.y, _OpaqueRemapValues.z, _OpaqueRemapValues.w,
                        sobelOpaque(uv).x));

                //float s = min(sDepth, sOpaque);
                float s = saturate(
                    lerp(1, sDepth, _DepthLineIntensity) +
                    lerp(1, sOpaque, _OpaqueLineIntensity));
#ifdef RAW_OUTLINE
                return half4(s.xxx, 1);
#else
                half4 col = SAMPLE_TEXTURE2D_LOD(_MainTex, sampler_MainTex, input.uv, 0.0);
#ifdef POSTERIZE
                col = pow(col, 0.4545);
                float3 c = RgbToHsv(col);
                c.z = round(c.z * _PosterizationCount) / _PosterizationCount;
                col = float4(HsvToRgb(c), col.a);
                col = pow(col, 2.2);
#endif
                return col * s;
#endif
            }
            
			#pragma vertex vert
			#pragma fragment frag
			
			ENDHLSL
		}
	} 
	FallBack "Diffuse"
}
