
#define PI 3.141592654

float logic(vec2 uv){


  float f2 = 1.0/((1.0+exp(uv.x))*(1.0+exp(uv.y)));
  return f2;
}
vec2 logic2d(vec2 uv){

  float f1=1.0/(1.0+exp(uv.x));
  float f2=1.0/(1.0+exp(uv.x));
  return vec2(f1,f2);
}
float fract2s(float st){
  float f1=fract(st)-0.5;
  return abs(f1*2.0);
}

float wave(vec2 st,vec2 center,float rotate){
 

  st=vec2(st.x*cos(rotate)+st.y*sin(rotate),st.y*cos(rotate)-st.x*sin(rotate));
  st=st-center;
  float len=length(st);
  float color=sin(len*10.0-iTime)*0.6;
  color+=sin(st.x*15.0+iTime*2.0)*0.3;
  color+=sin(st.y*26.0-iTime*3.0)*0.15;
  return color;
}

vec2 addBias(vec2 uv)
{
  float f1=sin(fract2s(uv.x*1.121+123.12)*PI);
  float f2=sin(fract2s(uv.y*1.121+323.71)*PI);
  return vec2(f1+f2,f2-f1);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord){

  vec2 uv=fragCoord.xy/iResolution.xy-0.5;
  uv=uv*1.0;
  vec4 baseColor=vec4(1.0,0.5,0.3,0.0);



  float w1=wave(uv,addBias(uv),0.0)*0.7;
  float w2=wave(vec2(uv.x,-uv.y),vec2(w1),PI*0.3)*0.7;
  float w3=wave(vec2(-uv.x,-uv.y),vec2(w2),PI*0.5)*0.7;
  float w4=wave(vec2(-uv.x,uv.y),vec2(w3),PI*0.7)*0.7;

  float res=(w1+w2+w3+w4)/3.0;
  // float res=max(max(w1,w2),w3);
  fragColor= vec4((1.0-baseColor).xyz*res,0.8);
}
