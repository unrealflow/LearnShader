#include "./smoke_common.glsl"
#iChannel0 "self"
// #iChxannel0 "file://./smoke_bufB.glsl"

void mainImage(out vec4 fragColor,in vec2 fragCoord)
{
    
    // if (iFrame < 20)
    // {
    //     fragColor = vec4(0.0,0.0,0.5,0);
    //     return;
    // }
    vec2 uv=fragCoord/iResolution.xy;
    float aspect=iResolution.x/iResolution.y;;
    vec2 coord=uv*2.0-1.0;
    coord.x*=aspect;
   
    fragColor=render(iChannel0,uv,coord,1.0/iResolution.xy,iTime);
    // fragColor=vec4(uv,0.0,1.0);
}