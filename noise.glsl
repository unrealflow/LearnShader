#iChannel0 "self"
#define PI 3.141592654
float k=15.0;
float bias=5.1;


float fract2(float x)
{
    return 2.0*abs(fract(x)-0.5);
}
// float noise(float x)
// {
//     return fract2(fract2(x*k+bias)+bias);
// }

// vec3 noise(vec2 uv)
// {
//     // float pTime = floor(2.0*iTime);
//     float pTime=0.01*iTime;
    
//     float n1=1.0-2.0*noise(uv.y);
//     float n2=1.0-2.0*noise(uv.x);
//     float n3=1.0-2.0*noise(n1+n2+pTime);

//     // uv=rot(n3*PI*2.)*uv;
//     float n4=1.0-2.0*noise(uv.x+n3);
//     float n5=1.0-2.0*noise(uv.y+n4);
//     float n6=1.0-2.0*noise(pTime+n5);
//     n6=n6;
//     float r=sqrt(1.0-n6*n6);
//     n5*=PI;
//     vec3 p=vec3(r*sin(n5),r*cos(n5),n6);
//     // p=vec3(n6);
//     return abs(p);

// }
// vec3 noise_bad(vec2 uv)
// {
//     // float pTime = floor(2.0*iTime);
//     float pTime=0.01*iTime;
    
//     float n1=1.0-2.0*noise(uv.y);
//     float n2=1.0-2.0*noise(uv.x);
//     float n3=1.0-2.0*noise(n1+n2+pTime);

//     // uv=rot(n3*PI*2.)*uv;
//     float n4=1.0-2.0*noise(uv.x+n3);
//     float n5=1.0-2.0*noise(uv.y+n4);
//     float n6=1.0-2.0*noise(pTime+n5);
//     n5*=PI;
//     n6*=PI;
//     vec3 p=vec3(cos(n6)*sin(n5),cos(n6)*cos(n5),sin(n6));
//     // p=vec3(n6);
//     return abs(p);

// }

float noise(float a)
{
    float k = fract(fract(131.33 * a + 23.123) * 131.133);
    return k;
}

vec3 norm_noise(vec2 uv)
{
    float t1 = PI*noise(uv.x);
    float t2 = PI*noise(uv.y);
    float t3 = 2.0*PI*noise(t2 * uv.x - t1 * uv.y);
    float t4= 2.0* noise(t1 * uv.x + t2 * uv.y)-1.0;
    float t5=t4;
    float r=sqrt(1.0-t5*t5);
    vec3 p=vec3(r*sin(t3),r*cos(t3),t5);
    return abs(p);
}

void main()
{
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 coord=uv*2.0-1.0;
    coord.x*=iResolution.x/iResolution.y;
    vec3 color=norm_noise(coord+iTime);
    color=mix(color,texture(iChannel0,uv).xyz,0.99);
    gl_FragColor = vec4(color, 1.0);
}