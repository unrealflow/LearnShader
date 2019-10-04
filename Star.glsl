#iChannel0 "self"
#define PI 3.141592654

float noise(float a)
{
    float k = fract(sin(1331.3333 * a + 23.123) * 1331.13333);
    return k;
}

vec3 DrawCenter(float len)
{
    vec3 baseColor =vec3(0.0,0.4,1.0);
    float inten=smoothstep(0.02,0.01,len);
    baseColor*=inten*2.0;
    return min(baseColor,vec3(1.0));
}
vec3 DrawStar(float len,float angle)
{
    vec3 baseColor=vec3(0.0,0.3,0.7);
    float fre1=10.0;
    float fre2=20.0;
    float radius=0.05;
    float m=radius/(radius+abs(sin(len*fre1*1.0-0.2*iTime)));
    float n=radius/(radius+abs(sin(angle*fre2+len*100.0)));
    float f6=max(m*n-0.03*len,0.0)*100.0;
    return baseColor*f6;
}

float fbm(float x,float ka,float kw,float kb)
{
    float res=0.0;
    float w=1.0;
    float a=0.5;
    float b=PI;
    for(int i=0;i<3;i++)
    {
        res+=(1.0-res)*smoothstep(0.0,1.0,a*sin(w*x+b));
        a*=ka;
        w*=kw;
        b*=kb;
    }
    return res;
}
float map(float l)
{
    float lm=1.0;

    l=clamp(1e-1,lm,l);
    float lm2=lm*lm;
    float lm4=lm2*lm2;
    return sqrt(lm4/(l*l)+lm2);
}
vec3 DrawFlow(vec2 uv,float weight)
{
    vec3 baseColor=vec3(0.0);
    float angle=0.5*PI;
    vec2 bias=vec2(cos(angle),sin(angle))*0.01;
    baseColor+=texture(iChannel0,uv+bias).xyz*weight*0.5;
    baseColor+=texture(iChannel0,uv-bias).xyz*weight*0.5;
    // baseColor+=texture(iChannel0,uv).xyz*0.5;

    return baseColor;
}

void main(){
    vec2 uv=gl_FragCoord.xy/iResolution.xy;
    vec2 coord=uv-0.5;
    coord.x*=iResolution.x/iResolution.y;
    float len=length(coord);
    float angle=PI-acos(coord.x/len)*sign(coord.y);

    vec3 baseColor=vec3(0.0,0.0,0.0);
    float dis=map(len);
    baseColor+=DrawStar(dis/10.0,angle);
    baseColor+=vec3(0.0,0.3,0.7)*dis/10.0;
    // baseColor+=DrawCenter(len);
    // baseColor+=/100.0;
    // vec3 preColor=texture(iChannel0,uv).xyz;
    // baseColor+=DrawFlow(uv,0.3);
    // baseColor=mix(baseColor,preColor,0.9);
    gl_FragColor=vec4(baseColor,1.0);
}