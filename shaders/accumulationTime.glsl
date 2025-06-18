#version 440

out vec4 color;

#pragma include "shaders/common.glsl"

void main() {

    vec2 uv = (gl_FragCoord.xy / resolution.xy);

    vec4 col = texture(AccumTimeTex, uv);

    col += mod(floor(beat * 2.0), 2.0) == 1.0 ? vec4(easeOutExpo(fract(beat * 2.0))) : vec4(0.0);

    color = col;
}