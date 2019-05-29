#define PI 3.141592654
#define MOD2 vec2(3.07965, 7.4235)


vec3 Remap(float r){
    vec3 basecolor=vec3(0.3,0.3,0.5);
    float step1=0.1;
    float step2=step1+0.1;
    float step3=step2+0.4;
    float f1=smoothstep(step1,step2,r);
    basecolor+=vec3(1.0,1.0,-0.3)*f1;
    float f2=smoothstep(step2,step3,r);
    basecolor+=vec3(0.0,-1.0,0.0)*f2;
    return basecolor*(step3+0.3-r);
}
float Hash( float p )
{
	vec2 p2 = fract(vec2(p) / MOD2);
    p2 += dot(p2.yx, p2.xy+19.19);
	return fract(p2.x * p2.y);
}
float Noise( in vec2 x )
{
    vec2 p = floor(x);
    vec2 f = fract(x);
    f = f*f*(3.0-2.0*f);
    float n = p.x + p.y*57.0;
    float res = mix(mix( Hash(n+  0.0), Hash(n+  1.0),f.x),
                    mix( Hash(n+ 57.0), Hash(n+ 58.0),f.x),f.y);
    return res;
}

void main(){
    vec2 uv=gl_FragCoord.xy/iResolution.xy-vec2(0.5,0.1);
    vec4 BaseColor =vec4(0.2,0.3,0.7,1.0);
    float r=length(uv);

    float angle=0.5*atan(uv.y/uv.x)*sign(uv.x)+PI*0.25;//0---0.5PI

    float f4=r*(1.0-0.993*sin(angle))*170.0;

    gl_FragColor=vec4(Remap(f4),1.0);//


}