#define RADIUS 0.3
#define RSIZE 0.001

//梯度差对速度的影响
const float G=0.4;
//速度对浓度的影响
const float K=0.4;
//速度对uv偏移的影响
const float P=0.3;

float fract2(float x)
{
    float k=fract(x/3.1415926);

    return 2.0*abs(2.0*k-1.0)-1.0;
}
const float dt=0.5;
//data (x,y):velocity (z):density
vec4 DrawEmit0(vec2 coord,float iTime)
{
    vec2 pos=vec2(-0.0-RADIUS*cos(0.3*iTime),RADIUS*sin(0.3*iTime));
    vec2 target=coord-pos;
    vec4 data=5.0*vec4(pos.y,-pos.x,1.0,0.0);
    float m2=dot(target,target);
    float power=smoothstep(RSIZE,0.0,m2);
    return data*power;
}
vec4 DrawEmit1(vec2 coord,float iTime)
{
    vec2 pos=vec2(0.0+RADIUS*cos(0.3*iTime),-RADIUS*sin(0.3*iTime));
    vec2 target=coord-pos;
    vec4 data=5.0*vec4(pos.y,-pos.x,1.0,0.0);
    float m2=dot(target,target);
    float power=smoothstep(RSIZE,0.0,m2);
    return data*power;
}
vec4 Solver(sampler2D smp, vec2 uv, vec2 w, float time)
{

    vec4 data = textureLod(smp, uv, 0.0)*0.998;
    vec4 tr = textureLod(smp, uv + vec2(w.x , 0), 0.0);
    vec4 tl = textureLod(smp, uv - vec2(w.x , 0), 0.0);
    vec4 tu = textureLod(smp, uv + vec2(0 , w.y), 0.0);
    vec4 td = textureLod(smp, uv - vec2(0 , w.y), 0.0);
    vec3 dx=(tr-tl).xyz*G;
    vec3 dy=(tu-td).xyz*G;
    data.z+=K*(dx.x+dy.y);
    vec2 t_uv=uv+data.xy*w*P;
    vec2 preVel=texture(smp,t_uv).xy;
    data.xy=preVel*0.999+G*vec2(dx.z,dy.z);
    
    return data;
}
vec4 render(sampler2D iChannel0,vec2 uv,vec2 coord,vec2 w,float iTime)
{
     vec4 data=Solver(iChannel0,uv,w,iTime);
    data+=DrawEmit0(coord,iTime);
    data+=DrawEmit1(coord,iTime);

    data.x *= smoothstep(.5,.48,abs(uv.x-0.5)); //Boundaries
    data.y *= smoothstep(.5,.48,abs(uv.y-0.5)); //Boundaries
    
    data.z*=smoothstep(0.5,0.48-w.y,abs(uv.y-0.5));
    // data*=smoothstep(0.5,0.5-0.3*w.y,abs(uv.x-0.5));
    data = clamp(data, vec4(vec2(-5), 0.01 , -10.), vec4(vec2(5), 3.0 , 10.));
    vec4 preData=texture(iChannel0,uv);
    data.xy=mix(preData.xy,data.xy,0.9);
    return data;
}
