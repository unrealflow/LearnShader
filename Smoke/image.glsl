#iChannel0 "file://./bufD.glsl"
#iChannel1 "self"

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv=fragCoord/iResolution.xy;
    vec4 col = textureLod(iChannel0,uv, 0.);
    if (fragCoord.y < 1. || fragCoord.y >= (iResolution.y-1.))
        col = vec4(0);
    vec2 w=1.0/iResolution.xy;

    vec4 tu=texture(iChannel0,uv+vec2(0.0,w.y));
    vec4 td=texture(iChannel0,uv-vec2(0.0,w.y));
    vec4 tl=texture(iChannel0,uv-vec2(w.x,0.0));
    vec4 tr=texture(iChannel0,uv+vec2(w.x,0.0));
    col=0.2*(col+tl+tr+tu+td);
    fragColor = col;
}