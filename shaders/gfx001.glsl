#version 440

out vec4 color;

#pragma include "shaders/common.glsl"

#define bounceTime texture(AccumTimeTex, vec2(0.0)).x

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

vec3 triWave(vec2 p)
{
    float bounce = bounceTime;

    vec3 noise = cyclic(vec3(beat/2.0, 324.32, 745.43), 8.0) * 0.5 + vec3(1.0);

    float id = floor(p.x * (0.2 + noise.x * 2.0) + beat / 2.0) - 0.5;
    p.x = fract(p.x * (0.2 + noise.x * 2.0) + beat / 2.0) - 0.5;

    float d = cyclic(vec3(beat / 4.0 + bounce * 0.02, id, 2312.32), 8.0).x;
    float f = length(p.x + asin(sin(bounce * 0.125 + p.y * (2.0 + d * 8.0))) * 0.2);
    f = step(f, 0.01 + 0.1 * (cyclic(vec3(id), 2.0).y * 0.5 + 1.0));

    vec3 c = vec3(f);
    c *= pcg3df(vec3(id)).x < 0.75 ? vec3(1.0) : vec3(1.0, 0.5, 0.0);

    return c;
}

vec3 worm(vec2 p)
{
    float bounce = bounceTime;

    float f = 0.0;

    for (float k = 0.0; k < 7.0; k += 1.0)
    {
        for (float i = 0.0; i < 10.0; i += 1.0)
        {
            vec2 pos = cyclic(vec3(bounce * 0.05 + beat / 4.0 + i * 0.125, 412.321 + k * 10.0, 6743.32), 8.0).xy * 0.8;
            pos.x *= resolution.z;

            float s = abs(randomNormal(pcg3df(vec3(744.423 + k, floor(beat) - 1.0, 12.536 + i)).xy).x);
            float nexts = abs(randomNormal(pcg3df(vec3(744.423 + k, floor(beat), 12.536 + i)).xy).x);

            s = mix(s, nexts, easeOutElastic(fract(beat))) * 0.1 + 0.1;

            f = abs(f - step(abs(length(p - pos) - s + i * 0.01), 0.002));
            f = abs(f - step(length(p - pos), s * 0.1 + 0.01 + (10.0 - i) * 0.005));
        }
    }

    vec2 fp = fract(p * 6.0) - 0.5;
    vec2 ip = floor(p * 6.0) - 0.5;
    float a = step(pcg3df(vec3(floor(beat), ip)).x, 0.65);
    float pastA = step(pcg3df(vec3(floor(beat - 1.0), ip)).x, 0.65);
    a = mix(pastA, a, easeOutElastic(fract(beat)));
    float squ = clamp(step(sdBox(fp, vec2(0.1, 0.01)), 0.001) + step(sdBox(fp, vec2(0.01, 0.1)), 0.001), 0.0, 1.0) * a;

    return vec3(f);
}

void main() {

    vec2 p = (gl_FragCoord.xy * 2.0 - resolution.xy) / min(resolution.x, resolution.y);

    vec3[5] gfxArray;
    gfxArray[0] = xorSquare(p);
    gfxArray[1] = interference(p);
    gfxArray[2] = triWave(p);
    gfxArray[3] = worm(p);

    float f = 0.0;
    float r = mix(pcg3df(vec3(7544.34, 1243.2, floor(beat - 1.0))).x, pcg3df(vec3(7544.34, 1243.2, floor(beat))).x, easeOutElastic(fract(beat)));


    for (float i = 0.0; i < 14.0; i += 1.0)
    {
        vec2 pp = p;

        float offset = i * 0.025;

        // vec3 pastRnd = pcg3df(vec3(floor(beat) - 1.0, 78.54, 842.3));
        vec3 rnd = pcg3df(vec3(floor(beat - offset), 78.54 + i, 842.3));
        vec2 rnd2 = randomNormal(pcg3df(vec3(354.56, floor(beat - offset), 956.33 + i)).xy);


        // float r = mix(pastRnd.x, rnd.x, easeOutElastic(fract(beat)));
        pp *= rot(acos(-1.0) / 2.0 * r);

        pp.y += rnd.x * 4.0 - 2.0;
        pp.x += mix(rnd.y - 0.5, rnd.z * 2.0 - 1.0, easeOutElastic(fract(beat - offset)));

        // p.x += fract(time);

        pp = abs(pp);

        f = abs(f - step(sin(1.25 * (pow(pp.x, 2.0/5.0) + pow(pp.y, 2.0/3.5) - (abs(rnd2.x) * 0.35 + 0.3))), 0.0001));
    }

    vec3 c = vec3(f);

    gfxArray[4] = c;

    int minIdx = 0;
    for (int i = 0; i < 5; i++)
    {
        if (buttons[i].y < buttons[minIdx].y)
        {
            minIdx = i;
        }
    }

    vec3 col = gfxArray[minIdx];

    color = vec4(col, 1.0);
}