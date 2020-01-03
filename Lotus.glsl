#iChannel0 "self"

#define PI 3.141592654
#define P_NUM 2U
vec3 draw_center(vec2 coord)
{
    float l = length(coord);
    float i_l = smoothstep(max(0.0, 0.01), 0.0, l);
    vec3 baseColor = vec3(1.0,1.0,0.0);
    baseColor=mix(baseColor,baseColor.zxy,smoothstep(-0.4,0.4,sin(iTime*0.4)));
    baseColor*=i_l * i_l;
    return baseColor;
}
vec3 noise(vec2 uv)
{
    // float pTime = floor(2.0*iTime);
    float fre=20.*PI;
    float pTime = iTime;
    float n_1 = sin(uv.x + pTime) * fre;
    float n_2 = sin(n_1 + uv.y + pTime) * fre;
    float n_3 = sin(n_1*uv.x+n_2*uv.y+n_2+n_1)*fre;
    float n_4 = sin(n_2*uv.x+n_3*uv.y+n_2+n_3)*fre;
    return vec3(sin(n_4), cos(n_4),sin(n_3+n_4));
}
vec3 draw_particles(vec2 uv, vec2 coord)
{
    float r=sign(coord.x)*atan(coord.y/coord.x);
    float dis=length(coord);
    float mag= max(0.0,1.0+coord.y*10.5)*pow(max(1.0*sin((r-dis*PI*2.0)*10.0),0.0),3.0);
    vec3 noi=noise(coord);
    vec2 dir=normalize(coord)*mag+(1.-mag)*noi.xz;
    
    vec3 baseColor=vec3(0.);
    if(dis>0.003)
    {
        float stride=0.006;
        baseColor+=texture(iChannel0,uv-stride*dir).xyz;
        baseColor*=0.9975;
    }
    return baseColor;
}

vec4 BlurSampler(sampler2D tex,vec2 uv,vec2 w)
{
    vec4 color=texture(tex,uv+vec2(0.0,w.y));
    color+=texture(tex,uv-vec2(0.0,w.y));
    color+=texture(tex,uv+vec2(w.x,0.0));
    color+=texture(tex,uv-vec2(w.x,0.0));
    return 0.25*color;
}
void mainImage(out vec4 fragColor, in vec2 fragCoord){

    vec2 uv = fragCoord.xy / iResolution.xy;
    vec2 w=1.0/iResolution.xy;
    float f = iResolution.x / iResolution.y;
    vec2 coord = uv - vec2(0.5,0.3);
    coord.x *= f;
    vec3 color1 = draw_center(coord);
    vec3 color2 = draw_particles(uv, coord);

    vec3 t_color = color1 + color2;
    // t_color=texture(iChannel0,uv).xyz;
    vec3 preColor = BlurSampler(iChannel0, uv,w).xyz;
    t_color=mix(t_color,preColor.xyz,0.3);
    fragColor = vec4(t_color, 1.0);
}