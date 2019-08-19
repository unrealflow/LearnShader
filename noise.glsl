#iChannel0 "self"






float noise(float a)
{
    float k=fract(sin(1311.33*a+23.123+iTime*0.001)*13.1);
    return k;
}

vec3 noise3(vec2 uv)
{
    float t1=noise(uv.x);
    float t2=noise(uv.y);
    float t3=noise(t1+t2);
    return vec3(noise(t1*uv.x+t2*uv.y),noise(t3+uv.x),noise(t3+uv.y));
}
void main()
{
    //(0,0) ~(1,1)
    vec2 uv=gl_FragCoord.xy / iResolution.xy-vec2(0.5);
    //(0,0,0) ~(1,1,1)
    vec2 nk=2.0*noise3(uv).xy-vec2(1.0);
    nk=pow(nk,vec2(1.));
    float d=distance(uv,nk.xy);

    // gl_FragColor=0.5*texture(iChannel0,nk)+0.5*vec4(d);

    gl_FragColor=vec4(d);
}