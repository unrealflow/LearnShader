/*
Shader coded live on twitch (https://www.twitch.tv/nusan_fx)
The shader was made using Bonzomatic.
You can find the original shader here: http://lezanu.fr/LiveCode/SpaceJelly.glsl

The idea was to accumulate when near the surface to make the translucent parts.
*/

float time = 0.0;

float box(vec3 p, vec3 s) {
  p=abs(p)-s;
  return max(p.x, max(p.y,p.z));
}

mat2 rot(float a) {
  float ca=cos(a);
  float sa=sin(a);
  return mat2(ca,sa,-sa,ca);
}

float rnd(float t) {
  return fract(sin(t*467.355)*541.988);
}

float curve(float t, float d) {
  float g=t/d;
  float it=fract(g);
  it=smoothstep(0.,1.,it);
  it=smoothstep(0.,1.,it);
  it=smoothstep(0.,1.,it);
  return mix(rnd(floor(g)), rnd(floor(g)+1.), it);
}

float tick(float t, float d) {
  float g=t/d;
  float it=fract(g);
  it=smoothstep(0.,1.,it);
  it=smoothstep(0.,1.,it);
  it=smoothstep(0.,1.,it);
  return floor(g) + it;
}

vec3 lp=vec3(0);
float map(vec3 p) {
  
  p.xz *= rot(p.y*sin(time*12.5 + length(p.xz)*max(0.2,sin(time))*0.8)*0.02 * smoothstep(0.0,0.5,abs(fract(time*0.2)-.5)));
    
  float dist=100.0;
  p = (fract(p/dist+.5)-.5)*dist;

  float d=10000.0;
  float s=8.0 + curve(time, 0.7)*10.0;
  for(int i=0; i<5; ++i) {
    
    float t=tick(time, 0.8 + 0.7*float(i)) * 0.25;
    p.xy *= rot(t);
    p.yz *= rot(t*.7);
    p.xy=abs(p.xy);
    d=min(d, length(p.xz)-.1);
    p-=s;
    s *= 0.4;
  } 
  
  float d2 = box(p, vec3(1.5, 0.7, 0.3)*.5);
  lp=p;
    
  return min(d, d2);
}

float rnd(vec2 uv) {
  
  return fract(dot(sin(uv*784.565 + uv.yx*568.655), vec2(438.724)));
}

void cam(inout vec3 p) {
  
  float t=time*.4 + curve(time, 1.9) * 3.0;
  p.xy *= rot(t);
  p.yz *= rot(t*1.2);
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{    
  vec2 uv = vec2(fragCoord.x / iResolution.x, fragCoord.y / iResolution.y);
  uv -= 0.5;
  uv /= vec2(iResolution.y / iResolution.x, 1);
  
  uv *= 2.0/(0.7+length(uv));
  
  float time2 = iTime*1.0 + 23.0;
  time = tick(time2*0.3, 1.7) + time2*0.3;

  vec3 s=vec3(0,0,-50);
  vec3 r=normalize(vec3(-uv, 0.5 + curve(time, 0.8)));
  
  cam(s);
  cam(r);
  
  float dither = mix(1.0,rnd(uv + fract(time)),0.1);
  
  vec3 col = vec3(0);
   
  vec3 l=normalize(-vec3(1,3,2));
  vec2 off=vec2(0.01,0.0);
  
  float t2 = time*10.3;
  
  vec3 p=s;
  float dd=0.0;
  for(int i=0; i<100; ++i) {
    float d=map(p)*dither;
    float limit = sin(p.z*0.13 + t2) * 1.5 + 2.0;
    if(dd>200.0) break;
    if(d<limit) {
      float dist = 30.0;
      vec3 lp2 = (fract(lp/dist+.5)-.5)*dist;
      float factor = 0.02;
      //factor = (d<0.001) ? 0.5 : 0.02;
      vec3 n=normalize(map(p) - vec3(map(p-off.xyy), map(p-off.yxy), map(p-off.yyx)));
      if(dot(n,l)<0.0) l=-l;
      vec3 h=normalize(l-r);
      float f=pow(1.0-abs(dot(n,r)), 10.0);
      col += max(dot(n,l), 0.0) * factor * (0.3 + vec3(0.6,0.3,0.9)*5.0*pow(max(0.0,dot(n,h)), 10.0));
      col += vec3(0.2,0.5,1.0) * 4.0 * f * factor * (n.y*.5+.5);
      col += smoothstep(0.2,0.1, length(lp2.xz)) * factor * 10.0;
      if(d<0.01) {
        break;
      }
      d=0.2;
    }
    p+=r*d;
    dd+=d;
  }
  float fog = pow(1.0-clamp(dd/200.0,0.0,1.0), 2.0);
  float turn = fog*0.9 + time*.3;
  col.xy *= rot(turn);
  col.yz *= rot(turn*1.3);
  col = abs(col);
  col = mix(col, vec3(0.3,0.5,1.0)*dot(col, vec3(0.333)), 0.7);
  
  col *= 2.0;
  col *= 1.2 - length(uv);
    
  fragColor = vec4(col, 1);
}