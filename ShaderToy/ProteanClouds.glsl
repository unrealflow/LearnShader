// Protean clouds by nimitz (twitter: @stormoid)
// https://www.shadertoy.com/view/3l23Rh
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License
// Contact the author for other licensing options

/*
	Technical details:

	The main volume noise is generated from a deformed periodic grid, which can produce
	a large range of noise-like patterns at very cheap evalutation cost. Allowing for multiple
	fetches of volume gradient computation for improved lighting.

	To further accelerate marching, since the volume is smooth, more than half the the density
	information isn't used to rendering or shading but only as an underlying volume	distance to 
	determine dynamic step size, by carefully selecting an equation	(polynomial for speed) to 
	step as a function of overall density (not necessarialy rendered) the visual results can be 
	the	same as a naive implementation with ~40% increase in rendering performance.

	Since the dynamic marching step size is even less uniform due to steps not being rendered at all
	the fog is evaluated as the difference of the fog integral at each rendered step.

*/

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
float prm1 = 0.;
vec2 bsMo = vec2(0);

float colVar = 0.;
float shapeVar = 0.;

float mg2(vec2 p) { return dot(p, p); }

//p为视线末端坐标
vec2 map(vec3 p)
{
    vec3 p2 = p;
    //偏移矫正
    p2.xy -= disp(p.z).xy;
    //云的流动效果
    p.xy *= rot(sin(p.z + iTime) * 0.15 + iTime * 0.09);
    //cl代表与中心的的距离的平方
    float cl = mag2(p2.xy);
    float d = 0.;
    p *= .61;
    float z = 1.;
    float trk = 1.;
    //分形噪声
    for (int i = 0; i < 5; i++)
    {
        //prim1设定颜色对浓度的影响
        p += sin(p.zxy * 0.75 * trk + iTime * trk * .8) * (0.1 + prm1 * 0.2);
        d -= abs(dot(cos(p), sin(p.yzx)) * z);
        //振幅减小
        z *= 0.57;
        //频率增大
        trk *= 1.4;
        p = p * m3;
    }
    d = abs(d + prm1 * 3.) + prm1 * .3 - 2.5 + bsMo.y;
    return vec2(d + cl * .2 + 0.25, cl);
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
        //云雾基础颜色
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
        //深度指数雾
        float fogC = exp(t * 0.2 - 2.2);
        col.rgba += vec4(0.06, 0.11, 0.11, 0.5) * clamp(fogC - fogT, 0., 1.);
        fogT = fogC;
        //根据alpha通道混合颜色
        rez = rez + col * (1. - rez.a);
        t += clamp(0.5 - dn * dn * .05, 0.09, 0.3);
    }
    return clamp(rez, 0.0, 1.0);
}

float getsat(vec3 c)
{
    float mi = min(min(c.x, c.y), c.z);
    float ma = max(max(c.x, c.y), c.z);
    return (ma - mi) / (ma + 1e-7);
}

vec3 iLerp(in vec3 a, in vec3 b, in float x)
{
    vec3 ic = mix(a, b, x) + vec3(1e-6, 0., 0.);
    float sd = abs(getsat(ic) - mix(getsat(a), getsat(b), x));
    vec3 dir = normalize(vec3(2. * ic.x - ic.y - ic.z, 2. * ic.y - ic.x - ic.z, 2. * ic.z - ic.y - ic.x));
    float lgt = dot(vec3(1.0), ic);
    float ff = dot(dir, normalize(ic));
    ic += 1.5 * dir * sd * ff * lgt;
    return clamp(ic, 0., 1.);
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{	
	vec2 q = fragCoord.xy/iResolution.xy;
    vec2 p = q - 0.5;
	p.x *= iResolution.x/iResolution.y;
    vec2 mous = iMouse.xy/iResolution.xy;
    //mo代表漩涡中心，须排除初始位置，以窗口中心为(0,0)为标
	vec2 mo = mous - 0.5;
    bsMo = mo;
    mo = (mo==vec2(-0.5))?mo=vec2(0.12, 0.15):mo;
	mo.x *= iResolution.x/iResolution.y;
    mo*= 4.14;
	mo.y = clamp(mo.y*0.6-.5,-4. ,.15 );
    
    float time = iTime*3.;
    //ro代表摄像机在空间中前进的位置，z为前进距离，xy为侧向偏移
    vec3 ro = vec3(0,0,time);
    
    //镜头晃动
    ro += vec3(sin(iTime)*0.5,sin(iTime*1.)*0.,0);
        
    float dspAmp = .85;
     //镜头方向偏移
    ro.xy += disp(ro.z)*dspAmp;
    float tgtDst = 3.5;
    
    //计算摄像机朝向
    vec3 target = normalize(ro - vec3(disp(time + tgtDst)*dspAmp, time + tgtDst));
    //鼠标的x值控制镜头
    ro.x -= bsMo.x*2.;
    //计算正交向量，右向，上向
    vec3 rightdir = normalize(cross(target, vec3(0,1,0)));
    vec3 updir = normalize(cross(rightdir, target));
    rightdir = normalize(cross(updir, target));
    //由当前像素的屏幕坐标计算视线方向
	vec3 rd=normalize((p.x*rightdir + p.y*updir)*1. - target);
    //以旋转的方式偏移
    rd.xy *= rot(-disp(time + 3.5).x*0.2 + bsMo.x);
    prm1 = smoothstep(-0.4, 0.4,sin(iTime*0.3));
    //计算显示颜色，ro为摄像机位置,rd为视线方向
	vec4 scn = render(ro, rd, time);
	
    //根据时间插值变幻颜色
    vec3 col = scn.rgb;
    col = iLerp(col.bgr, col.rgb, clamp(1.-prm1,0.05,1.));
    //伽马矫正
    col = pow(col, vec3(.55,0.65,0.6))*vec3(1.,.97,.9);

    col *= pow( 16.0*q.x*q.y*(1.0-q.x)*(1.0-q.y), 0.12)*0.7+0.3; //Vign
    
	fragColor = vec4( col, 1.0 );
}