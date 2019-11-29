#iChannel0 "self"


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
vec2 GetTargetPos(uint i)
{
    float x=RadicalInverse(3U,i);
    float y=RadicalInverse(5U,i);
    x=x*(1.0-y)+0.5*y;
    y=0.5+0.5*y;
    return vec2(x,y);
}
vec2 GetCurrentPos(uint i,float time)
{
    time =clamp(time,0.0,1.0);
    // float begin=RadicalInverse(7U,i);
    vec2 center=vec2(0.5,time);
    vec2 pos=GetTargetPos(i);
    time=smoothstep((2.0*(pos.y-0.5)+abs(pos.x-0.5))*0.5,1.0,time);
    pos=mix(center,pos,time);
    return pos;
}

vec3 DrawTrace(vec2 uv,uint i,float time)
{
    float fi=float(i);
    vec3 color=abs(vec3(sin(fi),cos(0.7+2.0*fi),cos(2.7+3.0*fi)));
    vec2 pos0=GetCurrentPos(i,time+0.0);
    vec2 pos1=GetCurrentPos(i,time-0.01);
    float d=distance(uv,pos0);
    d+=distance(uv,pos1);
    d-=distance(pos0,pos1);
    float k=smoothstep(0.001,0.0,d);
    return k*color;
}
vec4 BlurSampler(sampler2D tex,vec2 uv,vec2 w)
{
    vec4 color=texture(tex,uv+vec2(0.0,w.y));
    color+=texture(tex,uv-vec2(0.0,w.y));
    color+=texture(tex,uv+vec2(w.x,0.0));
    color+=texture(tex,uv-vec2(w.x,0.0));
    return 0.25*color;
}
void mainImage(out vec4 fragColor,in vec2 fragCoord)
{
    vec2 uv=fragCoord/iResolution.xy;

    // vec2 coord=uv*2.0-1.0;
    // coord.x*=iResolution.x/iResolution.y;

    float time=fract(iTime/20.0);
    vec3 color=BlurSampler(iChannel0,uv,1.0/iResolution.xy).xyz*0.999;
    for(uint i=0U;i<100U;i++)
    {
        color=max(color,DrawTrace(uv,i,time));
    }
    fragColor=vec4(color,1.0);
}