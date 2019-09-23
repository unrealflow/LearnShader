/*
Shader coded live on twitch (https://www.twitch.tv/nusan_fx)
The shader was made using Bonzomatic.
After the stream, I fixed a major glitch in how I apply alpha, this is the fixed version.
You can find the original shader here: http://lezanu.fr/LiveCode/CityBorealis.glsl
Or the modify version for bonzomatic here: http://lezanu.fr/LiveCode/CityBorealis_v2
*/

float time=0.0;

mat2 rot(float a) {
  float ca=cos(a);
  float sa=sin(a);
  return mat2(ca,sa,-sa,ca);
}

float box(vec3 p, vec3 s) {
  p=abs(p)-s;
  return max(p.x, max(p.y,p.z));
}

vec3 repeat(vec3 p, vec3 s) {
  return (fract(p/s-0.5)-0.5)*s;  
}

vec2 repeat(vec2 p, vec2 s) {
  return (fract(p/s-0.5)-0.5)*s;  
}

float repeat(float p, float s) {
  return (fract(p/s-0.5)-0.5)*s;  
}

vec3 kifs(vec3 p, float t) {
  
  p.xz = repeat(p.xz, vec2(28));
  p.xz = abs(p.xz);
  
  vec2 s=vec2(10,7) * 0.6;
  for(int i=0; i<5; ++i) {
    p.xz *= rot(t);
    //p.xz = repeat(p.xz, vec2(28-i*0));
    p.xz = abs(p.xz) - s;
    p.y += 0.1*abs(p.z);
    s*=vec2(0.7,0.5);
  }
  
  return p;
}

vec3 kifs3d(vec3 p, float t) {
  
  p.xz = repeat(p.xz, vec2(17));
  p = abs(p);
  
  vec2 s=vec2(10,7) * 0.4;
  for(int i=0; i<5; ++i) {
    p.yz *= rot(t*0.7);
    p.xz *= rot(t);
    //p.xz = repeat(p.xz, vec2(28-i*0));
    p.xz = abs(p.xz) - s;
    //p.y += 0.1*abs(p.z);
    s*=vec2(0.7,0.6);
  }
  
  return p;
}

vec3 tunnel(vec3 p) {
  
  vec3 off=vec3(0);
  
  off.x += abs(repeat(p.z, 15.0))*0.5;
  off.x += abs(repeat(p.z, 19.0))*0.6;
  
  return off;
}

bool gold = false;
float goldvalue = 0.0;
float solid(vec3 p) {
  
  vec3 pp = p;
  pp += tunnel(p);
  float path = abs(pp.x)-1.5;
    
  vec3 p2 = kifs(p, 0.5);
  vec3 p3 = kifs(p+vec3(3,0,0), 1.91);
  
  float b1 = box(p2,vec3(1,1.3,0.5));
  float b2 = box(p3,vec3(0.5,1.3,1));
  
  float m1 = max(abs(b1), abs(b2)) - 0.2;
  
  float s1 = length(p2+vec3(0,1.4,0))-0.8;
  float s2 = length(p3+vec3(0,1.7,0))-0.9;
  float top = max(abs(abs(abs(s1)-0.1)-0.05),abs(s2))-0.02;
  goldvalue = top;
  
  m1 = min(m1,top);
  
  m1 = max(m1, -path);
  
  float d = m1;
  
  
  d = min(d, -p.y);
  
  //d *= 0.7;
  
  return d;
}

float rnd(float a) {
  return fract(sin(a*425.621)*342.512);
}

float curve(float t, float d) {
  float g=t/d;
  return mix(rnd(floor(g)),rnd(floor(g)+1.0), pow(smoothstep(0.0,1.0,fract(g)), 10.0));
}

float at=0.0;
float at2=0.0;
float at3=0.0;
float ghost(vec3 p) {
  
  p.y += 3.0;
  
  float off = time * 0.1 - p.z*0.09;
  
  vec3 p2 = kifs3d(p-vec3(0,2,3), 0.8 + curve(off, 0.3) + off*0.9);
  vec3 p3 = kifs3d(p-vec3(6,0,0), 1.2 + curve(off, 0.4) + off* 0.7);
  
  float b1 = box(p2,vec3(1));
  float b2 = box(p3,vec3(0.7));
  
  float m1 = max(abs(b1), abs(b2)) - 0.1;
  
  //float s1 = length(p2.xz)-0.3;
  float s1 = box(p2, vec3(0.3,10,0.5));
  float s2 = box(p3, vec3(10,0.4,0.5));
  
  float tt=time*0.3;
  /*
  at += 0.1/(0.02+abs(s1+sin(p.x*0.13 + tt)*0.5));
  at2 += 0.1/(0.02+abs(s2+cos(p.z*0.2 + tt)*0.5));
  at3 += 0.25/(0.2+abs(m1+sin(p.x*0.59 + tt)*0.4));
  */
  at = 0.1/(0.02+abs(s1+sin(p.x*0.13 + tt)*0.5));
  at2 = 0.1/(0.02+abs(s2+cos(p.z*0.2 + tt)*0.5));
  at3 = 0.25/(0.2+abs(m1+sin(p.x*0.59 + tt)*0.4));
  
  //m1 *= 0.7;
  
  return abs(m1);
  
}

bool isghost = true;
float map(vec3 p) {
  
  float sol = solid(p);
  
  float gho = ghost(p);
    
  isghost = gho<sol;
  float d = min(sol, gho);
  gold = goldvalue<d+0.01;
  //return gho;
  
  //d *= 0.7;
  
  return d;
}

float rnd(vec2 uv) {
  return fract(dot(sin(uv*724.512+uv.yx*568.577),vec2(342.814)));
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
  vec2 uv = vec2(fragCoord.x / iResolution.x, fragCoord.y / iResolution.y);
  uv -= 0.5;
  uv /= vec2(iResolution.y / iResolution.x, 1);
  
  time = mod(iTime, 200.0);

  vec3 s=vec3(0,-1.0,-3);
  vec3 t=vec3(0,-1.0 + sin(time*0.2)*0.5,0);
  
  float adv = time * 0.9;
  s.z += adv;
  t.z += adv;
  
  s -= tunnel(s);
  t -= tunnel(t);
  //s.xz *= rot(time*0.3);
  
  
  
  vec3 cz=normalize(t-s);
  vec3 cx=normalize(cross(cz, vec3(sin(time)*0.1,1,0)));
  vec3 cy=normalize(cross(cz, cx));
  
  vec3 r = normalize(uv.x*cx + uv.y*cy + cz);
  //vec3 r=normalize(vec3(-uv, 1));
  
  vec2 off=vec2(0.01,0);
  
  vec3 p=s;
  float dd=0.0;
  float maxdist=100.0;
  vec3 alpha=vec3(1);
  vec3 emi = vec3(0);
  float rand=mix(rnd(uv),1.0,0.9);
  float firsthit = maxdist;
      vec3 b1 = vec3(0);
  vec3 b2 = vec3(0);
  vec3 b3 = vec3(0);
  for(int i=0; i<100; ++i) {
    float d=map(p)*rand;
    if(abs(d)<0.003) {
      if(!isghost) {
        bool copygold = gold;
        vec3 n=normalize(d-vec3(map(p-off.xyy), map(p-off.yxy), map(p-off.yyx)));
        
        if(p.y>-0.02) {
          
          float d3 = map(p-vec3(0,2,0));
          //n.xz += sin(d3*vec2(10,0.3) + time*vec2(0.3,0.7)) * 0.3;
          float fac = 0.02 / max(1.0,abs(d3));
          n.x += sin(d3*45.0 + time) * 0.5 * fac;
          n.x += sin(d3*17.0 + time*3.0) * fac;
          n.z += sin(d3*23.0 + time*0.7) * 0.8 * fac;
          
          n = normalize(n);
          
        }
        
        float fre = pow(1.0-abs(dot(n,r)),1.0);
        r = reflect(r,n);
        //break;
        
        alpha *= fre;
        if(copygold) {
          //emi += vec3(1,0.9,0.5) * alpha*0.0;
          alpha *= vec3(1,0.9,0.5) * 2.0;
        }
        firsthit = min(firsthit, dd);
      }
      d = 0.1;
    }
    /*if(dd>maxdist) {
      dd=maxdist;
      break;
    }*/
      
    b1 += at * alpha;
    b2 += at2 * alpha;
    b3 += at3 * alpha;
      
    p+=r*d;
    dd+=d;
  }
  firsthit = min(firsthit, dd);
  
  vec3 sky = mix(vec3(0.7,0.5,1), vec3(0), pow(abs(r.y),0.4));
  
  vec3 col = vec3(0);
  //col += pow(1.0-float(i)/101.0,6.0);
  col += b1*0.005*vec3(0.3,0.5,1) * curve(time+12.2, 0.9);
  col += b2*0.013*vec3(0.4,0.7,0.5) * curve(time, 1.2);
  col += b3*0.014*vec3(0.8,0.2,0.5) * curve(time+17.4, 1.7);
  col += emi;
  float fog = pow(clamp(firsthit*3.0/maxdist,0.0,1.0),1.3);
  //col *= 1-fog;
  col += fog * sky *  1.0;
  
  fragColor = vec4(col, 1);
}