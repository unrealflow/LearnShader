#iChannel0 "self"

float fract2(float x)
{
    float k=fract(x/3.1415926);

    return 2.0*abs(2.0*k-1.0)-1.0;
}
const float dt=0.5;
//data (x,y):velocity (z):density
vec4 DrawEmit0(vec2 coord,float iTime)
{
    vec2 pos=vec2(-0.0-0.5*cos(0.3*iTime),0.5*sin(0.3*iTime));
    vec2 target=coord-pos;
    vec4 data=-5.0*vec4(pos.y,-pos.x,0.0,0.0);
    float m2=dot(target,target);
    float power=smoothstep(0.001,0.0,m2);
    return data*power;
}
vec4 DrawEmit1(vec2 coord,float iTime)
{
    vec2 pos=vec2(0.0+0.5*cos(0.3*iTime),-0.5*sin(0.3*iTime));
    vec2 target=coord-pos;
    vec4 data=-5.0*vec4(pos.y,-pos.x,0.0,0.0);
    float m2=dot(target,target);
    float power=smoothstep(0.001,0.0,m2);
    return data*power;
}
vec4 Solver(sampler2D smp, vec2 uv, vec2 w, float time)
{
    const float K = 0.2;
	// const float v = 0.55;
    vec4 data = textureLod(smp, uv, 0.0)*0.998;
    vec4 tr = textureLod(smp, uv + vec2(w.x , 0), 0.0);
    vec4 tl = textureLod(smp, uv - vec2(w.x , 0), 0.0);
    vec4 tu = textureLod(smp, uv + vec2(0 , w.y), 0.0);
    vec4 td = textureLod(smp, uv - vec2(0 , w.y), 0.0);
    vec3 dx=(tr-tl).xyz*0.5;
    vec3 dy=(tu-td).xyz*0.5;
    vec2 densDif=vec2(dx.z,dy.z);
    data.z -= dt*dot(vec3(densDif, dx.x + dy.y) ,data.xyz); //density
    vec2 laplacian = tu.xy + td.xy + tr.xy + tl.xy - 4.0*data.xy;

    data.xy-=K*densDif; //update velocity
    
    return data;
}

void mainImage(out vec4 fragColor,in vec2 fragCoord)
{
    
    if (iFrame < 20)
    {
        fragColor = vec4(0.0,0.0,0.5,0);
        return;
    }
    vec2 uv=fragCoord/iResolution.xy;
    float aspect=iResolution.x/iResolution.y;;
    vec2 coord=uv*2.0-1.0;
    coord.x*=aspect;
    vec4 data=Solver(iChannel0,uv,1.0/iResolution.xy,iTime);
    data+=DrawEmit0(coord,iTime);
    data+=DrawEmit1(coord,iTime);

    //data.x *= smoothstep(.5,.48,abs(uv.x-0.5)); //Boundaries
    data = clamp(data, vec4(vec2(-5), 0.01 , -10.), vec4(vec2(5), 3.0 , 10.));
    vec4 preData=texture(iChannel0,uv);
    data.xy=mix(preData.xy,data.xy,0.9);
    fragColor=data;
}