#include "./MPM2_common.glsl"
#iChannel0 "self"

#define d (2.0*radius)
const float fm=1.0;


float GetForce(float r)
{
    float a=fm*4.0*d*d;
    float b=a/d;
    float repulsion=a/(r*r+1e-5);
    float attraction=b/(r+1e-5);
    return repulsion-attraction;
}
// pos0为受力点，计算其受pos1的斥力
vec2 GetForce(vec2 pos0,vec2 pos1)
{
    vec2 dir=pos0-pos1;
    float r=length(dir);
    dir/=(r+1e-5);
    float f=GetForce(r);
    return Rot(dir*f,0.1*PI);
}


void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 uv = fragCoord / iResolution.xy;
    vec2 w = 1.0 / iResolution.xy;

    ivec2 indices = GetIndices(fragCoord);

    if (indices.x >= p_size || indices.y >= p_size) {
        fragColor = vec4(vec3(0.0), 1.0);
        return;
    }
    if (iFrame < 2) {
        const vec2 center = vec2(0.5);
        vec2 pos = 2.0 * radius * (vec2(indices) + 0.5 - 0.5 * vec2(p_size));
        pos=Rot(pos,0.1) + center;
        vec2 dir = vec2(0.0);
        fragColor = vec4(pos, dir);
        return ;
    }
    vec4 data=texture(iChannel0,uv);

    vec2 pos=data.xy;
    vec2 dir=data.zw;
    
    vec2 force=vec2(0.0);
    if(indices.y<p_size-1)
    {
        vec4 pu=texture(iChannel0,uv+vec2(0.0,w.y));
        force+=GetForce(pos,pu.xy);
    }
    if(indices.y>0)
    {
        vec4 pd=texture(iChannel0,uv-vec2(0.0,w.y));
        force+=GetForce(pos,pd.xy);
    }
    if(indices.x>0)
    {
        vec4 pl=texture(iChannel0,uv-vec2(w.x,0.0));
        force+=GetForce(pos,pl.xy);
    }
    if(indices.x<p_size-1)
    {
        vec4 pr=texture(iChannel0,uv+vec2(w.x,0.0));
        force+=GetForce(pos,pr.xy);
    }
    force+=vec2(0.0,-0.01);
    dir+=0.1*force;
    pos+=dir*0.001;

    dir*=0.95;

    if (pos.x < 0.0 || pos.x > 1.0) {
        pos.x = fract(2.0 - pos.x);
        dir.x = -dir.x*0.5;
    }
    if (pos.y < 0.0 || pos.y > 1.0) {
        pos.y = fract(2.0 - pos.y);
        dir.y = -dir.y*0.5;
    }

    fragColor=vec4(pos,dir);

}