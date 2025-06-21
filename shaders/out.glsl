#version 440

uniform sampler2D feedbackTex;
uniform sampler2D logoTex;

out vec4 color;

#pragma include "shaders/common.glsl"

vec4 logo(vec2 uv, vec2 p, float scale, float offset, float offset2, float t) {
    vec2 p2 = p;
    p2 += offset;
    float alpha = mod(floor(uv.x * 3.0 + t), 2.0) == 1.0 ? 1.0 : 0.0;
    vec2 logoUv = vec2(fract(uv.x * 3.0 + t), uv.y * 3.0 - offset2);
    float s = step(sdBox(p2, vec2(10.0, scale)), 0.0001);
    vec4 logo = vec4(s) - texture(logoTex, logoUv) * alpha;

    return vec4(logo.rgb, s);
}

void main() {

    vec2 uv = (gl_FragCoord.xy / resolution.xy);
    vec2 p = (gl_FragCoord.xy * 2.0 - resolution.xy) / min(resolution.x, resolution.y);

    vec4 logo1 = logo(uv, p, 0.05, -0.95, 2.425, beat / 16.0);
    vec4 logo2 = logo(uv, p, 0.05, 0.95, -0.425, -beat / 16.0);

    vec4 col = texture(feedbackTex, uv) * (sliders[0] * 0.5 + 1.0);
    col.rgb = sliders[6] == 1.0 ? mix(vec3(0.0), vec3(1.0, 0.45, 0.0), col.rgb) : col.rgb;

    col *= (1.0 - logo1.a) * (1.0 - logo2.a);
    col += mix(vec4(0.0), vec4(1.0, 0.45, 0.0, 1.0), logo1.x + logo2.x);

    color = col * (1.0 - buttons[31].x);
}