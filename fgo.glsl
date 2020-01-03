
const int TOTAL=160;
const float RATE=0.028;

float compute(int total,int target)
{
    float c=1.0;
    float f_total=float(total);
    float f_target=float(target);
    for(int i=0;i<target;i++)
    {
        float v=float(i+1);
        c*=(f_total-v)/v;
    }
    return c*pow(RATE,f_target)*pow(1.0-RATE,f_total-f_target);
}


vec3 DrawLine(vec2 uv,float y)
{
    vec3 color=vec3(1.0);

    return color*smoothstep(0.002,0.0,abs(uv.y-y));
}

void mainImage(out vec4 fragColor,in vec2 fragCoord)
{
    vec2 uv=fragCoord/iResolution.xy;

    // vec2 coord=uv*2.0-1.0;
    // coord.x*=iResolution.x/iResolution.y;
    float base=0.1;
    vec3 color=DrawLine(uv,base);
    vec3 baseColor=vec3(0.0,0.6,1.0);
    float acc=0.0;
    for(int i=0;i<5&&i<TOTAL;i++)
    {
        float f_i=float(i);
        float x=0.5+(f_i-2.5)*0.15;
        float y=compute(TOTAL,i);
        acc+=y;
        y*=0.9;

        vec2 p=vec2(x,y+base);
        vec2 b=vec2(x,base);

        float dis=distance(uv,p)+distance(uv,b);

        color+=baseColor*smoothstep(0.001,0.0,dis-y);
    }
    {
        float x=0.5+(5.0-2.5)*0.15;
        float y=1.0-acc;

        vec2 p=vec2(x,y+base);
        vec2 b=vec2(x,base);

        float dis=distance(uv,p)+distance(uv,b);
        color+=baseColor*smoothstep(0.001,0.0,dis-y);
    }
    

    fragColor=vec4(color,1.0);
}