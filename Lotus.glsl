#iChannel0 "self"

#define PI 3.141592654
#define P_NUM 2U
vec3 draw_center(vec2 coord)
{
    float l = length(coord);
    float i_l = smoothstep(max(0.0, 0.01), 0.0, l);
    vec3 baseColor = vec3(0.9, 0.3, 0.3);
    baseColor=mix(baseColor,baseColor.zxy,smoothstep(-1.0,1.0,sin(iTime)));
    baseColor*=i_l * i_l;
    return baseColor;
}
float RadicalInverse(uint Base, uint i)
{
    float Digit, Radical, Inverse;
    Digit = Radical = 1.0 / float(Base);
    Inverse = 0.0;
    while (i>0U) {
        // i余Base求出i在"Base"进制下的最低位的数
        // 乘以Digit将这个数镜像到小数点右边
        Inverse += Digit * float(i % Base);
        Digit *= Radical;

        // i除以Base即可求右一位的数
        i /= Base;
    }
    return Inverse;
}
vec3 noise(vec2 uv)
{
    // float pTime = floor(2.0*iTime);
    float pTime = iTime;
    float n_1 = sin(uv.x + pTime) * 20.*PI;
    float n_2 = sin(n_1 + uv.y + pTime) * 20.*PI;
    float n_3 = sin(n_1*uv.x+n_2*uv.y+n_2+n_1)*20.*PI;
    float n_4 = sin(n_2*uv.x+n_3*uv.y+n_2+n_3)*20.*PI;
    return vec3(sin(n_4), cos(n_4),sin(n_3+n_4));
}
vec3 draw_line(vec2 uv, vec2 coord)
{
    float r=sign(coord.x)*atan(coord.y/coord.x);
    float dis=length(coord);
    float mag= pow(max(1.0*sin((r-dis*PI*2.0)*30.0),0.0),3.0);
    vec3 noi=noise(coord);
    vec2 dir=normalize(coord)*mag+(1.-mag)*noi.xz;
    
    vec3 baseColor=vec3(0.);
    if(dis>0.004)
    {
        float stride=0.002;
        baseColor+=texture2D(iChannel0,uv-stride*dir).xyz;
        // baseColor+=texture2D(iChannel0,uv-(stride+0.0001*noi.xy)*dir).xyz;
        // baseColor+=texture2D(iChannel0,uv-(stride-0.0001*noi.xy)*dir).xyz;
        // baseColor/=3.;
        baseColor*=0.995;
    }
    return baseColor;
}

void main()
{

    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    float f = iResolution.x / iResolution.y;
    vec2 coord = uv - vec2(0.5);
    coord.x *= f;
    vec3 color1 = draw_center(coord);
    vec3 color2 = draw_line(uv, coord);

    vec3 t_color = color1 + color2;
    // t_color=texture2D(iChannel0,uv).xyz;
    vec3 preColor = texture2D(iChannel0, uv).xyz;
    t_color=mix(t_color,preColor.yxz,0.01);
    gl_FragColor = vec4(t_color, 1.0);
}