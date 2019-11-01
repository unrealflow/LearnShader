
float fun(vec2 uv){
  vec4 baseColor=vec4(0.1,0.3,0.8,1.0);
  const float c1=2.33;
  const float c2=3.12;
  const float c3=4.33;
  const float c4=1.2344;
  float f1=sin(uv.x*c1+uv.y*c2-iTime);
  float f2=sin(uv.y*c1+uv.x*c2+iTime);

  float f3=sin((uv.x+f2)*c3*f2+(uv.y+f1)*(f1+f2)*c4);
  float f4=sin((uv.y-f2)*c3*(f1+f2)+(uv.x-f1)*f3*c4);
  return (f3+f4);
}


vec4 wave(vec2 st){
  const int OCTAVES=4;
  // Initial values
  float value=0.;
  float amplitude=.5;
  //
  // Loop of octaves
  for(int i=0;i<OCTAVES;i++){
    value+=amplitude*abs(fun(st));
    st*=2.;
    amplitude*=.5;
  }
  value=value*4.-.2;
  vec4 color=vec4(vec3(value),1.);
  color=color*vec4(1.,.3,.2,1.);
  color=1.-color;
  color.w=1.;
  return color;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord){
  vec2 uv=fragCoord/iResolution.xy-.5;
  uv=uv*1.;
  vec4 wave1=wave(uv);
  vec4 wave2=wave(vec2(uv.x,-uv.y));
  vec4 wave3=wave(vec2(-uv.x,-uv.y));
  vec4 wave4=wave(vec2(-uv.x,uv.y));
  fragColor=.25*wave1+.25*wave2+.25*wave3+.25*wave4;
  // fragColor=wave1;
}
