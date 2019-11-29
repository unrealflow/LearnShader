#define PI 3.141592654

vec2 hash22(vec2 p)
{
    p = vec2(dot(p, vec2(127.1, 311.7)),
        dot(p, vec2(269.5, 183.3)));

    return -1.0 + 2.0 * fract(sin(p) * 43758.5453123);
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
       res+=ap*simplex_noise(p*fre+1.33*fre);
       fre*=1.5;
       ap*=0.45;
    }
    return res;
}


vec3 Draw(vec2 coord)
{
    float res=1.0;
    float fre=1.0;
    float ap=0.7;
    for(int i=0;i<5;i++)
    {
        res*=1.2-ap+ap*fbm(coord*fre+fre*133.3333);
        fre*=2.0;
        ap*=0.6;
    }
    return vec3(1.0)*res;
}


void mainImage(out vec4 fragColor,in vec2 fragCoord)
{
    vec2 uv=fragCoord/iResolution.xy;

    vec2 coord=uv*2.0-1.0;
    coord.x*=iResolution.x/iResolution.y;
    vec3 res=Draw(coord);
    fragColor=vec4(res,1.0);
}