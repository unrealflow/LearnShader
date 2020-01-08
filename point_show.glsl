#iChannel0 "file://./point.glsl"
#iChannel1 "self"

vec2 GetUV(uint index)
{
    float y=floor(float(index)/iResolution.x);
    float x=float(index)-y*iResolution.x;
    return vec2(x,y)/iResolution.xy;
}

void mainImage(out vec4 fragColor,in vec2 fragCoord)
{
    vec2 uv=fragCoord/iResolution.xy;

    vec2 coord=uv*2.0-1.0;
    coord.x*=iResolution.x/iResolution.y;
    vec2 w=1.0/iResolution.xy;

    vec3 f=vec3(0.0);
    for(uint i=0U;i<500U;i++)
    {
        vec4 data=texture(iChannel0,GetUV(i));
        vec2 pos=data.xy;
        vec2 dir=data.zw;
        vec2 pos2=pos+dir*0.003;
        float fi=float(i);
        vec3 color=abs(vec3(sin(fi),cos(0.7+2.0*fi),cos(2.7+3.0*fi)));
        f=max(f,color*smoothstep(0.01,0.0,distance(uv,pos)+distance(uv,pos2)-0.003*length(dir)));
    }
    vec4 preColor=texture(iChannel1,uv);
    fragColor=mix(preColor,5.0*vec4(vec3(f),1.0),0.03);
}