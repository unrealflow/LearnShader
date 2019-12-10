#define RADIUS 0.3
#define RSIZE 0.001

const float PI=3.141592654;
//梯度差对速度的影响
const float G=0.7;
//速度对浓度的影响
const float K=0.4;
//速度对uv偏移的影响
const float P=0.5;

vec2 Rot(vec2 v, float angle)
{
    return vec2(v.x * cos(angle) + v.y * sin(angle),
        v.y * cos(angle) - v.x * sin(angle));
}

float fract2(float x)
{
    float k=fract(x/3.1415926);

    return 2.0*abs(2.0*k-1.0)-1.0;
}
vec4 BlurSampler(sampler2D tex,vec2 uv,vec2 w)
{
    vec4 color=texture(tex,uv+vec2(0.0,w.y));
    color+=texture(tex,uv-vec2(0.0,w.y));
    color+=texture(tex,uv+vec2(w.x,0.0));
    color+=texture(tex,uv-vec2(w.x,0.0));
    return 0.25*color;
}
vec3 Add(vec3 a,vec3 b)
{
    return vec3(a.xy+b.xy,max(a.z,b.z));
}
vec4 Add(vec4 a,vec4 b)
{
    return vec4(a.xy+b.xy,max(a.zw,b.zw));
}
const float dt=0.5;
const float rot_angle=-0.25;
//data (x,y):velocity (z):density
vec4 DrawEmit0(vec2 coord,float iTime)
{
    vec2 pos=vec2(-0.0-RADIUS*cos(0.3*iTime),RADIUS*sin(0.3*iTime));
    vec2 target=coord-pos;
    vec4 data=5.0*vec4(Rot(pos,PI*rot_angle),1.0,0.0);
    float m2=dot(target,target);
    float power=smoothstep(RSIZE,0.0,m2);
    return data*power;
}
vec4 DrawEmit1(vec2 coord,float iTime)
{
    vec2 pos=vec2(0.0+RADIUS*cos(0.3*iTime),-RADIUS*sin(0.3*iTime));
    vec2 target=coord-pos;
    vec4 data=5.0*vec4(Rot(pos,PI*rot_angle),1.0,0.0);
    float m2=dot(target,target);
    float power=smoothstep(RSIZE,0.0,m2);
    return data*power;
}
vec4 Solver(sampler2D smp, vec2 uv, vec2 w, float time)
{

    vec4 data = textureLod(smp, uv, 0.0);
    vec4 tr = textureLod(smp, uv + vec2(w.x , 0), 0.0);
    vec4 tl = textureLod(smp, uv - vec2(w.x , 0), 0.0);
    vec4 tu = textureLod(smp, uv + vec2(0 , w.y), 0.0);
    vec4 td = textureLod(smp, uv - vec2(0 , w.y), 0.0);
    vec3 dx=(tr-tl).xyz*G;
    vec3 dy=(tu-td).xyz*G;
    vec2 densDif=vec2(dx.z,dy.z);
    data.z-=K*dot(vec3(densDif,dx.x+dy.y),data.xyz);
    vec2 laplacian = tu.xy + td.xy + tr.xy + tl.xy - 4.0*data.xy;
    vec2 viscForce = 0.05*laplacian;
    
    vec2 t_uv=uv-data.xy*w*P;
    data.xyw=BlurSampler(smp,t_uv,w).xyw;
    data.xy=data.xy*0.999;
    data.xy+=viscForce-0.1*densDif;
    return data;
}
vec4 render(sampler2D iChannel0,vec2 uv,vec2 coord,vec2 w,float iTime)
{
     vec4 data=Solver(iChannel0,uv,w,iTime);
    data=Add(data, DrawEmit0(coord,iTime));
    data=Add(data, DrawEmit1(coord,iTime));

    data.x *= smoothstep(.5,.48,abs(uv.x-0.5)); //Boundaries
    // data.y *= smoothstep(.5,.48,abs(uv.y-0.5)); //Boundaries
    
    data.z*=smoothstep(0.5,0.48-w.y,abs(uv.y-0.5));
    // data*=smoothstep(0.5,0.5-0.3*w.y,abs(uv.x-0.5));
    data = clamp(data, vec4(vec2(-5), 0.01 , -10.), vec4(vec2(5), 3.0 , 10.));
    vec4 preData=texture(iChannel0,uv);
    data.xy=mix(preData.xy,data.xy,0.9);
    return data;
}
