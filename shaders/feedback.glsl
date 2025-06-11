#version 440

uniform sampler2D gfxTex;
uniform sampler2D feedbackTex;

out vec4 color;

#pragma include "shaders/common.glsl"

void main() {

    vec2 uv = (gl_FragCoord.xy / resolution.xy);

    vec4 col = texture(gfxTex, uv);
    vec4 past = texture(feedbackTex, uv);

    color = mix(col, abs(col - past), sliders[0] * 0.95);
}