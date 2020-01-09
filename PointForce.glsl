const float d=0.1;
const float fm=1.0;


float GetForce(float r)
{
    float a=fm*4.0*d*d;
    float b=a/d;
    float repulsion=a/(r*r+1e-5);
    float attraction=b/(r+1e-5);
    return repulsion-attraction;
}





void mainImage(out vec4 fragColor,in vec2 fragCoord)
{
    vec2 uv=fragCoord/iResolution.xy;

    float rate=0.1;
    float f=rate*GetForce(uv.x);

    vec2 t_pos=vec2(uv.x,f+0.5);
    vec3 color=vec3(.0);
    color=max(color,vec3(1.0)*smoothstep(0.01*(1.0-uv.x),0.0,distance(uv,t_pos)));
    color =max(color,vec3(0.0,1.0,1.0)*smoothstep(0.003,0.0,abs(uv.y-0.5)));
    color =max(color,vec3(0.0,1.0,0.0)*smoothstep(0.003,0.0,abs(uv.x-d)));
    color =max(color,vec3(1.0,0.0,0.0)*smoothstep(0.003,0.0,abs(uv.x-2.0*d)));
    color =max(color,vec3(0.0,0.0,1.0)*smoothstep(0.003,0.0,abs(uv.y-0.5+rate*fm)));
    fragColor=vec4(color,1.0);
}