#iChannel0 "self"
#iChannel1 "file://./tree_point.glsl"
#include "./tree_common.glsl"


float SDF_line(vec2 P,vec2 O,vec2 D)
{
    vec2 OP=P-O;
    vec2 OH=dot(OP,D)*D;
    vec2 HP=OP-OH;
    return length(HP);
}

void mainImage(out vec4 fragColor,in vec2 fragCoord)
{
    vec2 uv=fragCoord/iResolution.xy;
    vec2 loc=uv-vec2(0.5,0.0);
    loc.x*=iResolution.x/iResolution.y;

    float kt=iTime*0.8*time_rate;
    kt=mod(kt,time_rate+pow(2.0,1.0+ceil(log(stop_thre)/log(atten))));

    if(kt<time_begin)
    {
        fragColor=vec4(vec3(0.0),1.0);
        return;
    }
    kt-=time_begin;
    vec4 preColor=texture(iChannel0,uv);

    uint drawIndex = uint(kt);
    float progress=fract(kt);
    progress=smoothstep(0.0,0.4,progress);

    vec4 data=texture(iChannel1,GetUV(drawIndex,iResolution.xy));
    vec4 rootData=texture(iChannel1,GetUV(drawIndex/branch,iResolution.xy));

    vec2 dir=data.zw;
    vec2 root=rootData.xy;
    vec2 target=data.xy+dir*0.01;

    target=mix(root,target,progress);
    float len=distance(target,root);


    vec3 f=vec3(0.0);

    float p=length(dir);

    if(p>stop_thre)
    {   
        float d0=distance(loc,root)+distance(loc,target)-len;
        float d1=SDF_line(loc,root,normalize(dir));
        f=vec3(0.7,0.4,0.35)*smoothstep(0.005,-0.00,max(d1,d0));
    }else if(p>atten*stop_thre)
    {
        float kfm=0.8;
        float d0=distance(loc,root)+kfm*distance(loc,target);
        f=vec3(0.557,1.0,0.514)*smoothstep(kfm+leaf_size,kfm,d0/len);
    }
    
    // float f=smoothstep(0.01,-0.00,distance(uv,target));

    fragColor=max(preColor,vec4(vec3(f),1.0));
}