// The MIT License
// Copyright © 2019 Inigo Quilez
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions: The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software. THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

// This is a 1D noise that uses a single random number/hash
// per invocation, instead of two like regular value and gradient
// noises do. This means no neighboring information is needed
// in order to preserve continuity, and therefore it's much faster
// than both Value and Gradient Noise.
//
// In fact, this is a hybrid between the two - it has zeros at
// integer locations like Gradient noise, but the gradients/
// derivatives are constant, +-1. That way each cycle's boundaries
// are fixed and continuity is preserved always. Then, the single
// per cycle random number K controls the value of the signal's
// peak, a bit like in a Value Noise. A quartic function is used
// to interpolate the whole curve inside the cycle.
//
// p(0)=0, p'(0)=1, p(1)=0, p'(1)=-1, p(1/2)=k, p'(1/2)=0
//
// results in
//
// p(x)=x·(x-1)·((16k-4)·x·(x-1)-1)
//
// The yellow curve shows this new Basic Noise, superimposed on
// top of a regular Gradient Noise in dark grey.

float hash(uint n)
{ // integer hash copied from Hugo Elias
    n = (n << 13U) ^ n;
    n = n * (n * n * 15731U + 789221U) + 1376312589U;
    return float(n & uvec3(0x0fffffffU)) / float(0x0fffffff);
}

// Basic noise
float bnoise(in float x)
{
    float i = floor(x);
    float f = fract(x);
    float s = sign(fract(x / 2.0) - 0.5);

    // use some hash to create a random value k in [0..1] from i
    float k = hash(uint(i));
    //float k = 0.5+0.5*sin(i);
    //float k = fract(i*.1731);

    return s * f * (f - 1.0) * ((16.0 * k - 4.0) * f * (f - 1.0) - 1.0);
}

// Traditional gradient noise
float gnoise(in float p)
{
    uint i = uint(floor(p));
    float f = fract(p);
    float u = f * f * (3.0 - 2.0 * f);

    float g0 = hash(i + 0u) * 2.0 - 1.0;
    float g1 = hash(i + 1u) * 2.0 - 1.0;
    return 2.4 * mix(g0 * (f - 0.0), g1 * (f - 1.0), u);
}

////////////////////////////////////

float fbm(in float x)
{
    float n = 0.0;
    float s = 1.0;
    for (int i = 0; i < 9; i++) {
        n += s * bnoise(x);
        s *= 0.5;
        x *= 2.0;
        x += 0.131;
    }
    return n;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    float px = 1.0 / iResolution.y;
    vec2 p = fragCoord * px;

    vec3 col = vec3(0.0);
    col = mix(col, vec3(0.7), 1.0 - smoothstep(0.0, 2.0 * px, abs(p.y - 0.75)));
    col = mix(col, vec3(0.7), 1.0 - smoothstep(0.0, 2.0 * px, abs(p.y - 0.25)));
    p.x += iTime * 0.1;

    {
        float y = 0.75 + 0.25 * gnoise(6.0 * p.x);
        col = mix(col, vec3(0.3, 0.3, 0.3),
            1.0 - smoothstep(0.0, 4.0 * px, abs(p.y - y)));
    }

    {
        float y = 0.75 + 0.25 * bnoise(6.0 * p.x);
        col = mix(col, vec3(1.0, 1.0, 0.0),
            1.0 - smoothstep(0.0, 4.0 * px, abs(p.y - y)));
    }

    {
        float y = 0.25 + 0.15 * fbm(2.0 * p.x);
        col = mix(col, vec3(1.0, 0.6, 0.2),
            1.0 - smoothstep(0.0, 4.0 * px, abs(p.y - y)));
    }

    fragColor = vec4(col, 1.0);
}
