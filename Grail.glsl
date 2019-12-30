#iChannel0 "file://./Feather.glsl"
#define PI 3.141592654
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
float map(float l)
{
    float lm = 1.0;
    l = clamp(1e-5, l, l);
    float lm2 = lm * lm;
    float lm4 = lm2 * lm2;
    return sqrt(lm4 / (l * l) + lm2);
    // return 1.0/(l+1e-5);
}

vec4 BlurSampler(sampler2D tex,vec2 uv,vec2 w)
{
    vec4 color=texture(tex,uv);
    color+=texture(tex,uv+vec2(0.0,w.y));
    color+=texture(tex,uv-vec2(0.0,w.y));
    color+=texture(tex,uv+vec2(w.x,0.0));
    color+=texture(tex,uv-vec2(w.x,0.0));
    return 0.2*color;
}
vec3 fbm_noise(vec2 coord,float ft)
{
    float len=length(coord);
    float dis=map(len);
    vec3 kp = vec3(coord * max(dis, 1.0), dis);

    float fre=1.0;
    float ap=0.5;
    vec3 d=vec3(1.0);
    for(int i=0;i<5;i++)
    {
        kp=mix(kp,kp.yzx,0.1);
        kp+=sin(0.75*kp.zxy * fre+ft*iTime);
        d -= abs(dot(sin(kp), norm_fract(kp.yzx)) * ap);
        fre*=-2.0;
        ap*=0.5;
    }
    return vec3((d));
}
vec3 DrawLines(vec2 coord,float fre,float ap,float bias)
{
    
    float len=length(coord);
    float depth=map(len);
    float frag=(sin((depth-2.0*bias)*4.0)+1.0)*0.5;
    vec3 color=mix(vec3(0.0,0.0,0.99),vec3(0.0,1.0,1.0),frag*0.5);
    // vec3 color=vec3(0.0,0.5,0.99);
    float angle =atan(coord.y,coord.x);

    float p=angle+fre*depth+bias;
    float base=1.001;
    float k=0.1/(0.1+len);
    color*=smoothstep(base-k*k*k,base,(sin(p*3.0)+1.0)*0.5);
    return 6.0*color*smoothstep(10.0,1.0,depth)*frag*ap;
}


void mainImage(out vec4 fragColor,in vec2 fragCoord)
{
    vec2 uv=fragCoord/iResolution.xy;
    vec2 w=1.0/iResolution.xy;
    vec2 coord=uv*2.0-1.0;
    coord.x*=iResolution.x/iResolution.y;
    vec3 color=vec3(0.0);
    float ap=abs(fbm_noise(coord,0.5).x);
    // color=max(color,DrawCenter(coord));
    color=max(color,BlurSampler(iChannel0,uv,w).xyz)*(1.0+0.2*ap);
    color=max(color,DrawLines(coord,1.0,ap,0.0+0.2*iTime));
    color=max(color,0.5*DrawLines(coord,3.0,ap,PI*0.2+0.3*iTime));
    color=max(color,0.3*DrawLines(coord,6.0,ap,PI*0.2+0.5*iTime));

    fragColor=vec4(color,1.0);
}