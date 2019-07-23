#iChannel0 "file://./SegmentTrails_bufA.glsl"
#iChannel1 "file://./SegmentTrails_bufB.glsl"

#define clamps(x) clamp(x,0.,1.)
void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
	vec2 uv = fragCoord.xy / iResolution.xy;
    vec2 suv = uv-.5; suv.x /= iResolution.y/iResolution.x;
	fragColor = texture(iChannel0,uv)+(texture(iChannel1,uv)*1.)+vec4(clamps(1.-(((length(suv)-0.2)+0.2)*2.))*vec3(0.1,0.12,0.3),0.);
}