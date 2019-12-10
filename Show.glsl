#iChannel0 "file://./smoke_bufA.glsl"

vec4 BlurSampler(sampler2D tex,vec2 uv,vec2 w)
{
    vec4 color=texture(tex,uv+vec2(0.0,w.y));
    color+=texture(tex,uv-vec2(0.0,w.y));
    color+=texture(tex,uv+vec2(w.x,0.0));
    color+=texture(tex,uv-vec2(w.x,0.0));
    return 0.25*color;
}
vec3 Add(vec3 a,vec3 b)
{
    return vec3(a.xy+b.xy,max(a.z,b.z));
}
void mainImage(out vec4 fragColor,in vec2 fragCoord)
{
    vec2 uv=fragCoord/iResolution.xy;

    vec2 coord=uv*2.0-1.0;
    coord.x*=iResolution.x/iResolution.y;

    fragColor=vec4((texture(iChannel0,uv).xyz),vec3(1.0));
}