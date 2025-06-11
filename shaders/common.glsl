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