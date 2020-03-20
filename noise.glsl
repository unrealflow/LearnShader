#iChannel0 "self"
#define PI 3.141592654
float k=15.0;
float bias=5.1;


float fract2(float x)
{
    return 2.0*abs(fract(x)-0.5);
}
vec3 norm_fract(vec3 x)
{
    vec3 p=fract(x);
    return 8.0*p*(1.0-p)-1.0;
}
float noise(float a)
{
    float k = fract(sin(131.33 * a + 23.123) * 131.133);
    return k;
}
vec3 noise(vec3 a)
{
    vec3 k = fract(sin(131.33 * a + 23.123) * 131.133);
    return k;
}
vec3 noise3(vec2 coord)
{
    float len=length(coord);
    vec3 kp=vec3(coord,len+1.0);
    float bias=noise(kp.z);
    float fre=1.0;
    float ap=1.0;
    for(int i=0;i<2;i++)
    {
        kp+=sin(kp.zxy*fre+bias*PI*2.0);
        kp=cross(cos(kp),sin(kp.yzx))*ap;
        kp=noise(kp);
    }
    return kp*2.0-1.0;
}
vec3 norm_noise(vec2 coord)
{
    float len=length(coord);
    vec3 kp=vec3(coord,len+1.0);
    float bias=noise(kp.z);
    float fre=1.0;
    float ap=1.0;
    for(int i=0;i<2;i++)
    {
        kp+=sin(kp.zxy*fre+bias*PI*2.0);
        kp=cross(cos(kp),sin(kp.yzx))*ap;
        kp=noise(kp);
    }
    float t3 = 2.0*PI*kp.x;
    float t4= 2.0* kp.y-1.0;
    float t5=t4;
    float r=sqrt(1.0-t5*t5);
    vec3 p=vec3(r*sin(t3),r*cos(t3),t5);
    return (p);
}
vec3 fbm_noise(vec2 coord,float ft)
{
    float len=length(coord);
    vec3 kp=vec3(coord,len+1.0);
    float fre=1.0;
    float ap=0.5;
    vec3 d=vec3(1.0);
    for(int i=0;i<5;i++)
    {
        // kp=mix(kp,kp.yzx,0.1);
        kp+=sin(0.75*kp.zxy * fre+ft*iTime);
        d -= abs(cross(sin(kp), cos(kp.yzx)) * ap);
        fre*=-1.9;
        ap*=0.5;
    }
    return vec3(abs(d-0.2));
}

void main()
{
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 coord=uv*2.0-1.0;
    coord.x*=iResolution.x/iResolution.y;
    // vec3 color=noise3(coord);
    // vec3 color=norm_noise(coord);
    vec3 color=fbm_noise(coord*10.0,1.0);
    // color=mix(color,texture(iChannel0,uv).xyz,0.95);
    gl_FragColor = vec4(color, 1.0);
}