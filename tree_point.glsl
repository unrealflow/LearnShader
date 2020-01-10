#iChannel0 "self"
#include "./tree_common.glsl"

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

vec2 Rot(vec2 v, float angle)
{
    return vec2(v.x * cos(angle) + v.y * sin(angle),
        v.y * cos(angle) - v.x * sin(angle));
}

void mainImage(out vec4 fragColor,in vec2 fragCoord)
{
    vec2 uv=fragCoord/iResolution.xy;
   
    float kt=iTime*time_rate;
    if(kt<time_begin)
    {
        fragColor=vec4(0.0);
        return;
    }
    kt-=time_begin;

    vec4 preData=texture(iChannel0,uv);
    if(preData.y>0.0)
    {
        fragColor=preData;
        return;
    }

    uint drawIndex = uint(kt);
    uint locIndex=GetIndex(fragCoord,iResolution.xy);
    if(drawIndex!=locIndex)
    {
        fragColor=preData;
        return;
    }
    else if(drawIndex<1U)
    {
        fragColor=vec4(0.0,0.0,0.0,1.0);
        return;
    }
    else if(drawIndex<branch)
    {
        fragColor=vec4(0.0,0.3-0.15*float(drawIndex)/float(branch),0.0,1.0);
        return;
    }
    uint rootIndex=drawIndex/branch;
    vec4 rootData=texture(iChannel0,GetUV(rootIndex,iResolution.xy));

    float rd0=RadicalInverse(2U,drawIndex)*2.0-1.0;//[-1,1]
    float rd1=RadicalInverse(3U,drawIndex)*0.6+0.4;//[-1,1]

    vec2 dir=rootData.zw;
    dir=atten*Rot(dir,0.15*PI*rd0);

    vec2 pos=rootData.xy+dir*0.25*rd1;
    

    fragColor=vec4(pos,dir);
    // fragColor=vec4(1.0);
}