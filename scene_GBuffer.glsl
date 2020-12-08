#include "BRDF.glsl"
#iChannel0 "self"

float SdfPlane(vec3 pos)
{
    return pos.y+1.0;
}
float SdfSphere(vec3 pos)
{
    vec3 center=vec3(0.0,0.0,2.0);
    float d=distance(pos,center);
    return d-0.2;
}

vec3 RayMarch(vec3 pos,vec3 dir,int index)
{
    float farDis=1000.0;
    float track=0.0;
    float stride=1.0;
    for(;track<farDis;track+=stride)
    {
        float d=SdfPlane(pos);

        if(abs(d)<1e-3)
        {
            return pos;
        }
        float k=SdfSphere(pos);
        float k2=SdfSphere(pos+dir*stride*0.5);
        k=abs(k)<abs(k2)?k:k2;
        if(abs(k)<1e-3)
        {
            return pos;
        }
        d=abs(d)<abs(k)?d:k;
        d*=(0.5+0.5*fract(D_y[index]+noise11(track+pos.x+pos.y+pos.z)));
        pos+=dir*d;
        stride=abs(d);
        if(pos.z>farDis)
        {
            break;
        }
    }
    return vec3(pos.xy,farDis);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{

    // vec3 lightPos=vec3(1.0,0.0,2.0);
    
    vec2 uv = fragCoord.xy / iResolution.xy;
    vec2 coord = uv * 2.0 - 1.0;
    coord.x *= iResolution.x / iResolution.y;

    vec3 origin=vec3(coord,0.0);
    int index=iFrame%16;
    // vec2 bias=vec2(D_x[index],D_y[index])*2.0-1.0;
    // vec3 dir=normalize(vec3(coord+bias/iResolution.xy,1.0));
    vec3 dir=normalize(vec3(coord,1.0));
    vec3 pos = RayMarch(origin,dir,index);

    fragColor=vec4(pos,0.0);
    vec4 preColor=texture(iChannel0,uv);
    float fp=preColor.w+(1.0-preColor.w)*0.05;
    fp=min(0.98,fp);
    fragColor=mix(fragColor,preColor,fp);
    fragColor.w=fp;
}