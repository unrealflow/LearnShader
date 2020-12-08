

mat3 rot_x(float a)
{
    float sa = sin(a);
    float ca = cos(a);
    return mat3(1., .0, .0, .0, ca, sa, .0, -sa, ca);
}
mat3 rot_y(float a)
{
    float sa = sin(a);
    float ca = cos(a);
    return mat3(ca, .0, sa, .0, 1., .0, -sa, .0, ca);
}
mat3 rot_z(float a)
{
    float sa = sin(a);
    float ca = cos(a);
    return mat3(ca, sa, .0, -sa, ca, .0, .0, .0, 1.);
}
mat2 rot(in float a)
{
    float c = cos(a), s = sin(a);
    return mat2(c, s, -s, c);
}
const float fov = 1.5;

const mat3 m3 = mat3(0.33338, 0.56034, -0.71817, -0.87887, 0.32651, -0.15323, 0.15162, 0.69596, 0.61339) * 1.93;
float mag2(vec2 p) { return dot(p, p); }
float mag2(vec3 p) { return dot(p, p); }

float linstep(in float mn, in float mx, in float x) { return clamp((x - mn) / (mx - mn), 0., 1.); }
vec2 disp(float t) { return vec2(sin(t * 0.22) * 1., cos(t * 0.175) * 1.) * 2.; }
float prm1 = -0.0;
vec2 bsMo = vec2(0);

float colVar = 0.;
float shapeVar = 0.;

float mg2(vec2 p) { return dot(p, p); }
float sin_1(float x)
{
    return 1.1*(sin(x));
}
vec2 map2(vec3 p)
{
    // p*=0.5;
    float t1=sin(p.x);
    t1=0.5*(t1+1.0);
    t1=t1*t1;
    float t2=sin(p.y+t1*0.4);
    t2=t2*t2;
    float t3=sin(p.z+t1*0.4+t2*0.4);
    t3=0.5*(t3+1.0);
    t3=t3*t3;
    return 2.0*vec2(t1*t2*t3,t1);
}
//p为视线末端坐标
vec2 map(vec3 p)
{
    vec3 p2 = p;
    //偏移矫正
    // p2.xy -= disp(p.z).xy;
    //云的流动效果
    p.xy *= rot(sin(p.z + iTime) * 0.15 + iTime * 0.09);
    //cl代表与中心的的距离的平方
    float cl = mag2(p2.xy);
    float d = 3.;
    p *= .61;
    float z = 1.6;
    float trk = 1.;
    //分形噪声
    for (int i = 0; i < 6; i++)
    {
        //prim1设定颜色对浓度的影响
        p += sin(p.zxy * 0.75 * trk + iTime * trk * .8) * (0.1 + prm1 * 0.2);
        d -= abs(dot(cos(p), sin(p.yzx)) * z);
        //振幅减小
        z *= 0.57;
        //频率增大
        trk *= 1.4;
        p = p * m3;
        // p=p*1.93;
        // p = p * m3;
    }
    return vec2(d + cl * .21 + 0.0, cl);
}
//计算显示颜色，ro为摄像机位置,rd为视线方向
vec4 render(in vec3 ro, in vec3 rd, float time)
{
    vec4 rez = vec4(0);
    const float ldst = 8.;
    //摄像机前方ldst处
    vec3 lpos = vec3(disp(time + ldst) * 0.5, time + ldst);
    float t = 1.5;
    float fogT = 0.;
    //添加不同深度的颜色
    for (int i = 0; i < 40; i++)
    {
        if (rez.a > 0.9)
            break;
        //当前视线末端坐标
        vec3 pos = ro + t * rd;
        //当前视线位置对应的云朵密度和与中心的距离
        vec2 mpv = map(pos);
        float den = clamp(mpv.x - 0.3, 0., 1.) * 1.12;
        float dn = clamp((mpv.x + 2.), 0., 3.);

        vec4 col = vec4(0);
        // //云雾基础颜色
        if (mpv.x > 0.3)
        {

            col = vec4(sin(vec3(5., 0.4, 0.2) + mpv.y * 0.1 + sin(pos.z * 0.4) * 0.5 + 1.8) * 0.5 + 0.5, 0.08);
            col *= den * den * den;
            col.rgb *= linstep(4., -2.5, mpv.x) * 2.3;
            float dif = clamp((den - map(pos + .8).x) / 9., 0.001, 1.);
            dif += clamp((den - map(pos + .35).x) / 2.5, 0.001, 1.);
            // dif=1.0;
            col.xyz *= den * (vec3(0.005, .045, .075) + 1.5 * vec3(0.033, 0.07, 0.03) * dif);
        }
        // //深度指数雾
        float fogC = exp(t * 0.2 - 2.2);
        col.rgba += vec4(0.06, 0.11, 0.11, 0.5) * clamp(fogC - fogT, 0., 1.);
        fogT = fogC;
        // //根据alpha通道混合颜色
        rez = rez + col * (1. - rez.a);
        t += clamp(0.5 - dn * dn * .05, 0.09, 0.3);
    }
    return clamp(rez, 0.0, 1.0);
}


void mainImage(out vec4 fragColor, in vec2 fragCoord)
{

    vec2 uv = fragCoord.xy / iResolution.xy;
    vec2 coord = uv * 2.0 - 1.0;
    coord.x *= iResolution.x / iResolution.y;
    vec3 origin=vec3(0.0,0.0,0.4*iTime);
    vec3 dir=vec3(coord,1.0);
    vec3 color = render(origin,dir,iTime*1.3).xyz;

    fragColor = vec4(color, 1.0);
}