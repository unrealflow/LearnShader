// #iCxhannel0 "file://./Smoke/bufA.glsl"
#include "./smoke_common.glsl"
#iChannel0 "file://./smoke_bufB.glsl"
#iChannel1 "self"

#define c_p 1.0
vec4 DrawEmit0_c(vec2 coord)
{

    vec2 target=coord-vec2(-0.0-RADIUS*cos(0.3*iTime),RADIUS*sin(0.3*iTime));
    vec4 color=c_p*vec4(0.3,1.0,0.3,0.0);
    float m2=dot(target,target);
    float power=smoothstep(RSIZE,0.0,m2);
    return color*power;
}
vec4 DrawEmit1_c(vec2 coord)
{

    vec2 target=coord-vec2(0.0+RADIUS*cos(0.3*iTime),-RADIUS*sin(0.3*iTime));
    vec4 color=c_p*vec4(1.0,0.3,0.3,0.0);
    float m2=dot(target,target);
    float power=smoothstep(RSIZE,0.0,m2);
    return color*power;
}
vec4 DrawEmit2_c(vec2 coord)
{

    vec2 target=coord-vec2(0.0);
    vec4 color=c_p*vec4(0.3,0.3,1.0,0.0);
    float m2=dot(target,target);
    float power=smoothstep(0.1*RADIUS,0.0,m2);
    return color*power;
}

void mainImage(out vec4 fragColor,in vec2 fragCoord)
{
    const float k=0.599;
    // if (iFrame < 20)
    // {
    //     fragColor = vec4(0.00);
    //     return;
    // }


    const float dt=0.14;
    vec2 w=1.0/iResolution.xy;
    vec2 uv=fragCoord/iResolution.xy;
    vec2 coord=uv*2.0-1.0;
    coord.x*=iResolution.x/iResolution.y;

    vec4 data=texture(iChannel0,uv);
    
    vec2 vel=data.xy;
    // fragColor=vec4(t0.z);
    // vec4 color=vec4(0.0001);
    vec4 color=BlurSampler(iChannel1,uv,w)*(0.999-k);
    color=max(color,DrawEmit0_c(coord));
    color=max(color,DrawEmit1_c(coord));
    color=max(color,DrawEmit2_c(coord));
    vec2 t_uv=uv - vel*w*P;
    // t_uv+=0.0003*fbm_noise(uv,0.3).xy;
    color+= BlurSampler(iChannel1,t_uv , w)*k; //advection
    // color+= texture(iChannel1,t_uv)*k; //advection

    color=clamp(color,vec4(0.0),vec4(1.0));
    fragColor=vec4(color.xyz,1.0);

}



