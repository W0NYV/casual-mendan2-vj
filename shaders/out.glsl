#version 440

uniform sampler2D feedbackTex;

out vec4 color;

#pragma include "shaders/common.glsl"

void main() {

    vec2 uv = (gl_FragCoord.xy / resolution.xy);

    vec4 col = texture(feedbackTex, uv) * (sliders[0] * 0.5 + 1.0);

    color = col * (1.0 - buttons[0].x);
}