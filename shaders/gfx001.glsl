#version 440

out vec4 color;

#pragma include "shaders/common.glsl"

vec3 xorSquare(vec2 p)
{
    float aspect = resolution.x/resolution.y;

    float square = 0.0;

    for (float i = 0.0; i < 20.0; i += 1.0)
    {
        vec2 size = pcg3df(vec3(floor(beat) - 1.0, 234.23 + i, 675.43)).xy * 0.69 + 0.01;
        vec2 nextSize = pcg3df(vec3(floor(beat), 234.23 + i, 675.43)).xy * 0.69 + 0.01;

        vec2 pos = randomNormal(pcg3df(vec3(744.423, floor(beat) - 1.0, 12.536 + i)).xy);
        vec2 nextPos = randomNormal(pcg3df(vec3(744.423, floor(beat), 12.536 + i)).xy);

        size = mix(size, nextSize, easeOutExpo(fract(beat)));
        pos = mix(pos, nextPos, easeOutExpo(fract(beat))) * vec2(1.0 * aspect, 1.0) * 0.3;

        square = abs(square - step(sdBox(p - pos, size), 0.00001));
    }

    return vec3(square);
}

void main() {

    vec2 p = (gl_FragCoord.xy * 2.0 - resolution.xy) / min(resolution.x, resolution.y);

    vec3 rnd = pcg3df(vec3(546.453, 454.312, floor(beat)));
    vec3 rnd2 = pcg3df(vec3(74.23, 894.23, floor(beat)));

    float f = sin(acos(-1.0) * rnd2.x * 0.5 + 5.0 * beat + length(p - (rnd.xy * 2.0 - 1.0)) * (rnd.z * 27.0 + 3.0)) 
            + sin(8.0 * beat + length(p - vec2(cos(beat / 3.0) * sin(beat), sin(beat / 5.0))) * (rnd2.z * 49.0 + 1.0));

    float f2 = sin(5.0 * beat + length(p - (rnd.xy * 2.0 - 1.0)) * (rnd.z * 27.0 + 3.0)) 
            + sin(8.0 * beat + length(p - vec2(cos(beat / 3.0) * sin(beat), sin(beat / 5.0))) * (rnd2.z * 49.0 + 1.0));

    float f3 = sin(acos(-1.0) * rnd2.z * 0.5 + 5.0 * beat + length(p - (rnd.xy * 2.0 - 1.0)) * (rnd.z * 27.0 + 3.0)) 
            + sin(8.0 * beat + length(p - vec2(cos(beat / 3.0) * sin(beat), sin(beat / 5.0))) * (rnd2.z * 49.0 + 1.0));

    vec3 col = vec3(pow(f, 3.0/2.0), pow(f2, 3.0/2.0), pow(f3, 4.0/5.0));

    col = buttons[16].y < buttons[17].y ? col : xorSquare(p);

    color = vec4(col, 1.0);
}