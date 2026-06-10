#version 460

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;

    float intensity;
    vec4 glowColor;
    vec2 pixelSize;
} data;

layout(binding = 1) uniform sampler2D source;

void main() {
    vec4 src = texture(source, qt_TexCoord0);

    float minRadius = 8.0;
    float maxRadius = 15.0;
    float radius = data.intensity * (maxRadius - minRadius) + minRadius;

    float alphaSum = 0.0;
    float weightSum = 0.0;

    // broken blur by gemini, looks cool tho

    // Golden angle for even sampling distribution
    float goldenAngle = 2.39996323; 
    float numSamples = data.intensity > 0.0 ? 5.0 + data.intensity * 11.0 : 0;

    for (float j = 0.0; j < numSamples; j += 1.0) {
        float r = sqrt(j + 0.5) / sqrt(numSamples);
        float theta = j * goldenAngle;
        vec2 offset = vec2(cos(theta), sin(theta)) * r * radius;

        // Sample the alpha channel of the nearby pixels
        float sampleAlpha = texture(source, qt_TexCoord0 + offset * data.pixelSize).a;

        // Weight samples closer to the center slightly higher
        float weight = 1.0 - (r * 0.5);
        alphaSum += sampleAlpha * weight;
        weightSum += weight;
    }
    alphaSum /= weightSum;

    // increase alpha by a lot to make effect more visible and saturated
    alphaSum = clamp(alphaSum * 5.0, 0.0, 1.0);

    alphaSum *= data.intensity;

    // Build the glow color (premultiplied alpha)
    vec4 finalGlow = vec4(data.glowColor.rgb * alphaSum, alphaSum);

    // Composite: Source drawn over the Glow
    fragColor = src + finalGlow * (1.0 - src.a);
    fragColor *= data.qt_Opacity;
}