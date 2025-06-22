#version 440

uniform sampler2D feedbackTex;

out vec4 color;

#pragma include "shaders/common.glsl"

void main() {

    vec2 uv = (gl_FragCoord.xy / resolution.xy);
    vec2 p = (gl_FragCoord.xy * 2.0 - resolution.xy) / min(resolution.x, resolution.y);
    
    vec4 col = texture(feedbackTex, uv);// * (sliders[0] * 0.5 + 1.0);
    col.rgb = sliders[6] == 1.0 ? mix(vec3(0.0), vec3(1.0, 0.45, 0.0), col.rgb) : col.rgb;

    color = col * (1.0 - buttons[31].x);
}