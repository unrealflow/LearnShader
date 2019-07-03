
#iChannel0 "file://./ColoredLines_buff.glsl"


//bloom and DOF. Check buffer's #define to tweak the shape
float [] blurWeights = float[](0.002216,
   0.008764,
   0.026995,
   0.064759,
   0.120985,
   0.176033,
   0.199471,
   0.176033,
   0.120985,
   0.064759,
   0.026995,
   0.008764,
   0.002216);

vec4 blur (vec2 uv)
{
    vec4 res;
	for (int x = - 6; x < 6; x ++)
    {
    	for (int y = -6 ; y < 6; y ++)
        {
            res += blurWeights[x+6]*blurWeights[y+6] * texture( iChannel0, ( uv * iResolution.xy + vec2 (x,y) ) / iResolution.xy);
        }
    }
    return res;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = fragCoord/iResolution.xy;
  
   	vec4 buf = texture( iChannel0, ( uv));
    vec3 blr = blur(uv).rgb;
    float near =3.; float mid = 9.; float far = 15.;
    float curve = smoothstep(0.,near,buf.w)* smoothstep(far,mid,buf.w);
    vec3 col = mix (blr,buf.rgb,curve);
    col.rgb += 0.5*blr;

    fragColor = vec4 (col,1.);
}