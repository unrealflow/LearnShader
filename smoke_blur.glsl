#iChannel0 "file://./smoke_bufB.glsl"



void mainImage(out vec4 fragColor,in vec2 fragCoord)
{
    vec2 uv=fragCoord/iResolution.xy;

    vec2 coord=uv*2.0-1.0;
    coord.x*=iResolution.x/iResolution.y;
    vec2 w=1.0/iResolution.xy;
    vec4 tc=texture(iChannel0,uv);
    vec4 tl=texture(iChannel0,uv-vec2(w.x,0.0));
    vec4 tr=texture(iChannel0,uv+vec2(w.x,0.0));
    vec4 tu=texture(iChannel0,uv+vec2(0.0,w.y));
    vec4 td=texture(iChannel0,uv-vec2(0.0,w.y));
    fragColor=0.2*(tc+tl+tr+tu+td);
}