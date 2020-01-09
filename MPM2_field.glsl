#include "./MPM2_common.glsl"

#iChannel0 "file://./MPM2_point.glsl"


void mainImage(out vec4 fragColor,in vec2 fragCoord)
{
    vec2 uv=fragCoord/iResolution.xy;

    vec2 w=1.0/iResolution.xy;

    vec3 color=vec3(0.0);
    for(int i=0;i<p_size;i++)
    {
        for(int j=0;j<p_size;j++)
        {
            vec2 t_uv=GetUV(ivec2(i,j));

            vec4 data=texture(iChannel0,t_uv);
            vec2 pos=data.xy;
            float d=distance(pos,uv);
            float t=smoothstep(1.0,0.09,d/radius);
            color=max(color,vec3(t));
        }
    }

    fragColor=vec4(color,1.0);
}