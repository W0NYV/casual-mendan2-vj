#version 440

uniform sampler2D gfxTex;
uniform sampler2D feedbackTex;
uniform sampler2D logoTex;
uniform sampler2D ndi;

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

vec3 moon(vec2 p)
{
    vec3 rnd = pcg3df(vec3(floor(beat), 85.34, 524.21));

    float m = sdBox(p, vec2(0.95 + rnd.x, 0.005));

    for (float i = 0.0; i < 7.0; i += 1.0)
    {
        vec3 irnd = pcg3df(vec3(floor(beat), i + 645.34, 412.23));
        float s = sdBox(p - (irnd.xy * 2.0 - 1.0) * vec2(1.2, 0.3), vec2(0.002, irnd.z * 0.75));
        m = smin(m, s, 0.01);
    }

    for (float i = 0.0; i < 16.0; i += 1.0)
    {
        vec2 p2 = p;
        vec3 irnd = pcg3df(vec3(8735.324, floor(beat), i + 523.123));
        vec3 irnd2 = pcg3df(vec3(i + 1251.2, 76.43214, floor(beat)));

        vec2 pos = (irnd.yz * 2.0 - 1.0) * vec2(1.3, 0.35);
        float size = 0.1 + irnd2.x * 0.35;
        float offset = irnd2.y * 0.025 + 0.975;

        p2 *= rot(acos(-1.0) * 2.0 * irnd.x + beat / 8.0);
        p2 -= pos * rot(acos(-1.0) * 2.0 * irnd.x + beat / 8.0);

        m = smin(m, sdMoon(p2, irnd2.z * 0.025, size, size * offset), 0.01);
    }

    return vec3(step(m + 0.0001, 0.0001));
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
    // float scale = 16.0/9.0 * 10.0;
    // vec2 fragCoord = gl_FragCoord.xy - mod(gl_FragCoord.xy, scale);
    // vec2 o = scale / resolution.xy;
    // vec2 uv2 = (fragCoord / resolution.xy) + (o * 0.5);

    // vec3 cnt = vec3(0.0);

    // for (int x = -1; x <= 1; x++) {
    //     for (int y = -1; y <= 1; y++) {
    //         vec3 c = texture(feedbackTex, uv2 + o * vec2(x, y)).rgb;
    //         if (x != 0 && y != 0) {
    //             if (0.0 < c.r) cnt.r += 1.0;
    //             if (0.0 < c.g) cnt.g += 1.0;
    //             if (0.0 < c.b) cnt.b += 1.0;

    //         }
    //     }
    // }

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

    col = mix(col, texture(ndi, uv), sliders[2]);

    col *= (1.0 - logo1.a) * (1.0 - logo2.a);
    col += logo1.x + logo2.x;

    p = sliders[4] == 1.0 ? abs(p) : p;
    col += vec4(moon(p) * sliders[5], 1.0);

    color = mix(mix(col, past, sliders[0] * 0.975), mix(col, abs(sin(col * 1.1) - cos(past * 1.2)), sliders[0] * 0.975), sliders[1]);

}