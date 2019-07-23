const float maxIter = 40.;
const float fallSpeed = .7;
const float fallDuration = 3.;
const float spinSpeed = 2.;
const float stickiness = 0.9;// pushes exp curve back
const float maxRepDist = 1.;
const float minRepDist = .6;
const float sharpness = 800.;

const float pi = 3.141592;
const float pi2 = pi * 2.;

float rand(vec2 co)
{
    float a = 12.9898;
    float b = 78.233;
    float c = 43758.5453;
    float dt= dot(co.xy ,vec2(a,b));
    float sn= mod(dt,3.14);
    return fract(sin(sn) * c);
}
float nsin(float t) {return sin(t)*.5+.5; }

vec2 hash2( vec2 p )
{
    return fract(sin(vec2(dot(p,vec2(127.1,311.7)),dot(p,vec2(269.5,183.3))))*43758.5453);
}
float triWave(float x) {
    float ret = mod(x, pi2)/pi-1.;// -1 to 1
    ret = abs(ret);// 0-1
    ret -= .5;
    ret *= 2.;    
    return ret;
}

float dstar(vec2 uv, float p, float ir, float or, float phase, vec2 id) {
    float a = atan(uv.x,uv.y)/pi2+phase;
    float r = triWave(a*p*pi2)*.5+.5;// 0-1
    //r = pow(r, nsin(iTime)*4.+.5);
    r = pow(r, rand(id)*4.+.5);
    r *= or-ir;
    r += ir;
    return length(uv)-r;
}

float dtoa(float d, float amount){
    return 1. / clamp(d*amount, 1., amount);
}


void mainImage(out vec4 o, vec2 O)
{
    float t = iTime+1e3;
    vec2 R = iResolution.xy,
        V=(O-.5*R)/R.y
        ,N=O/R-.5// normalized coords (0-1)
        ,P=O-R*.5// screen space coords, centered
        ;
    V *= .7;
    
    t *= .1;
    V += iMouse.xy/iResolution.xy;
    float sgn = 1.;
    
    o = vec4(0.);
    vec2 moon = vec2(0,.3);
    float ma = dtoa(length(V-moon)-.1, 100.);
    float ma2 = dtoa(length(V-moon)-.1, 20.);
    for (float i = 0.; i <maxIter; ++ i) {
    	V.x += sgn * t;
       	sgn = -sgn;
        vec2 cent = vec2(-.5+rand(vec2(i, i+1.)), -.5+rand(vec2(i+2., i+3.)));// find a center; 
        vec2 off = cent;
        off *= 2.;// spread
        
        off.y -= exp(mod(t*fallSpeed + i*fallDuration/maxIter, fallDuration)-stickiness)-1.;// make them fall. -2 to hover longer near 0.

        float phase = rand(cent)-.5;
        phase *= spinSpeed;

        vec2 rep = hash2(cent)*(maxRepDist-minRepDist)+minRepDist;// ID
        vec2 repUV = mod(V-off, rep)-rep*.5;
        float d = dstar(repUV, 5., rep.x*.04, 0.008, t*phase*5., rep);
        vec4 thisColor;
        thisColor.rg = vec2(dtoa(d, sharpness*(i/maxIter))*(i/maxIter));// darken layers
        thisColor.b = d*.4;
        thisColor.rg *= rep*rep*rep*rep;
        
        thisColor *= (ma2*2.)+.2;
        o = max(o, thisColor);// mix
    }
    o += ma;
    
    // post
    o *= .8;
    o = clamp(o,0.,1.);
    o = pow(o,vec4(.5));
    o += (fract(sin(dot(R+t,N))*1e5)-.5)*.01;
    o *=1.4-dot(N,N);
    o *= 1.-step(.42,abs(N.y));
    o = clamp(o,0.,1.);
    o.a = 1.;
}





