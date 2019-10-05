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
    float fre1=30.0;
    float fre2=20.0;
    float radius=0.03;
    float m=radius/(radius+abs(sin(len*fre1*1.0-0.5*iTime)));
    float n=radius/(radius+abs(sin(angle*fre2+len*100.0)));
    float f6=max(m*n-0.1*len,0.0)*100.0;
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
vec3 DrawCloud(float dis,float angle)
{
    vec3 baseColor=vec3(0.0,0.0,0.0);
    vec3 cloudColor=vec3(0.0,0.3,0.7);
    float x=angle+dis;
    float fre=2.0;
    float ap=1.0;
    for(int i=1;i<5;i++)
    {
        float k=1.0+sin(fre*x+0.3*iTime);
        k=k*k*0.25;
        float p=fract(k+dis/float(i+1));
        p=p*(1.0-p);
        p=smoothstep(0.1,0.25,p);
        baseColor+=ap*cloudColor*p;
        fre*=-2.0;
        ap*=0.5;
    }
    return baseColor*1.0;
}
void main(){
    vec2 uv=gl_FragCoord.xy/iResolution.xy;
    vec2 coord=uv-0.5;
    if(iResolution.y>iResolution.x)
    {
         coord.x*=iResolution.x/iResolution.y;
    }
    else
    {
         coord.y/=iResolution.x/iResolution.y;
    }
    float len=length(coord);
    float angle=PI-acos(coord.x/len)*sign(coord.y);

    vec3 baseColor=vec3(0.0,0.0,0.0);
    float dis=map(len);
    baseColor+=DrawStar(dis/10.0,angle);
    // baseColor+=vec3(0.0,0.3,0.7)*dis/10.0;
    baseColor+=DrawCloud(dis,angle)*0.3;
    vec3 fogColor=vec3(0.3,1.5,3.0);
    float fogC=pow(0.97,dis);
    baseColor=mix(fogColor,baseColor,fogC);
    // baseColor*=DrawStar(dis/10.0,angle);
    gl_FragColor=vec4(baseColor,1.0);
}