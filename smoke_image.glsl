// #ixChannel0 "file://./Smoke/bufA.glsl"
#iChannel0 "file://./smoke_bufA.glsl"
#iChannel1 "self"

vec3 norm_fract(vec3 x)
{
    vec3 p=fract(x);
    return 8.0*p*(1.0-p)-1.0;
}
vec3 fbm_noise(vec2 coord,float ft)
{
    float len=length(coord);
    vec3 kp=vec3(coord,len+1.0);
    float fre=1.0;
    float ap=1.0;
    vec3 d=vec3(1.0);
    for(int i=0;i<5;i++)
    {
        kp=mix(kp,kp.yzx,0.1);
        kp+=sin(0.75*kp.zxy * fre+ft*iTime);
        d -= abs(cross(norm_fract(kp), norm_fract(kp.yzx)) * ap);
        fre*=-2.0;
        ap*=0.5;
    }
    return vec3((d));
}

#define c_p 0.3
vec4 DrawEmit0_c(vec2 coord)
{

    vec2 target=coord-vec2(-0.0-0.5*cos(0.3*iTime),0.5*sin(0.3*iTime));
    vec4 color=c_p*vec4(0.0,1.0,0.0,0.0);
    float m2=dot(target,target);
    float power=smoothstep(0.001,0.0,m2);
    return color*power;
}
vec4 DrawEmit1_c(vec2 coord)
{

    vec2 target=coord-vec2(0.0+0.5*cos(0.3*iTime),-0.5*sin(0.3*iTime));
    vec4 color=c_p*vec4(1.0,0.0,0.0,0.0);
    float m2=dot(target,target);
    float power=smoothstep(0.001,0.0,m2);
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
    vec2 t_uv=uv - dt*vel*w*3.;
    // t_uv+=0.0003*fbm_noise(uv,0.3).xy;
    color+= BlurSampler(iChannel1,t_uv , w)*k; //advection

    color=clamp(color,vec4(0.0),vec4(1.0));
    fragColor=vec4(color.xyz,1.0);
}

