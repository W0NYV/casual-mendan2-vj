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

vec3 interference(vec2 p)
{
    vec3 rnd = pcg3df(vec3(546.453, 454.312, floor(beat)));
    vec3 rnd2 = pcg3df(vec3(74.23, 894.23, floor(beat)));

    float f = sin(acos(-1.0) * rnd2.x * 0.15 + 5.0 * beat + length(p - (rnd.xy * 2.0 - 1.0)) * (rnd.z * 27.0 + 3.0)) 
            + sin(8.0 * beat + length(p - vec2(cos(beat / 3.0) * sin(beat), sin(beat / 5.0))) * (rnd2.z * 49.0 + 1.0));

    float f2 = sin(5.0 * beat + length(p - (rnd.xy * 2.0 - 1.0)) * (rnd.z * 27.0 + 3.0)) 
            + sin(8.0 * beat + length(p - vec2(cos(beat / 3.0) * sin(beat), sin(beat / 5.0))) * (rnd2.z * 49.0 + 1.0));

    float f3 = sin(acos(-1.0) * rnd2.z * 0.15 + 5.0 * beat + length(p - (rnd.xy * 2.0 - 1.0)) * (rnd.z * 27.0 + 3.0)) 
            + sin(8.0 * beat + length(p - vec2(cos(beat / 3.0) * sin(beat), sin(beat / 5.0))) * (rnd2.z * 49.0 + 1.0));

    return vec3(pow(f, 3.0/2.0), pow(f2, 3.0/2.0), pow(f3, 4.0/5.0));
}

void main() {

    vec2 p = (gl_FragCoord.xy * 2.0 - resolution.xy) / min(resolution.x, resolution.y);

    float bounce = texture(AccumTimeTex, vec2(0.0)).x;

    vec3[3] gfxArray;
    gfxArray[0] = xorSquare(p);
    gfxArray[1] = interference(p);

    vec3 noise = cyclic(vec3(beat/4.0, 324.32, 745.43), 2.0) * 0.5 + vec3(1.0);

    float id = floor(p.x * (0.2 + noise.x) + beat / 2.0) - 0.5;
    p.x = fract(p.x * (0.2 + noise.x) + beat / 2.0) - 0.5;

    float d = cyclic(vec3(beat / 4.0 + bounce * 0.02, id, 2312.32), 8.0).x;
    float f = length(p.x + asin(sin(bounce * 0.25 + p.y * (2.0 + d * 8.0))) * 0.2);
    f = step(f, 0.01 + 0.1 * (cyclic(vec3(id), 2.0).y * 0.5 + 1.0));

    vec3 c = vec3(f);
    c *= pcg3df(vec3(id)).x < 0.75 ? vec3(1.0) : vec3(1.0, 0.5, 0.0);

    gfxArray[2] = c;

    int minIdx = 0;
    for (int i = 0; i < 3; i++)
    {
        if (buttons[i].y < buttons[minIdx].y)
        {
            minIdx = i;
        }
    }

    vec3 col = gfxArray[minIdx];

    color = vec4(col, 1.0);
}