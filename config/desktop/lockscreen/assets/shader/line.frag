#version 460

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;

    vec2 p1;
    vec2 p2;
    vec4 color1;
    vec4 color2;
    float intensity;
    float time;
    vec2 resolution;
} ubuf;

// Simple 1D hash and noise functions for jaggedness
float hash(float n) { return fract(sin(n) * 1e4); }
float noise(float x) {
    float i = floor(x);
    float f = fract(x);
    float u = f * f * (3.0 - 2.0 * f);
    return mix(hash(i), hash(i + 1.0), u);
}

// Distance to line segment
float sdLine(vec2 p, vec2 a, vec2 b) {
    vec2 pa = p - a, ba = b - a;
    float h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
    return length(pa - ba * h);
}

// sRGB to Oklab
vec3 linear_srgb_to_oklab(vec3 c) {
    float l = 0.4122214708 * c.r + 0.5363325363 * c.g + 0.0514459929 * c.b;
    float m = 0.2119034982 * c.r + 0.6806995451 * c.g + 0.1073969566 * c.b;
    float s = 0.0883024619 * c.r + 0.2817188376 * c.g + 0.6299787005 * c.b;

    float l_ = sign(l) * pow(abs(l), 1.0/3.0);
    float m_ = sign(m) * pow(abs(m), 1.0/3.0);
    float s_ = sign(s) * pow(abs(s), 1.0/3.0);

    return vec3(
        0.2104542553*l_ + 0.7936177850*m_ - 0.0040720468*s_,
        1.9779984951*l_ - 2.4285922050*m_ + 0.4505937099*s_,
        0.0259040371*l_ + 0.7827717662*m_ - 0.8086757660*s_
    );
}

// Oklab to sRGB
vec3 oklab_to_linear_srgb(vec3 c) {
    float l_ = c.x + 0.3963377774 * c.y + 0.2158037573 * c.z;
    float m_ = c.x - 0.1055613458 * c.y - 0.0638541728 * c.z;
    float s_ = c.x - 0.0894841775 * c.y - 1.2914855480 * c.z;

    float l = l_*l_*l_;
    float m = m_*m_*m_;
    float s = s_*s_*s_;

    return vec3(
        +4.0767416621 * l - 3.3077115913 * m + 0.2309699292 * s,
        -1.2684380046 * l + 2.6097574011 * m - 0.3413193965 * s,
        -0.0041960863 * l - 0.7034186147 * m + 1.7076147010 * s
    );
}

void main() {
    vec2 p = qt_TexCoord0 * ubuf.resolution;
    vec2 a = ubuf.p1;
    vec2 b = ubuf.p2;
    
    vec2 dir = b - a;
    float len = length(dir);
    if (len < 0.001) discard;
    
    vec2 ndir = normalize(dir);
    vec2 norm = vec2(-ndir.y, ndir.x); // Perpendicular vector for displacement
    
    // Project current pixel onto the line to find the mix factor
    vec2 pa = p - a;
    float t = dot(pa, ndir);
    float normT = clamp(t / len, 0.0, 1.0);
    
    // 1. Calculate Oklab gradient color
    // Assume input colors are sRGB, approximate linear by squaring
    vec3 linear1 = ubuf.color1.rgb * ubuf.color1.rgb;
    vec3 linear2 = ubuf.color2.rgb * ubuf.color2.rgb;
    
    vec3 ok1 = linear_srgb_to_oklab(linear1);
    vec3 ok2 = linear_srgb_to_oklab(linear2);
    vec3 okMix = mix(ok1, ok2, normT);
    vec3 rgbMix = sqrt(clamp(oklab_to_linear_srgb(okMix), 0.0, 1.0)); // Approximate back to sRGB
    
    // 2. Generate multiple jagged lines overlaid on top of each other
    float alpha = 0.0;
    int numLines = 3;
    
    // Envelope ensures the line stays pinned to the exact centers of the letters
    float envelope = sin(normT * 3.14159265); 
    
    for (int i = 0; i < numLines; i++) {
        float timeOffset = ubuf.time * (2.0 + float(i));
        float freq = 8.0 + float(i) * 5.0;
        float amp = 15.0 / (float(i) + 1.0);
        
        // Jagged displacement along the normal
        float displacement = (noise(normT * freq - timeOffset) - 0.5) * 2.0 * amp * envelope;
        
        vec2 displacedP = p - norm * displacement;
        float d = sdLine(displacedP, a, b);
        
        // Additive glowing core and soft edges
        alpha += 0.8 * exp(-d * 0.5) + 0.2 * exp(-d * 0.1);
    }
    
    // Final composite
    fragColor = vec4(rgbMix, 1.0) * min(alpha, 1.0) * ubuf.intensity * ubuf.qt_Opacity;
}