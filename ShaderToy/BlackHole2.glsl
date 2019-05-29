// "Second Image of a Black Hole" by Martijn Steinrucken aka BigWings - 2019
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
// Email:countfrolic@gmail.com Twitter:@The_ArtOfCode
//
// In honor of the amazing achievement of the photographing of a real black hole,
// behold my 100% fake one. I know next to nothing about black holes other than
// that it distorts spacetime so much that it visibly affects light.
//
// Just marching the light rays and bending them towards the hole bulges the accretion disc
// over the top when you look at it from the side, similar to the way it looked in
// interstellar. I didn't specifically code this, it just came out that way
// so I figure my 'physics' is not completely wrong ;)
//
// The jets coming out the top and bottom I just added because lots of black hole 
// illustrations have them and they look cool :)
//
// Code is a bit of a mess. It annoys me that step size has to be super small in order
// for it to look halfway decent. 

#define SURFDIST .001
#define MAXSTEPS 200
#define MAXDIST 20.
#define TAU 6.2832

#define USEDISC
#define USESTREAM

mat2 Rot(float a) {
	float s = sin(a), c = cos(a);
    
    return mat2(c, -s, s, c);
}

float N21(vec2 p) {
    p = fract(p*vec2(123.34,345.35));
    p += dot(p, p+34.53);
    return fract(p.x*p.y);
}

float Noise(vec2 p) {
	vec2 gv = fract(p);
    vec2 id = floor(p);
    
    gv = smoothstep(0.,1.,gv);
    
    float b = mix(N21(id+vec2(0,0)), N21(id+vec2(1, 0)), gv.x);
    float t = mix(N21(id+vec2(0,1)), N21(id+vec2(1, 1)), gv.x);
    
    return mix(b, t, gv.y);
}

float Noise3(vec2 p) {
    return 
        (Noise(p) + 
        .50*Noise(p*2.12*Rot(1.)) +
        .25*Noise(p*4.54*Rot(2.)))/1.75;
}

vec3 GetRd(vec2 uv, vec3 ro, vec3 lookat, vec3 up, float zoom, inout vec3 bBend) {
    vec3 f = normalize(lookat-ro),
        r = normalize(cross(up, f)),
        u = cross(f, r),
        c = ro + zoom * f,
        i = c + uv.x*r + uv.y*u,
        rd = normalize(i-ro);
 	
    vec3 offs = normalize(uv.x*r + uv.y*u);
    bBend = rd-.1*offs/(1.+dot(uv,uv));
    return rd;   
}

vec3 GetBg(vec3 rd) {
	float x = atan(rd.x, rd.z);
    float y = dot(rd, vec3(0,1,0));
    
    float size = 10.;
    vec2 uv = vec2(x, y)*size;
    float m = abs(y);
    
    float side = Noise3(uv);
    float stars = pow(Noise(uv*20.)*Noise(uv*23.), 10.);
    
    vec2 puv = rd.xz*size;
    float poles = Noise3(rd.xz*size);
    float stars2 = pow(Noise(puv*21.)*Noise(puv*13.), 10.);
    
    stars = mix(stars, stars2, m*m);
    float n = mix(side, poles, m*m);
    n = pow(n, 5.);
    
    vec3 nebulae = n * vec3(1., .7, .5);
    
    return nebulae + stars*4.;
}

float GetDist(vec3 p) {
    float d = length(p)-.15;
    
    //d = min(d, max(length(p.xz)-2., abs(p.y)));
    return d;
}

float GetDisc(vec3 p, vec3 pp) {
	
    float t = iTime;
    
    // calculate plane intersection point
    vec3 rd = p-pp;			// local ray direction
    vec3 c = pp + rd*pp.y;	// intersection point
    rd = normalize(rd)*.5;
    p = c-rd;
    rd *= 2.;
    
    // myeah this seemed like a good idea at some point... doesn't add as much as it should
    float m = 0.;
    const float numSamples = 3.;
    for(float i=0.; i<1.; i+=1./numSamples) {
    	c = p + i*rd;
        
        float d = length(c.xz);
    	float l = smoothstep(3.5, .6, d);
    	l *= smoothstep(.1, .6, d);
    	
        float x = atan(c.x, c.z);
    	l *= sin(x*floor(5.)+d*20.-t)*.3+.7;
        m += l;
    }
    
    return 1.5*m/numSamples;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = (fragCoord-.5*iResolution.xy)/iResolution.y;
	vec2 m = iMouse.xy/iResolution.xy;
    
    vec3 col = vec3(0);
	
    vec3 ro = vec3(0, 0, -4.+sin(iTime*.2));
    ro.yz *= Rot(m.y*TAU+iTime*.05);
    ro.xz *= Rot(-m.x*TAU+iTime*.1);
    
    vec3 lookat = vec3(0);
    float zoom = .8;
    vec3 up = normalize(vec3(.5, 1,0));
    vec3 bBend;
    vec3 rd = GetRd(uv, ro, lookat, up, zoom, bBend);
    vec3 eye = rd;
    
    float dS, dO;
    float disc = 0.;
    vec3 p=ro;
    p += N21(uv)*rd*.05;
    vec3 pp;
    
    float stream = 0.;
    
    for(int i=0; i<MAXSTEPS; i++) {
        rd -= .01*p/dot(p,p);		// bend ray towards black hole
        
        pp = p;
        p += dS*rd;
        
        if(p.y*pp.y<0.)
            disc += GetDisc(p, pp);
        
        float y = abs(p.y)*.2;
        stream += smoothstep(.1+y, 0., length(p.xz))*
            smoothstep(0., .2, y)*
            smoothstep(1., .5, y)*.05;
        
        dS = GetDist(p);
        dS = min(.05, dS);
        dO += dS;
        if(dS<SURFDIST || dO>MAXDIST) break;
    }
    
    col = GetBg(bBend);
    
    if(dS<SURFDIST) {
        col = vec3(0);      // its black!
    }
    
    #ifdef USEDISC
    col += disc*vec3(1,.8,.5)*1.5;
    #endif
    #ifdef USESTREAM
    col += min(.5, stream)*vec3(.7, .7, 1.);
    #endif
    
    fragColor = vec4(col,1.0);
}