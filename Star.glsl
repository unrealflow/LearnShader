#define PI 3.141592654

void main(){

    vec2 uv=gl_FragCoord.xy/iResolution.xy-0.5;

    float len=length(uv);
    float angle=PI-acos(uv.x/len)*sign(uv.y);
    
    float f1=0.8;
    float f2=9.0;
    float f3=0.02;
    float f4=f3/(f3+abs(sin(len*f2*3.0)));
    float f5=f3/(f3+abs(sin(angle*f2)));
    float f6=max(f4*f5-0.05*len,0.0)*100.0;
    vec4 baseColor=vec4(0.0,0.3,0.7,1.0);

    gl_FragColor=baseColor*f6;
}