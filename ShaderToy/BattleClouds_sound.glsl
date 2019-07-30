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



vec2 mainSound( float time )
{    
    time = time+37.0;
    
    // view dir calculation
    float roll = 0.5;
    float ft = time-1.0;
	vec3 p0 = vec3(12.0 - perlin(ft*0.25, 7.5)*24.0, 3.0 - perlin(ft*0.25, 8.5)*6.0, 0.0);  
    ft+=0.5;
	vec3 p1 = vec3(12.0 - perlin(ft*0.25, 7.5)*24.0, 3.0 - perlin(ft*0.25, 8.5)*6.0, 0.0);     
    vec3 dir = (p1-p0) + vec3(0.0, 0.0, 4.0);
    dir = normalize(dir);
    vec3 up = vec3(dir.x*roll, 1.0, 0.0);
    up = normalize(up);
    vec3 right = cross(dir, up);
    right = normalize(right);
    up = cross(right, dir);
    up = normalize(up);   
    
    // light positons
    vec3 lpos0 = vec3(0.0, 0.0, time*FLIGHT_SPEED) + vec3(perlin(time*0.4, 2.5)*30.0-15.0, perlin(time*0.4, 3.5)*8.0-4.0, 20.0 + perlin(time*0.4, 13.5)*8.0-4.0);
    vec3 lpos1 = vec3(0.0, 0.0, time*FLIGHT_SPEED) + vec3(perlin(time*0.6, 1.5)*30.0-15.0, perlin(time*0.6, 2.5)*8.0-4.0, 20.0 + perlin(time*0.6, 11.5)*8.0-4.0);
    
    float ll = dot(normalize(lpos0-p0), right) + dot(normalize(lpos1-p0), right);
    float rr = dot(normalize(lpos0-p0), right) + dot(normalize(lpos1-p0), right);
	ll=pow(ll,3.0);
    rr=pow(rr,3.0);
    
    float l = 0.0;
    for (float t=-0.1; t<0.1; t+=0.01)
    {
        float val = Lightning(time+t);
    	if (val>0.5)
            l += val;    
    }
    l/=5.0;
    float w = 0.0;
    for (float t=-0.1; t<0.5; t+=0.01)
    {
        float val = Lightning(time+t);
    	if (val>0.5)
            w += val;    
    }
    w/=10.0;
    
    float s = perlin(time*4000.0, 1.5)*l + sin(time*400.0)*w;
    
    return vec2( s*ll/(ll+rr), s*rr/(ll+rr) );
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    fragColor=vec4(mainSound(iTime),0.0,0.0);
}