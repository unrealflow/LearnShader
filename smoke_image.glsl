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

float fract2(float x)
{
    float k=fract(x/3.1415926);

    return 2.0*abs(2.0*k-1.0)-1.0;
}
#define c_p 0.05
vec4 DrawEmit0(vec2 coord)
{
    vec2 target=coord-vec2(-0.0-0.5*fract2(0.1*iTime),-1.0);
    vec4 color=c_p*vec4(-0.5,1.0,0.0,0.0);
    float m2=dot(target,target);
    return color*smoothstep(0.001,0.0,m2);
}
vec4 DrawEmit1(vec2 coord)
{
    vec2 target=coord-vec2(0.0+0.5*fract2(0.1*iTime),-1.0);
    vec4 color=c_p*vec4(1.0,-0.5,0.0,0.0);
    float m2=dot(target,target);
    return color*smoothstep(0.001,0.0,m2);
}
void mainImage(out vec4 fragColor,in vec2 fragCoord)
{
    const float dt=0.14;
    vec2 w=1.0/iResolution.xy;
    vec2 uv=fragCoord/iResolution.xy;
    vec2 coord=uv*2.0-1.0;
    coord.x*=iResolution.x/iResolution.y;

    vec4 data=texture(iChannel0,uv);
    
    vec2 vel=data.xy;
    // fragColor=vec4(t0.z);
    vec4 color=DrawEmit0(coord);
    color+=DrawEmit1(coord);
    vec2 t_uv=uv - dt*vel*w*3.;
    t_uv+=0.0003*fbm_noise(uv,0.3).xy;
    color+= textureLod(iChannel1,t_uv , 0.)*0.999; //advection

    vec4 tu=texture(iChannel1,t_uv+vec2(0.0,w.y));
    vec4 td=texture(iChannel1,t_uv-vec2(0.0,w.y));
    vec4 tl=texture(iChannel1,t_uv-vec2(w.x,0.0));
    vec4 tr=texture(iChannel1,t_uv+vec2(w.x,0.0));
    color=0.2*(color+tl+tr+tu+td);
    color=max(vec4(0.0),color);
    fragColor=vec4(color.xyz,1.0);
}

