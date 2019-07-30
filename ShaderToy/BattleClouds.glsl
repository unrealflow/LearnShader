#iChannel0 "file://./3.jpg"
#iChannel1 "file://./BattleClouds_sound.glsl"



///////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////
#define FLIGHT_SPEED 15.0
///////////////////////////////////////////////////////////////////////////////////

float blerp(float x, float y0, float y1, float y2, float y3) {
	float a = y3 - y2 - y0 + y1;
	float b = y0 - y1 - a;
	float c = y2 - y0;
	float d = y1;
	return a * x * x * x + b * x * x + c * x + d;
}

float rand(vec2 co){
  return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

float perlin(float x, float h) {
	float a = floor(x);
	return blerp(mod(x, 1.0),
		rand(vec2(a-1.0, h)), rand(vec2(a-0.0, h)),
		rand(vec2(a+1.0, h)), rand(vec2(a+2.0, h)));
}

float Lightning(float time)
{
	return clamp(pow(perlin(((time)*6.14159), 3.14), 5.0), 0.0, 1.0);    
}

struct Material {
    vec3 colour;
    float diffuse;
    float specular;
};
    
struct Ray {
    vec3 pos;
    vec3 dir;
};
    
struct Light {
    vec3 pos;
    vec3 colour;
};
    
struct Result {
    vec3 pos;
    vec3 normal;
    Material mat;
    vec4 fog;
};

///////////////////////////////////////////////////////////////////////////////////

Material g_NoMaterial = Material(vec3(1.0, 0.0, 1.0), 0.0, 1.0);
Result g_result;
    
///////////////////////////////////////////////////////////////////////////////////

const int lightarraysize = 2;
const int numlights = 2;
Light g_lights[lightarraysize];

float lightning = 0.0;
vec3 lightningcolour = vec3(1.5, 2.0, 3.0);

///////////////////////////////////////////////////////////////////////////////////



///////////////////////////////////////////////////////////////////////////////////
// IQ's noise functions

//#define HIGH_QUALITY_NOISE

float noise( in vec3 x )
{    
    vec3 p = floor(x);
    vec3 f = fract(x);
	//f = f*f*(3.0-2.0*f);
	vec2 uv = p.xy + f.xy;
	vec2 rg = textureLod( iChannel0, (uv.xy + p.z*37.0 + 0.5)/256.0, 0. ).yx;
	
    //return rg.x*0.9;
    //return mix( rg.x, rg.y, 0.5 );
	return mix( rg.x, rg.y, f.z );
}

float noise2( in vec3 x )
{
    vec3 p = floor(x);
    vec3 f = fract(x);
	//f = f*f*(3.0-2.0*f);
    f = (f*f*(3.0-2.0*f)+f)*0.5;
#ifndef HIGH_QUALITY_NOISE
	vec2 uv = (p.xy+vec2(37.0,17.0)*p.z) + f.xy;
	vec2 rg = textureLod( iChannel0, (uv+ 0.5)/256.0, 0. ).yx;
#else
	vec2 uv = (p.xy+vec2(37.0,17.0)*p.z);
	vec2 rg1 = textureLod( iChannel0, (uv+ vec2(0.5,0.5))/256.0, 0. ).yx;
	vec2 rg2 = textureLod( iChannel0, (uv+ vec2(1.5,0.5))/256.0, 0. ).yx;
	vec2 rg3 = textureLod( iChannel0, (uv+ vec2(0.5,1.5))/256.0, 0. ).yx;
	vec2 rg4 = textureLod( iChannel0, (uv+ vec2(1.5,1.5))/256.0, 0. ).yx;
	vec2 rg = mix( mix(rg1,rg2,f.x), mix(rg3,rg4,f.x), f.y );
#endif	
	return mix( rg.x, rg.y, f.z );
}

///////////////////////////////////////////////////////////////////////////////////

//#define MARCH_ITERATIONS 	270
//#define MARCH_DELTA			0.05
//#define MARCH_DELTA2		1.01
//#define START_DIST 			1.0

#define MARCH_ITERATIONS 	240
#define MARCH_DELTA			0.05
#define MARCH_DELTA2		1.01
#define START_DIST 			6.0

float mist(vec3 p, int LOD)
{   
    vec3 p2 = p;
    p *= 0.2;
    float weight = 0.25;
    float totalweight = 0.0;
    float value = 0.0;
    for (int i=0; i<LOD; i++)
    {
        totalweight += weight;
        value += noise2(p)*weight;    
        p *= 2.03;
        weight *= 0.6;
    }
    //return (value/totalweight + abs(p.y)*0.01 + abs(p.x)*0.0003 - 0.1);
    return (value/totalweight + abs(p2.y)*0.07 + abs(p2.x)*0.0001 - 0.1);
}

///////////////////////////////////////////////////////////////////////////////////

float fogvalue(float mistvalue)
{
    float value=0.0;
    const float vmax=0.7;
    const float vmin=0.5;

    if (mistvalue >= vmax)
        value = 1.0;
    else if (mistvalue <= vmin)
        value = 0.0;
    else
        value = (mistvalue-vmin)/(vmax-vmin);

    value=value*value;
    return value;
}

Result raymarch_query(Ray ray, int iterations, float delta)
{
    Result result = Result(ray.pos+ray.dir*10000.0, vec3(0.0, 0.0, 0.0), g_NoMaterial, vec4(0.0, 0.5, 0.0, 0.0));    
    float dist = 0.0;
    float fog=0.0;
    float dstalpha = 0.0;
    float srcalpha = 0.0;
    const float densitythreshold = 0.70;
    const float densityscale = 100.0/(1.0-densitythreshold);
    
    vec3 lighting = vec3(-1.0, -1.0, 1.0);
    lighting = normalize(lighting);
    
	for (int i=0; i<iterations; i++)
    {        
		float v1 = mist(ray.pos, 5);
		float value=fogvalue(v1);
		vec3 fogcolour = mix(vec3(0.1 + lightning*0.2), vec3(0.0), value);
        
        for (int j=0; j<numlights; j++)
        {
            lighting = ray.pos - g_lights[j].pos;
            float attenuation = clamp(9.0 / length(lighting), 0.0, 1.0);
            lighting = normalize(lighting);        
            float v2 = mist(ray.pos + lighting*1.0, 5);
                     
            if ((v2-v1) >= 0.0)
            {
                fogcolour += (v2-v1)*(v2-v1)*10.0*g_lights[j].colour*2.0*attenuation;
                fogcolour += 0.3*g_lights[j].colour*1.0*attenuation*attenuation;
            }
        }    
        
        // density is the value times the step       
        float density = clamp(value*delta*0.7, 0.0, 1.0);
        density*=clamp(delta*4.0, 0.0, 1.0);
        // update the alpha
        srcalpha = density;
        
        if (srcalpha>0.01)
        {
            // modify the destingation alpha, based on the current srcalpha
            float prevdstalpha = dstalpha;
            dstalpha = dstalpha + srcalpha*(1.0 - dstalpha);
            result.fog.xyz = mix(fogcolour, result.fog.xyz, prevdstalpha/dstalpha);
        }
        if (dstalpha>0.95)
        {
		   	result.fog.w = dstalpha;
    		return result;            
        }
             
        ray.pos += ray.dir*delta;
        delta*=MARCH_DELTA2;
    }
            
   	result.fog.w = dstalpha;
    return result;
}

///////////////////////////////////////////////////////////////////////////////////

vec3 raymarch(Ray inputray)
{
    vec3 colour = vec3(0.0, 0.0, 0.0);
    Ray ray=inputray;        
    g_result = raymarch_query(ray, MARCH_ITERATIONS, MARCH_DELTA);
    
//    colour = vec3(g_result.fog.w);	
//    colour = g_result.fog.xyz;    
    colour = mix(vec3(0.05), g_result.fog.xyz, g_result.fog.w);       
    //colour = mix(vec3(0.0), g_result.fog.xyz, g_result.fog.w);       
            
    return colour;    
}

///////////////////////////////////////////////////////////////////////////////////

vec3 nearestpointonline(vec3 l0, vec3 l1, vec3 p)
{
    vec3 ld = l1-l0;
    vec3 ldn = normalize(ld);
    float d = dot(p-l0, ldn);
    vec3 r = l0+d*ldn;
    //return r - normalize(p-r)*mist(p,1);
    
    if (d<0.0) 
        return l0;
    else if (d>length(ld))
        return l1;
    else
        return r;
}

vec3 volumelights( Ray ray )
{   
    float caststep=0.5;    
    vec3 colour = vec3(0.0, 0.0, 0.0);                
    float castdistance = 0.0;
    for (int i=0; i<numlights; i++)
    {
	    castdistance = max(length(g_lights[i].pos-ray.pos)*1.1, castdistance);    
    }
    float castscale=castdistance/caststep;
	float obscurity = 0.0;
    
    for (float t=0.0; t<castdistance; t+=caststep)
    {
        vec3 pos = ray.pos + ray.dir*t; 
        obscurity += fogvalue(mist(pos, 5));
		vec3 deltapos;
        float d2;
        
        if (lightning > 0.5)
        {
            vec3 nearest = nearestpointonline(g_lights[0].pos, g_lights[1].pos, pos);
            deltapos = nearest-pos;
            float d2=dot(deltapos, deltapos);
            if (d2<5.0)
            {
                colour.xyz += lightningcolour/(d2*castscale*1.0) * lightning;
            } 
        }
                
        for (int i=0; i<numlights; i++)
        {        
            deltapos = g_lights[i].pos-pos;
            d2=dot(deltapos, deltapos);
            
            if (d2<40.0)
            {
                colour.xyz += g_lights[i].colour/(d2*castscale*0.4);
            }   
            
            //colour.rgb += clamp(mist(pos), 0.0, 1.0)*0.01;
        }
    }
    
    return colour*clamp((1.0-obscurity*0.1), 0.0, 1.0);
}

///////////////////////////////////////////////////////////////////////////////////
// main loop

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{           
    fragColor = vec4(0.0, 0.0, 0.0, 1.0);
    
    Ray ray;
    vec2 uv = fragCoord.xy / iResolution.xy * 2.0 - 1.0;
    uv.y *= iResolution.y / iResolution.x;
    
    float speed = FLIGHT_SPEED;
    float roll = 0.5;
    float time = iTime + 37.0;
    
    float ft = time-1.0;
	vec3 p0 = vec3(12.0 - perlin(ft*0.25, 7.5)*24.0, 3.0 - perlin(ft*0.25, 8.5)*6.0, 0.0);  
    ft+=0.5;
	vec3 p1 = vec3(12.0 - perlin(ft*0.25, 7.5)*24.0, 3.0 - perlin(ft*0.25, 8.5)*6.0, 0.0); 
    
    // screen shake
    float l = 0.0;
    for (float t=-0.2; t<0.2; t+=0.01)
    {
        float val = Lightning(time+t);
    	if (val>0.5)
            l += val;    
    }
    l/=60.0;    
    p1+=l*vec3(perlin(time*15.0, 5.0)*1.0 - 0.5, perlin(time*16.0, 6.0)*1.0 - 0.5, perlin(time*17.0, 7.0)*1.0 - 0.5);
    
    vec3 dir = (p1-p0) + vec3(0.0, 0.0, 4.0);
    dir = normalize(dir);
    vec3 up = vec3(dir.x*roll, 1.0, 0.0);
    up = normalize(up);
    vec3 right = cross(dir, up);
    right = normalize(right);
    up = cross(right, dir);
    up = normalize(up);
    
    ray.pos = vec3(0.0, 0.0, time*speed) + p0;
    ray.dir = dir*1.0 + up*uv.y + right*uv.x;
    ray.dir = normalize(ray.dir);
        
    ray.pos += ray.dir*START_DIST;
    
    g_lights[0].pos = vec3(0.0, 0.0, time*speed) + vec3(perlin(time*0.4, 2.5)*30.0-15.0, perlin(time*0.4, 3.5)*8.0-4.0, 20.0 + perlin(time*0.4, 13.5)*8.0-4.0);
    g_lights[1].pos = vec3(0.0, 0.0, time*speed) + vec3(perlin(time*0.6, 1.5)*30.0-15.0, perlin(time*0.6, 2.5)*8.0-4.0, 20.0 + perlin(time*0.6, 11.5)*8.0-4.0);
    
    const float looptime = 3.0;
        
    float fft1 = perlin(time*0.8, 112.5);
    float fft2= perlin(time*0.5, 112.5);
    fft1 += 0.5;
    fft2 += 0.5;    
    fft1 = 0.5;
    fft2 = 0.5;
    
    lightning = Lightning(time);
    g_lights[0].colour = mix(vec3(1.0, fft1, fft1), lightningcolour, lightning);
    g_lights[1].colour = mix(vec3(fft2, fft2, 1.0), lightningcolour, lightning);
    
    float f = texelFetch( iChannel1, ivec2(1, 0), 0 ).x; 
	g_lights[0].colour *= 0.5 + lightning*0.5 + f;
	g_lights[1].colour *= 0.5 + lightning*0.5 + f;
    
    fragColor.xyz = vec3(0.0);
        
    fragColor.xyz += raymarch(ray); 
    fragColor.xyz += volumelights(ray);
}

///////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////
