#pragma once

uniform vec4 resolution;
uniform float time;
uniform float beat;

uniform float sliders[32];
uniform vec4 buttons[32];

vec3 pcg3df(vec3 v) {
    uvec3 r = floatBitsToUint(v);
    r = r * 1664525u + 1013904223u;
  
    r.x += r.y*r.z;
    r.y += r.z*r.x;
    r.z += r.x*r.y;
  
    r ^= r >> 16u;
  
    r.x += r.y*r.z;
    r.y += r.z*r.x;
    r.z += r.x*r.y;
  
    return vec3(r) / float(0xffffffffu);
}

vec2 randomNormal(vec2 p)
{
    float c = sqrt(-2.0 * log(p.x));
    float r = 2.0 * p.y * acos(-1.0);
    
    return vec2(c * cos(r), c * sin(r));
}

mat2 rot(float r) {
    return mat2(cos(r), sin(r), -sin(r), cos(r));
}

float easeOutExpo(float x) {
    return x == 1.0 ? 1.0 : 1.0 - pow(2.0, - 10.0 * x);
}

float sdBox(vec2 p, vec2 b) {
    vec2 d = abs(p) - b;
    return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
}

vec3[9] mooreNeighborhood(sampler2D tex, vec2 fragCoord, vec2 resolution) {
    vec3 mc = texture(tex, (fragCoord + vec2(0.0, 0.0))/resolution.xy).rgb;
    vec3 mr = texture(tex, (fragCoord + vec2(1.0, 0.0))/resolution.xy).rgb;
    vec3 ml = texture(tex, (fragCoord + vec2(-1.0, 0.0))/resolution.xy).rgb;

    vec3 tc = texture(tex, (fragCoord + vec2(0.0, 1.0))/resolution.xy).rgb;
    vec3 tr = texture(tex, (fragCoord + vec2(1.0, 1.0))/resolution.xy).rgb;
    vec3 tl = texture(tex, (fragCoord + vec2(-1.0, 1.0))/resolution.xy).rgb;

    vec3 bc = texture(tex, (fragCoord + vec2(0.0, -1.0))/resolution.xy).rgb;
    vec3 br = texture(tex, (fragCoord + vec2(1.0, -1.0))/resolution.xy).rgb;
    vec3 bl = texture(tex, (fragCoord + vec2(-1.0, -1.0))/resolution.xy).rgb;
    
    vec3[9] array;
    array[0] = tl, array[1] = tc, array[2] = tr;
    array[3] = ml, array[4] = mc, array[5] = mr;
    array[6] = bl, array[7] = bc, array[8] = br;
    
    return array;
}