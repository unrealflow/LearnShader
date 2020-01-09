#iChannel0 "self"
#iChannel1 "file://./MPM_field.glsl"
#define PI 3.141592654

uint GetIndex(vec2 fragCoord)
{
    return uint(fragCoord.y * iResolution.x + fragCoord.x);
}
vec2 Rot(vec2 v, float angle)
{
    return vec2(v.x * cos(angle) + v.y * sin(angle),
        v.y * cos(angle) - v.x * sin(angle));
}
float RadicalInverse(uint Base, uint i)
{
    float Digit, Radical, Inverse;
    Digit = Radical = 1.0 / float(Base);
    Inverse = 0.0;
    while (i > 0U) {
        Inverse += Digit * float(i % Base);
        Digit *= Radical;

        i /= Base;
    }
    return Inverse;
}

float RenderPoint(vec2 coord,vec2 p_pos,vec2 p_dir)
{
    float bias=dot(p_dir,p_dir);    
    p_dir=p_dir/(sqrt(bias)+1e-5);
    // p_dir=normalize(p_dir);
    bias=bias/(bias+0.1);


    vec2 dir=coord-p_pos;
    float len=length(dir);
    dir=dir/(len+1e-5);

    float size=0.1;

    float base=0.99;
    float r=size*(1.0-0.9*bias*bias);

    float theta=acos(dot(p_dir,dir));

    float p=r/(1.0-0.99*bias*theta/PI);
    p=size;
    float k=smoothstep(1.00,0.01,len/p);
    return k*k*k;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 uv = fragCoord / iResolution.xy;
    vec2 w=1.0/iResolution.xy;

    uint index = GetIndex(fragCoord - 0.5);
    if (index > 1000U) {
        fragColor = vec4(0.0);
        return;
    }
    if (iFrame < 2) {
        float x = RadicalInverse(2U, index);
        float y = RadicalInverse(3U, index);
        vec2 p = vec2(x, y) * 0.5 + 0.25;
        fragColor = vec4(p, normalize((p - 0.5)));
        return;
    }

    vec4 data = texture(iChannel0, uv);
    vec2 pos = data.xy;
    vec2 dir = data.zw;

    vec2 targetPos = pos + dir * 0.003;

    float tr = texture(iChannel1, pos + vec2(w.x , 0)).a;
    float tl = texture(iChannel1, pos - vec2(w.x , 0)).a;
    float tu = texture(iChannel1, pos + vec2(0 , w.y)).a;
    float td = texture(iChannel1, pos - vec2(0 , w.y)).a;

    float tc = RenderPoint(targetPos,pos,dir);
    float tt = texture(iChannel1, targetPos).a;

    float dx=tr-tl;
    float dy=tu-td;
    float df=tt-tc;
    dir-=0.1*vec2(dx,dy);
    if(df>0.0)
        dir*=max(1.0-0.01*df,0.0);

    pos=targetPos;
    

    if (iMouse.w > 0.1) {
        vec2 pd = iMouse.xy / iResolution.xy - pos;
        vec2 fa = cos(length(pd)) * normalize(pd);
        dir += 0.03 * fa;
    } else
    {
        dir+=vec2(0.0,-0.02);
    }
    dir*=0.995;
    // dir-=0.02*dir/(length(dir)+1e-5);

    if (pos.x < 0.0 || pos.x > 1.0) {
        pos.x = fract(2.0 - pos.x);
        dir.x = -dir.x*0.5;
    }
    if (pos.y < 0.0 || pos.y > 1.0) {
        pos.y = fract(2.0 - pos.y);
        dir.y = -dir.y*0.5;
    }

    // if(pos.y<0.01)
    // {
    //     dir.y=0.0;
    // }

    fragColor = vec4(pos, dir);
}