
// uniform vec3 iResolution; // viewport resolution (in pixels) 
// uniform float iGlobalTime; // shader playback time (in seconds) 
// uniform float iChannelTime[4]; // channel playback time (in seconds) 
// uniform vec3 iChannelResolution[4]; // channel resolution (in pixels) 
// uniform vec4 iMouse; // mouse pixel coords. xy: current (if MLB down), zw: click 
// uniform samplerXX iChannel0..3; // input channel. XX = 2D/Cube 
// uniform vec4 iDate; // (year, month, day, time in seconds) 
// uniform float iSampleRate; 
#define PI 3.141592654
vec4 CreatTails(float radius2,float angle,float iTime,float len,float baselight,vec4 tailsColor,float sep){

    float f4=(1.0-len)*1.2*(max(len,radius2)-radius2)*2.0;
    float k1=sin(angle+iTime-len*20.0)+0.7;

    vec4 TrailColor=baselight+tailsColor*(k1)*(0.7+sep*sin(iTime*2.0+len*100.0));
    return TrailColor*f4*k1;
}


void main()
{
    vec2 uv = gl_FragCoord.xy/iResolution.xy;
    float tran=iResolution.x/iResolution.y;
    vec2 center =vec2(0.5,0.5);

    float iTime=iGlobalTime*1.0;
    vec2 r=uv-center;
    r=vec2(r.x,r.y/tran)*1.0;
    float len=length(r);
    

    float angle=acos((r).x/len)*sign(r.y);
    float radius1=0.05;
    float f1=max(1.0-abs(pow((len-radius1)/radius1,2.0)),0.0);
    float f2=pow(f1,2.0);
    
    float f3=2.0;
    float f=f1*f2*f3;


    vec4 centerColor=vec4(0.0,0.5,1.0,1.0);
    

    vec4 tailsColor=vec4(0.0,0.5,2.0,1.0);
    vec4 tailsColor2=vec4(0.7,1.2,1.0,1.0);
    // len=len*pow((1.5-len),2.0);
    vec4 TrailColor1=CreatTails(0.1,angle*3.0,iTime*0.5,len,0.2,tailsColor,0.1)*0.3;
    TrailColor1+=CreatTails(0.0,angle*6.0,iTime*2.5,len,0.2,tailsColor,0.1)*0.3;
    TrailColor1+=CreatTails(0.2,angle*8.0,iTime*1.5,len,0.2,tailsColor2,0.0)*0.4;


    gl_FragColor=centerColor*f+TrailColor1;
}