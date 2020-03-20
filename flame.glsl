#define PI 3.141592654

vec2 hash22(vec2 p)
{
    p = vec2(dot(p, vec2(127.1, 311.7)),
        dot(p, vec2(269.5, 183.3)));

    return -1.0 + 2.0 * fract(sin(p) * 43758.5453123);
}
vec3 fbm_noise(vec3 pos,float ft)
{
    vec3 kp=pos;
    float fre=1.0;
    float ap=0.5;
    vec3 d=vec3(1.0);
    for(int i=0;i<5;i++)
    {
        // kp=mix(kp,kp.yzx,0.1);
        kp+=sin(0.75*kp.zxy * fre+ft*iTime);
        d -= abs(cross(sin(kp), cos(kp.yzx)) * ap);
        fre*=-1.9;
        ap*=0.5;
    }
    return vec3(abs(d-vec3(0.0,1.0,1.0)));
}
float simplex_noise(vec2 p)
{
    const float K1 = 0.366025404; // (sqrt(3)-1)/2;
    const float K2 = 0.211324865; // (3-sqrt(3))/6;
    vec2 i = floor(p + (p.x + p.y) * K1);
    vec2 a = p - (i - (i.x + i.y) * K2);
    vec2 o = (a.x < a.y) ? vec2(0.0, 1.0) : vec2(1.0, 0.0);
    vec2 b = a - o + K2;
    vec2 c = a - 1.0 + 2.0 * K2;
    vec3 h = max(0.5 - vec3(dot(a, a), dot(b, b), dot(c, c)), 0.0);
    vec3 n = h * h * h * h * vec3(dot(a, hash22(i)), dot(b, hash22(i + o)), dot(c, hash22(i + 1.0)));

    return dot(vec3(70.0, 70.0, 70.0), n);
}
float fbm(vec2 p)
{
    float res=0.0;
    float fre=1.0;
    float ap=1.0;
    for(int i=0;i<5;i++)
    {
       res+=ap*simplex_noise(p*fre);
       fre*=1.5;
       ap*=0.45;
    }
    return res;
}
float lerp(float a, float b, float x)
{
    return clamp((x - a) / (b - a), 0.0, 1.0);
}

vec3 Remap(float r)
{
    vec3 color0 = vec3(0.3,0.1,0.1);
    vec3 color1 = vec3(0.6,0.3,0.3);
    vec3 color2 = vec3(1.0, 0.6, 0.0);
    vec3 color3 = vec3(1.0, 0.3, 0.0);
    float step1 = 0.1;
    float step2 = step1 + 0.2;
    float step3 = step2 + 0.3;
    float f1 = smoothstep(0.0, step1, r);
    float f2 = smoothstep(step1, step2, r);
    float f3 = smoothstep(step2, step3, r);
    float f4 = smoothstep(step3, 1.0, r);

    vec3 res = color0;
    res += (color1 - color0) * f1;
    res += (color2 - color1) * f2;
    res += (color3 - color2) * f3;
    res += -color3 * f4;
    return res;
}
vec3 Draw(vec2 coord)
{
    float time = 5.0 * iTime;

    float r = length(coord);

    float angle = 0.5*atan(coord.y , coord.x)+0.25*PI; //0---0.5PI
    float trace = r * (1.0 - 0.995 * sin(angle)) * 230.0;

    vec2 c1 = coord * 10.0 + vec2(0.0, -time);
    trace += 0.1 * smoothstep(0.05, 0.2, coord.y) * fbm(c1);

    vec2 c2 = coord * 5.0 + vec2(0.0, 0.5*-time);
    float f5 = 1.0 + 0.7 * fbm(c2);

    return Remap(trace) * f5 * smoothstep(-0.05, 0.3, coord.y);
}

void mainImage(out vec4 fragColor,in vec2 fragCoord)
{
    vec2 uv=fragCoord/iResolution.xy;

    vec2 coord = uv - vec2(0.5, 0.1);
    coord.x*=iResolution.x/iResolution.y;
    

    fragColor=vec4(Draw(coord),1.0);
}