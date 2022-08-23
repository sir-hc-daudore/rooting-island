void Sobel_float(float2 TextureSize, float2 UV, float PixelScale, Texture2D FilterTexture, SamplerState SS, out float Magnitude)
{
    float2 pixelSize = 1.0 / TextureSize.xy * PixelScale;

    float gx = -1.0 * SAMPLE_TEXTURE2D(FilterTexture, SS, UV.xy - pixelSize).r
                - 2.0 * SAMPLE_TEXTURE2D(FilterTexture, SS, UV.xy + float2(-pixelSize.x, 0)).r
                - 1.0 * SAMPLE_TEXTURE2D(FilterTexture, SS, UV.xy + float2(-pixelSize.x, pixelSize.y)).r
                + 1.0 * SAMPLE_TEXTURE2D(FilterTexture, SS, UV.xy + float2(pixelSize.x, -pixelSize.y)).r
                + 2.0 * SAMPLE_TEXTURE2D(FilterTexture, SS, UV.xy + float2(pixelSize.x, 0)).r
                + 1.0 * SAMPLE_TEXTURE2D(FilterTexture, SS, UV.xy + pixelSize).r;
    float gy = -1.0 * SAMPLE_TEXTURE2D(FilterTexture, SS, UV.xy - pixelSize).r
                - 2.0 * SAMPLE_TEXTURE2D(FilterTexture, SS, UV.xy + float2(0, -pixelSize.y)).r
                - 1.0 * SAMPLE_TEXTURE2D(FilterTexture, SS, UV.xy + float2(pixelSize.x, -pixelSize.y)).r
                + 1.0 * SAMPLE_TEXTURE2D(FilterTexture, SS, UV.xy + float2(-pixelSize.x, pixelSize.y)).r
                + 2.0 * SAMPLE_TEXTURE2D(FilterTexture, SS, UV.xy + float2(0, pixelSize.y)).r
                + 1.0 * SAMPLE_TEXTURE2D(FilterTexture, SS, UV.xy + pixelSize).r;

    Magnitude = sqrt(gx * gx + gy * gy);
}