#define PI 3.141592653589793

#define EXPLOSION_COUNT 8.
#define SPARKS_PER_EXPLOSION 156.

// Hash function by Dave_Hoskins.
#define MOD3 vec3(.1031,.11369,.13787)
vec3 hash31(float p) {
   vec3 p3 = fract(vec3(p) * MOD3);
   p3 += dot(p3, p3.yzx + 19.19);
   return fract(vec3((p3.x + p3.y) * p3.z, (p3.x + p3.z) * p3.y, (p3.y + p3.z) * p3.x));
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    float aspectRatio = iResolution.x / iResolution.y;
    vec2 uv = fragCoord / iResolution.xy;
    uv.x *= aspectRatio;
    float t = iTime;
	vec3 col = vec3(0.); 
    vec2 origin = vec2(0.);
    
    for (float j = 0.; j < EXPLOSION_COUNT; ++j)
    {
        vec3 oh = hash31((j + 123.4679) * 987.1254);
        origin = vec2(oh.x*aspectRatio, oh.y);
        t += (j + 1.)*6.7451*oh.z;
        for (float i = 0.; i < SPARKS_PER_EXPLOSION; ++i)
    	{
            vec3 h = hash31(i);
            float a = h.x * PI * 2.;
            float rScale = h.y*.08;
            if (mod(t * 4., 12.) > 1.5)
            {
                float r = mod(t * 4., 12.) * rScale;
                vec2 sparkPos = vec2(r * cos(a), r * sin(a)); 
                float spark = .0002/pow(length(uv - sparkPos - origin), 1.8); // shiny sparks
                float shimmer = sin(((sparkPos.x + sparkPos.y + i*3.)
                                     * h.y * 2. * PI) * 25.);
                float fade = max(0., 11.5 * rScale - r);
                col += mix(spark, shimmer * spark, r) * fade * oh;
            }
    	}
    }
    fragColor = vec4(col, 1.0);
}