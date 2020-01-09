#iChannel0 "self"
#iChannel1 "file://./MPM2_field.glsl"



void mainImage(out vec4 fragColor,in vec2 fragCoord)
{
    vec2 uv=fragCoord/iResolution.xy;

    vec2 coord=uv*2.0-1.0;
    coord.x*=iResolution.x/iResolution.y;
    vec2 w=1.0/iResolution.xy;
    float base=0.1;
    vec3 color=vec3(smoothstep(base,1.5*(base+1.0),texture(iChannel1,uv).xyz));
    // vec3 preColor=texture(iChannel0,uv).xyz;

    fragColor=vec4(color,1.0);
}