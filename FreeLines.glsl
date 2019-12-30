#iChannel0 "self"

#define PI 3.141592654

#define P_NUMS 20U
#define Radius 0.005
float RadicalInverse(uint Base, uint i)
{
    float Digit, Radical, Inverse;
    Digit = Radical = 1.0 / float(Base);
    Inverse = 0.0;
    while (i > 0U) {
        Inverse += Digit * float(i % Base);
        Digit *= Radical;

        i /= Base;
    }
    return Inverse;
}
vec2 GetPoint(uint i)
{
    float a = RadicalInverse(3U, i) * 2.0 * PI;
    float b = RadicalInverse(5U, i);
    return vec2(b * sin(a), b * cos(a));
}

vec3 DrawLine(vec2 pos0,vec2 pos1,vec2 coord)
{
    vec3 color=abs(sin(vec3(1.0,pos0))+cos(0.7+2.0*vec3(pos1.x,1.0,pos1.y)));
    float d0=distance(pos0,pos1);
    float d1=distance(pos0,coord);
    float d2=distance(pos1,coord);
    float f=d1+d2-d0;

    return color*smoothstep(Radius,0.0,f);
}
vec2 NoisePos(vec2 inPos, float fre, float bias)
{
    inPos*=2.0*PI;
    float p = (iTime-bias) * fre*1.0;
    float f0 = sin(p + inPos.x) *  PI;
    float f1 = cos(p + inPos.y) *  PI;
    float f3 = sin(p*0.7 + f1*inPos.x + f0 * inPos.y) *  PI;
    float f4 = 0.7*cos(p*0.7 + f0*inPos.y - f1 * inPos.x);
    return vec2(f4 * sin(f3), f4 * cos(f3));
}
vec3 track(vec2 inPos, vec2 coord)
{
    vec3 color = vec3(0.0);
    float fre=0.08;
    vec2  pos0 = NoisePos(inPos, fre, 0.0);
    vec2  pos1 = NoisePos(inPos, fre, 0.05);
    color += DrawLine(pos0,pos1,coord);
    return color;
}
vec4 BlurSampler(sampler2D tex,vec2 uv,vec2 w)
{
    vec4 color=texture(tex,uv+vec2(0.0,w.y));
    color+=texture(tex,uv-vec2(0.0,w.y));
    color+=texture(tex,uv+vec2(w.x,0.0));
    color+=texture(tex,uv-vec2(w.x,0.0));
    return 0.25*color;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord){

    vec2 uv = fragCoord.xy / iResolution.xy;
    float f = iResolution.x / iResolution.y;
    vec2 coord = uv * 2.0 - vec2(1.0);
    coord.x *= f;
    vec3 color = vec3(0.0);

    for (uint i = 0U; i < P_NUMS; i++) {
        vec2 pos = GetPoint(i);
        vec3 tpColor = track(pos, coord);
        float fc = smoothstep(-0.7, 0.7, sin(iTime+PI*float(i)));
        color =max(color,mix(tpColor, tpColor.zxy, fc));
    }
    color =max(color,BlurSampler(iChannel0, uv,1.0/iResolution.xy).xyz * 0.99);
    fragColor = vec4(color, 1.0);
}