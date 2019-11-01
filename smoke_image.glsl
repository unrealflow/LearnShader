// #iCxhannel0 "file://./Smoke/bufA.glsl"
#include "./smoke_common.glsl"
#iChannel0 "file://./smoke_blur.glsl"
#iChannel1 "self"

#define c_p 0.1
vec4 DrawEmit0_c(vec2 coord)
{

    vec2 target=coord-vec2(-0.0-RADIUS*cos(0.3*iTime),RADIUS*sin(0.3*iTime));
    vec4 color=c_p*vec4(0.0,1.0,0.0,0.0);
    float m2=dot(target,target);
    float power=smoothstep(RSIZE,0.0,m2);
    return color*power;
}
vec4 DrawEmit1_c(vec2 coord)
{

    vec2 target=coord-vec2(0.0+RADIUS*cos(0.3*iTime),-RADIUS*sin(0.3*iTime));
    vec4 color=c_p*vec4(1.0,0.0,0.0,0.0);
    float m2=dot(target,target);
    float power=smoothstep(RSIZE,0.0,m2);
    return color*power;
}
vec4 BlurSampler(sampler2D tex,vec2 uv,vec2 w)
{
    vec4 tc=texture(tex,uv);
    vec4 tu=texture(tex,uv+vec2(0.0,w.y));
    vec4 td=texture(tex,uv-vec2(0.0,w.y));
    vec4 tl=texture(tex,uv-vec2(w.x,0.0));
    vec4 tr=texture(tex,uv+vec2(w.x,0.0));
    vec4 tul=texture(tex,uv+vec2(-w.x,w.y));
    vec4 tdl=texture(tex,uv-vec2(-w.x,w.y));
    vec4 tdr=texture(tex,uv-vec2(w.x,w.y));
    vec4 tur=texture(tex,uv+vec2(w.x,w.y));
    return 0.36*tc+0.12*(tu+td+tl+tr)+0.04*(tul+tur+tdl+tdr);
}
void mainImage(out vec4 fragColor,in vec2 fragCoord)
{
    const float k=0.998;
    if (iFrame < 20)
    {
        fragColor = vec4(0.0001/(1.0-k));
        return;
    }


    const float dt=0.14;
    vec2 w=1.0/iResolution.xy;
    vec2 uv=fragCoord/iResolution.xy;
    vec2 coord=uv*2.0-1.0;
    coord.x*=iResolution.x/iResolution.y;

    vec4 data=texture(iChannel0,uv);
    
    vec2 vel=data.xy;
    // fragColor=vec4(t0.z);
    vec4 color=vec4(0.0001);
    color+=DrawEmit0_c(coord);
    color+=DrawEmit1_c(coord);
    vec2 t_uv=uv + vel*w*P;
    // t_uv+=0.0003*fbm_noise(uv,0.3).xy;
    color+= BlurSampler(iChannel1,t_uv , w)*k; //advection
    // color+= texture(iChannel1,t_uv)*k; //advection

    color=clamp(color,vec4(0.0),vec4(1.0));
    fragColor=vec4(color.xyz,1.0);

}



