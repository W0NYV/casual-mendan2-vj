#version 440

uniform sampler2D gfxTex;
uniform sampler2D feedbackTex;

out vec4 color;

#pragma include "shaders/common.glsl"

void main() {

    vec2 uv = (gl_FragCoord.xy / resolution.xy);

    vec4 col = texture(gfxTex, uv);
    vec4 past = texture(feedbackTex, uv);

    // https://www.shadertoy.com/view/4tcyRN ありがとん
    float scale = 16.0/9.0 * 10.0;
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

    if (past.r < 1.0) {
        if (cnt.r == 3.0 || cnt.r == 6.0 || cnt.r == 7.0 || cnt.r == 8.0) col.r = 1.0;
    } else {
        col.r = cnt.r == 3.0 || cnt.r == 4.0 || cnt.r == 6.0 || cnt.r == 7.0 || cnt.r == 8.0 ? 1.0 : 0.0;
    }

    if (past.g < 1.0) {
        if (cnt.g == 3.0 || cnt.g == 6.0 || cnt.g == 7.0 || cnt.g == 8.0) col.g = 1.0;
    } else {
        col.g = cnt.g == 3.0 || cnt.g == 4.0 || cnt.g == 6.0 || cnt.g == 7.0 || cnt.g == 8.0 ? 1.0 : 0.0;
    }

    if (past.b < 1.0) {
        if (cnt.b == 3.0 || cnt.b == 6.0 || cnt.b == 7.0 || cnt.b == 8.0) col.b = 1.0;
    } else {
        col.b = cnt.b == 3.0 || cnt.b == 4.0 || cnt.b == 6.0 || cnt.b == 7.0 || cnt.b == 8.0 ? 1.0 : 0.0;
    }

    color = mix(col, abs(col - past), 0.0025 + sliders[0] * 0.95);
}