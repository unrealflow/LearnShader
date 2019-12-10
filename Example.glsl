#iChannel0 "file://./ShaderToyShaderToy/image/1.jpg"


float cartoon(float _in){
  float temp=0.3;
  return max(ceil(_in/temp)*temp-temp/2.0,0.0);
}
vec3 cartoon(vec3 _in){
  return vec3(cartoon(_in.x),cartoon(_in.y),cartoon(_in.z));
}
vec3 cartoonLen(vec3 _in){
  float len=length(_in);
  return _in*(cartoon(len)/len);
}
void main(){
  // float ratio=iResolution.y/iResolution.x;
   float time = iGlobalTime * 1.0;
   vec2 uv0=gl_FragCoord.xy / iResolution.xy;
  vec2 uv = (uv0 - 0.5) * 8.0;
  float i0 = 1.0;
  float i1 = 1.0;
  float i2 = 1.0;
  float i4 = 0.0;
  for (int s = 0; s < 7; s++) {
    vec2 r;
    r = vec2(cos(uv.y * i0 - i4 + time / i1), sin(uv.x * i0 - i4 + time / i1)) / i2;
    r += vec2(-r.y, r.x) * 0.3;
    uv.xy += r;

    i0 *= 1.93;
    i1 *= 1.15;
    i2 *= 1.7;
    i4 += 0.05 + 0.1 * time * i1;
  }
  float r = sin(uv.x - time) * 0.5 + 0.5;
  float b = sin(uv.y + time) * 0.5 + 0.5;
  float g = sin((uv.x + uv.y + sin(time * 0.5)) * 0.5) * 0.5 + 0.5;
  gl_FragColor = vec4( cartoonLen(vec3(r,g,b)), 1.0);


  // uv0=uv0+vec2(r,b)*0.02;
  // gl_FragColor=texture2D(iChannel0,uv0);


  // vec2 center=vec2(0.5,0.5);
  // vec2 v=uv0-center;
  // // vec3 sub=vec3(v,0.0);
  // // vec2 bias=cross(sub,vec3(0.0,0.0,1.0)).xy;
  // float dist=length(v);

  // float g = sin((uv0.x + uv0.y + time * 0.5) * 0.5) * 0.5 + 0.5;
  // g=g*100.0;
  // float r = sin(uv0.x*100.0 - time+g) * 0.5 + 0.5;
  // float b = sin(uv0.y*100.0 + time+g) * 0.5 + 0.5;
  

  // uv0+=v*(pow(sin(dist*30.0-time*3.0),6.0))*0.1;
  // // uv0+=vec2(r,b)*0.02;
  // gl_FragColor=texture2D(iChannel0,uv0);
}