#iChannel0 "self"

vec2 hash22(vec2 p)
{
    p = vec2(dot(p, vec2(127.1, 311.7)),
        dot(p, vec2(269.5, 183.3)));

    return -1.0 + 2.0 * fract(sin(p) * 43758.5453123);
}
float simplex_noise(vec2 p)
{
    const float K1 = 0.366025404; // (sqrt(3)-1)/2;
    const float K2 = 0.211324865; // (3-sqrt(3))/6;
    vec2 i = floor(p + (p.x + p.y) * K1);
    vec2 a = p - (i - (i.x + i.y) * K2);
    vec2 o = (a.x < a.y) ? vec2(0.0, 1.0) : vec2(1.0, 0.0);
    vec2 b = a - o + K2;
    vec2 c = a - 1.0 + 2.0 * K2;
    vec3 h = max(0.5 - vec3(dot(a, a), dot(b, b), dot(c, c)), 0.0);
    vec3 n = h * h * h * h * vec3(dot(a, hash22(i)), dot(b, hash22(i + o)), dot(c, hash22(i + 1.0)));

    return dot(vec3(70.0, 70.0, 70.0), n);
}
float fbm(vec2 p)
{
    float res=0.0;
    float fre=1.0;
    float ap=1.0;
    for(int i=0;i<5;i++)
    {
       res+=ap*simplex_noise(p*fre);
       fre*=1.9;
       ap*=0.5;
    }
    return res;
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
vec3 DrawCenter(vec2 coord)
{
    float thre=8.0;
    vec3 color=vec3(0.0,0.3,0.8);
    float l=length(coord);
    
    float d=map(l);
    float f0=smoothstep(0.09,0.13,l);
    float f1=2.0*smoothstep(thre-0.54,thre,d);
    f1+=smoothstep(0.0,thre,d);
    return color*f0*f1;
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

void mainImage(out vec4 fragColor,in vec2 fragCoord)
{
    vec2 uv=fragCoord/iResolution.xy;
    vec2 w=1.0/iResolution.xy;
    vec2 coord=uv*2.0-1.0;
    vec2 uvDir=normalize(coord);
    coord.x*=iResolution.x/iResolution.y;

    float n=fbm(uv*400.0+uvDir*iTime);
    vec3 color=DrawCenter(coord);
    
    vec3 color1=BlurSampler(iChannel0,uv-0.003*(n+0.01)*uvDir,w).xyz;
    // vec3 color1=texture(iChannel0,uv-0.002*abs(n)*uvDir).xyz;

    color=max(color,color1*0.99);

    fragColor=vec4(color,1.0);
}