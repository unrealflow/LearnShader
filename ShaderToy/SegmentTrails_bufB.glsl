#iChannel0 "file://./SegmentTrails_bufA.glsl"
#iChannel1 "self"

#define clamps(x) clamp(x,0.,1.)
float pi = 3.14159265358979323;
vec2 circle(float a){return vec2(cos(a),sin(a));}
void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
	vec2 uv = fragCoord.xy / iResolution.xy;
    vec4 d = vec4(0);
    #define L 8.
    for(float i=0.;i<L;i++){
        vec2 p = circle((i/L)*pi*2.);
        p.x /= iResolution.x/iResolution.y;
		d = max(d,texture(iChannel1,uv+(p*0.00003)));
    }
	fragColor = pow(texture(iChannel0,uv),vec4(4.))+(clamps(d)*pow(0.05,iTimeDelta));
}