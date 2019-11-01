#iChannel0 "file://./smoke_bufA.glsl"

void mainImage(out vec4 fragColor,in vec2 fragCoord)
{
    vec2 uv=fragCoord/iResolution.xy;

    vec2 coord=uv*2.0-1.0;
    coord.x*=iResolution.x/iResolution.y;

    fragColor=vec4(texture(iChannel0,uv).z);
}