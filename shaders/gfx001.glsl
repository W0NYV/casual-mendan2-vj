#version 440

uniform sampler2D logoTex;

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

vec3 triWave(vec2 p)
{
    float bounce = floor(beat) + easeOutExpo(fract(beat));

    vec3 noise = cyclic(vec3(beat/2.0, 324.32, 745.43), 8.0) * 0.5 + vec3(1.0);

    float id = floor(p.x * (0.2 + noise.x * 2.0) + beat / 2.0) - 0.5;
    p.x = fract(p.x * (0.2 + noise.x * 2.0) + beat / 2.0) - 0.5;

    float d = cyclic(vec3(beat / 4.0 + bounce * 0.65, id, 2312.32), 8.0).x;
    float f = length(p.x + asin(sin(bounce * 0.75 + p.y * (2.0 + d * 8.0))) * 0.2);
    f = step(f, 0.01 + 0.1 * (cyclic(vec3(id), 2.0).y * 0.5 + 1.0));

    vec3 c = vec3(f);
    c *= pcg3df(vec3(id)).x < 0.75 ? vec3(1.0) : vec3(1.0, 0.45, 0.0);

    return c;
}

vec3 worm(vec2 p)
{
    float bounce = floor(beat) + easeOutExpo(fract(beat));

    float f = 0.0;

    for (float k = 0.0; k < 7.0; k += 1.0)
    {
        for (float i = 0.0; i < 10.0; i += 1.0)
        {
            vec2 pos = cyclic(vec3(bounce + beat / 4.0 + i * 0.125, 412.321 + k * 10.0, 6743.32), 8.0).xy * 0.8;
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

vec3 springStar(vec2 p)
{
    float f = 0.0;
    float r = mix(pcg3df(vec3(7544.34, 1243.2, floor(beat - 1.0))).x, pcg3df(vec3(7544.34, 1243.2, floor(beat))).x, easeOutElastic(fract(beat)));

    for (float i = 0.0; i < 14.0; i += 1.0)
    {
        vec2 pp = p;

        float offset = i * 0.025;

        vec3 rnd = pcg3df(vec3(floor(beat - offset), 78.54 + i, 842.3));
        vec2 rnd2 = randomNormal(pcg3df(vec3(354.56, floor(beat - offset), 956.33 + i)).xy);

        pp *= rot(acos(-1.0) / 2.0 * r);

        pp.y += rnd.x * 4.0 - 2.0;
        pp.x += mix(rnd.y - 0.5, rnd.z * 2.0 - 1.0, easeOutElastic(fract(beat - offset)));

        pp = abs(pp);

        f = abs(f - step(sin(1.25 * (pow(pp.x, 2.0/5.0) + pow(pp.y, 2.0/3.5) - (abs(rnd2.x) * 0.35 + 0.3))), 0.0001));
    }

    return vec3(f);
}

vec3 crossTile(vec2 p) {

    p *= 0.98;

    vec3 rnd = pcg3df(vec3(74.31, 3423.32, floor(beat)));

    vec2 ip = floor(p * 3.0) - 0.5;

    float factor = rnd.z < 0.5 ? 1.0 : -1.0;

    if (mod(floor(beat), 2.0) == 1.0) {
        p.x -= floor(rnd.x * 6.0) - 3.0 == ip.y + 0.5 ? factor * easeOutExpo(fract(beat)) / 3.0 : 0.0;
    } 
    else
    {
        p.y -= floor(rnd.x * 6.0) - 3.0 == ip.x + 0.5 ? factor * easeOutExpo(fract(beat)) / 3.0 : 0.0;
    }

    vec2 fp = fract(p * 3.0) - 0.5;

    if (mod(floor(beat), 2.0) == 1.0) {
        fp *= floor(rnd.x * 6.0) - 3.0 == ip.y + 0.5 ? rot(fract(beat) * acos(-1.0) / 2.0 * factor) : mat2(1.0, 0.0, 0.0, 1.0);
    } 
    else
    {
        fp *= floor(rnd.x * 6.0) - 3.0 == ip.x + 0.5 ? rot(fract(beat) * acos(-1.0) / 2.0 * factor) : mat2(1.0, 0.0, 0.0, 1.0);
    }

    fp *= rot(acos(-1.0) / 4.0);
    float s = step(sdBox(fp, vec2(0.02, 0.2)), 0.0001) + step(sdBox(fp, vec2(0.2, 0.02)), 0.0001);

    return vec3(s);
}

vec3 pixelateCurve(vec2 p)
{
    vec3 c = vec3(0.0);
    vec2 reso = vec2(80.0, 45.0);
    vec2 p2 = p;
    vec3 rnd = pcg3df(vec3(floor(beat), 64.3, 123.12));

    for (float i = 0.0; i < 6.0; i += 1.0)
    {
        vec3 rnd2 = pcg3df(vec3(435.23, floor(beat), i));
        vec3 n = cyclic(vec3(p.x * 1.2 + i * 0.5, beat / 2.0, (floor(beat) + easeOutExpo(fract(beat))) * 2.0), 10.0);

        vec3 circle = vec3(1.0, 0.0, 0.0) * step(abs(length(floor((p2 - randomNormal(rnd2.xy) * 0.5) * reso) / reso) - 0.2 - rnd2.z * 0.2), 0.01);
        c += circle;

        p *= rot(acos(-1.0) * (rnd.x * 2.0 - 1.0) * 0.15);

        c += vec3(step(length((floor(p.y*reso)/reso) + n.x * 0.3), 0.015));
    }

    return c;
}

vec3 logoRotation(vec2 p)
{
    float t = floor(beat) + easeOutExpo(fract(beat));

    vec3 c = vec3(0.0);

    vec3 tRand = pcg3df(vec3(floor(beat), 7645.324, 32.23));

    p *= 0.05 + tRand.y * 1.0;

    float s = 0.0;

    for (float i = 0.0; i < 20.0; i += 1.0)
    {
        s += i;
        vec3 rnd = pcg3df(vec3(i, floor(beat), 243.23));

        vec2 p2 = p;
        float a = rnd.z < 0.5 ? -1.0 : 1.0;
        p2 *= rot(rnd.x * acos(-1.0) * 2.0 + beat / 4.0 * a + a * t * acos(-1.0) * rnd.y * 0.4);
        p2 = vec2(atan(p2.x, p2.y), length(p2) * 2.0);

        p *= 1.0 / (1.0 - p.x * (tRand.x * 2.0 - 1.0) * 0.2);
        p *= 1.0 / (1.0 - p.y * (tRand.z * 2.0 - 1.0) * 0.2);

        c += texture(logoTex, p2 * vec2(0.3, 30.0 / s * 0.9)).rgb;
    }

    return c;
}

vec3 triangles(vec2 p)
{
    float s = 0.0015;
    vec3 tri = vec3(0.0);
    vec2 aspect = vec2(1.8, 1.0) * 0.85;

    for (float i = 0.0; i < 7.0; i += 1.0)
    {
        vec3 pastRnd = pcg3df(vec3(floor(beat)-1.0, 74.234 + i, 463.23));
        vec3 rnd = pcg3df(vec3(floor(beat), 74.234 + i, 463.23));
        vec3 pastRnd2 = pcg3df(vec3(743.22, floor(beat)-1.0, 845.43 - i));
        vec3 rnd2 = pcg3df(vec3(743.22, floor(beat), 845.43 - i));

        vec3 lr = mix(pastRnd, rnd, easeOutElastic(fract(beat)));
        vec3 lr2 = mix(pastRnd2, rnd2, easeOutElastic(fract(beat)));

        vec2 pos = (lr.xy * 2.0 - 1.0) * aspect;
        vec2 pos2 = (vec2(lr.z, lr2.x) * 2.0 - 1.0) * aspect;
        vec2 pos3 = (lr2.yz * 2.0 - 1.0) * aspect;

        tri += vec3(1.0) * step(sdSegment(p, pos, pos2), s) + step(sdSegment(p, pos2, pos3), s) + step(sdSegment(p, pos3, pos), s);

        tri += vec3(1.0, 0.0, 0.0) * (step(sdBox(p - pos, vec2(0.005, 0.025)), 0.00001) + step(sdBox(p - pos - vec2(0.0, 0.005), vec2(0.02, 0.005)), 0.00001));
        tri += vec3(1.0, 0.0, 0.0) * (step(sdBox(p - pos2, vec2(0.005, 0.025)), 0.00001) + step(sdBox(p - pos2 - vec2(0.0, 0.005), vec2(0.02, 0.005)), 0.00001));
        tri += vec3(1.0, 0.0, 0.0) * (step(sdBox(p - pos3, vec2(0.005, 0.025)), 0.00001) + step(sdBox(p - pos3 - vec2(0.0, 0.005), vec2(0.02, 0.005)), 0.00001));

    }

    return tri;
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

    vec2 p = (gl_FragCoord.xy * 2.0 - resolution.xy) / min(resolution.x, resolution.y);
    p = sliders[7] == 1.0 ? abs(p) : p;

    vec3[11] gfxArray;
    gfxArray[0] = xorSquare(p);
    gfxArray[1] = interference(p);
    gfxArray[2] = triWave(p);
    gfxArray[3] = worm(p);
    gfxArray[4] = springStar(p);
    gfxArray[5] = crossTile(p);
    gfxArray[6] = pixelateCurve(p);
    gfxArray[7] = logoRotation(p);
    gfxArray[8] = triangles(p);
    gfxArray[9] = moon(p);

    gfxArray[10] = vec3(p, 0.0);

    int minIdx = 0;
    for (int i = 0; i < 11; i++)
    {
        if (buttons[i].y < buttons[minIdx].y)
        {
            minIdx = i;
        }
    }

    vec3 col = gfxArray[minIdx];

    color = vec4(col, 1.0);
}