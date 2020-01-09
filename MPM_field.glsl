#iChannel0 "file://./MPM_particles.glsl"
#define PI 3.141592654

vec2 GetUV(uint index)
{
    float y=floor(float(index)/iResolution.x);
    float x=float(index)-y*iResolution.x;
    return vec2(x,y)/iResolution.xy;
}
float RenderPoint(vec2 coord,vec2 p_pos,vec2 p_dir)
{
    float bias=dot(p_dir,p_dir);    
    p_dir=p_dir/(sqrt(bias)+1e-5);
    // p_dir=normalize(p_dir);
    bias=bias/(bias+0.1);


    vec2 dir=coord-p_pos;
    float len=length(dir);
    dir=dir/(len+1e-5);

    float size=0.1;

    float base=0.99;
    float r=size*(1.0-0.9*bias*bias);

    float theta=acos(dot(p_dir,dir));

    float p=r/(1.0-0.99*bias*theta/PI);
    p=size;
    float k=smoothstep(1.00,0.01,len/p);
    return k*k*k;
}

void mainImage(out vec4 fragColor,in vec2 fragCoord)
{
    vec2 uv=fragCoord/iResolution.xy;

    vec2 coord=uv*2.0-1.0;
    coord.x*=iResolution.x/iResolution.y;
    vec2 w=1.0/iResolution.xy;

    vec4 f=vec4(0.0);
    vec2 preUV=vec2(0.0);
    for(uint i=0U;i<1000U;i++)
    {
        vec4 data=texture(iChannel0,GetUV(i));
        vec2 pos=data.xy;
        vec2 dir=data.zw;
        vec2 pos2=pos+dir*0.003;
        float fi=float(i);
        vec3 color=abs(vec3(sin(fi),cos(0.7+2.0*fi),cos(2.7+3.0*fi)));
        float a=RenderPoint(uv,pos,dir);
        f.xyz=max(f.xyz,color*a);
        f.a+=a;
    }
    fragColor=f;
}