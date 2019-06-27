




vec3 rotate(vec3 _input,vec2 uv)
{
    return sin(_input+sin(iTime+uv.x*20.0)*1.3).zxy+sin(_input+sin(iTime+uv.y*20.0)*1.3).yzx;
}



void mainImage(out vec4 fragColor, in vec2 fragCoord){
  vec2 uv=fragCoord/iResolution.xy-.5;
    vec3 baseColor=vec3(uv,0.0);
    float ap=1.0;
    for(int i=0;i<3;i++)
    {
        baseColor=ap*rotate(baseColor,uv);
        ap*=0.8;
    }

  fragColor=vec4(baseColor,1.0);
  // fragColor=wave1;
}
