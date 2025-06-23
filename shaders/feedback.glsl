#version 440

uniform sampler2D gfxTex;
uniform sampler2D feedbackTex;
uniform sampler2D logoTex;

out vec4 color;

#pragma include "shaders/common.glsl"

vec4 logo(vec2 uv, vec2 p, float scale, float offset, float offset2, float t) {
    vec2 p2 = p;
    p2 += offset;
    float alpha = mod(floor(uv.x * 4.0 + t), 2.0) == 1.0 ? 1.0 : 0.0;
    vec2 logoUv = vec2(fract(uv.x * 4.0 + t), uv.y * 4.0 - offset2);
    float s = step(sdBox(p2, vec2(10.0, scale)), 0.0001);
    vec4 logo = vec4(s) - texture(logoTex, logoUv) * alpha;

    return vec4(logo.rgb, s);
}

void main() {

    vec2 uv = (gl_FragCoord.xy / resolution.xy);
    vec2 p = (gl_FragCoord.xy * 2.0 - resolution.xy) / min(resolution.x, resolution.y);

    vec4 logo1 = logo(uv, p, 0.035, -0.965, 3.430, beat / 16.0);
    vec4 logo2 = logo(uv, p, 0.035, 0.965, -0.430, -beat / 16.0);

    vec3 n = cyclic(vec3(uv, beat / 8.0), 10.0);

    vec4 col = texture(gfxTex, uv);
    vec4 past = texture(feedbackTex, uv + n.xy * 0.01);

    // https://www.shadertoy.com/view/4tcyRN ありがとん
    float scale = 16.0/9.0 * 12.0;
    vec2 fragCoord = gl_FragCoord.xy - mod(gl_FragCoord.xy, scale);
    vec2 o = scale / resolution.xy;
    vec2 uv2 = (fragCoord / resolution.xy) + (o * 0.5);

    vec3 cnt = vec3(0.0);

    for (int x = -1; x <= 1; x++) {
        for (int y = -1; y <= 1; y++) {
            vec3 c = texture(feedbackTex, uv2 + o * vec2(x, y)).rgb;
            if (x != 0 && y != 0) {
                if (0.0 < c.r) cnt.r += 1.0;
                if (0.0 < c.g) cnt.g += 1.0;
                if (0.0 < c.b) cnt.b += 1.0;

            }
        }
    }

    // if (past.r < 1.0) {
    //     if (cnt.r == 3.0 || cnt.r == 6.0 || cnt.r == 7.0 || cnt.r == 8.0) col.r = 1.0;
    // } else {
    //     col.r = cnt.r == 3.0 || cnt.r == 4.0 || cnt.r == 6.0 || cnt.r == 7.0 || cnt.r == 8.0 ? 1.0 : 0.0;
    // }

    // if (past.g < 1.0) {
    //     if (cnt.g == 3.0 || cnt.g == 6.0 || cnt.g == 7.0 || cnt.g == 8.0) col.g = 1.0;
    // } else {
    //     col.g = cnt.g == 3.0 || cnt.g == 4.0 || cnt.g == 6.0 || cnt.g == 7.0 || cnt.g == 8.0 ? 1.0 : 0.0;
    // }

    // if (past.b < 1.0) {
    //     if (cnt.b == 3.0 || cnt.b == 6.0 || cnt.b == 7.0 || cnt.b == 8.0) col.b = 1.0;
    // } else {
    //     col.b = cnt.b == 3.0 || cnt.b == 4.0 || cnt.b == 6.0 || cnt.b == 7.0 || cnt.b == 8.0 ? 1.0 : 0.0;
    // }

    // abs(abs(sin(col*10.0 + iTime * 10.0)) - pow(backCol, vec4(0.85)))

    // color = mix(col, past, sliders[0] * 1.0);

    col *= (1.0 - logo1.a) * (1.0 - logo2.a);
    col += logo1.x + logo2.x;

    color = mix(col, abs(sin(col * 1.1) - cos(past * 1.2)), sliders[0] * 0.975);
}