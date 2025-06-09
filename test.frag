#version 440

uniform vec4 resolution;
uniform float time;

uniform sampler2D tex;

uniform float sliders[32];
uniform vec4 buttons[32];

out vec4 color;

void main() {
    vec2 uv = gl_FragCoord.xy / resolution.xy;

    color = vec4(uv, abs(sin(time)), 1.0);
}