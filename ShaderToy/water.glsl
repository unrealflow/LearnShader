#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform vec2 u_mouse;

float sdcircle(vec2 st,vec2 origin,float r){
  return length(st-origin)-r;
}

vec2 floor2d(vec2 st){
  return vec2(floor(st.x),floor(st.y));
}

vec2 fract2d(vec2 st){
  return vec2(fract(st.x),fract(st.y));
}

vec2 random2d(vec2 st){
  float r1=fract(sin(dot(st.xy,vec2(127.9898,311.233)))*43758.5453123);
  float r2=fract(sin(dot(st.xy,vec2(269.5,183.3)))*43758.5453123);
  return 2.*vec2(r1,r2)-1.;
}

float noise(vec2 st){
  vec2 i=floor2d(st);
  vec2 f=fract2d(st);
  
  vec2 a=random2d(i);
  vec2 b=random2d(i+vec2(1,0));
  vec2 c=random2d(i+vec2(0,1));
  vec2 d=random2d(i+vec2(1,1));
  
  vec2 u=smoothstep(0.,1.,f);
  
  float e=mix(dot(a,f),dot(b,f-vec2(1,0)),u.x);
  float g=mix(dot(c,f-vec2(0,1)),dot(d,f-vec2(1,1)),u.x);
  float h=mix(e,g,u.y);
  return h;
}

float fbm(vec2 st){
  const int OCTAVES=4;
  // Initial values
  float value=0.;
  float amplitude=.5;
  //
  // Loop of octaves
  for(int i=0;i<OCTAVES;i++){
    value+=amplitude*abs(noise(st));
    st*=2.;
    amplitude*=.5;
  }
  return value;
}

vec2 distort(vec2 uv){
  return uv+fbm(uv+vec2(.24,.025)+iTime*.125);
}

vec2 distort2(vec2 uv){
  return uv+fbm(uv+vec2(.12,.52)+iTime*.324);
}

vec4 wave(vec2 uv){
  uv=uv*2.;
  vec2 p=distort(uv);
  p=distort(p);
  float c=fbm(p);
  c=c*4.-.2;
  vec4 color=vec4(vec3(c),1.);
  color=color*vec4(1.,.5,.3,1.);
  color=1.-color;
  color.w=1.;
  return color;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord){
  vec2 uv=fragCoord/iResolution.xy-.5;
  uv=uv*1.;
  vec4 wave1=wave(uv);
  vec4 wave2=wave(vec2(uv.x,-uv.y)+1.5);
  vec4 wave3=wave(vec2(-uv.x,-uv.y)+3.);
  vec4 wave4=wave(vec2(-uv.x,uv.y)+4.5);
  fragColor=.25*wave1+.25*wave2+.25*wave3+.25*wave4;
}
