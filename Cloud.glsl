
vec2 Rot(vec2 v, float angle)
{
    return vec2(v.x * cos(angle) + v.y * sin(angle),
        v.y * cos(angle) - v.x * sin(angle));
}

vec2 map(vec3 pos)
{
    float cl = dot(pos.xy, pos.xy);
    float density = 1.0;
    float fre = 1.0;
    float ap = 0.5;
    float timeSpeed = 0.3;
    vec3 kp = vec3(pos);
    kp.z *= 5.2;
    kp.xy=Rot(kp.xy,sin(0.1*iTime+pos.z));
    for (int i = 0; i < 5; i++) {
        
        kp += sin(kp.zxy * 0.75 * fre + timeSpeed * iTime);
        density -= abs(dot(cos(kp), sin(kp.yzx)) * ap);
        fre *= 1.79;
        ap *= 0.47;
    }
    density += 0.1 * (cl);
    density = smoothstep(0.0, 3.0, density);
    return vec2(density*density*density, cl);
}


vec3 RayMarch(vec2 coord)
{
    vec3 baseColor = vec3(0.2,0.5,1.0);
    vec3 fogColor = 0.3*vec3(0.2,0.5,1.0);
    vec3 orientation = normalize(vec3(coord, 1.0));

    vec3 pos = vec3(coord, 0.0);
    vec3 color = vec3(0.0);
    float alpha = 0.0;
    float trace = 5.0;
    float len = length(coord);
    vec3 stage=vec3(0.6);
    // float depth=0.1+1.0/(len+1e-5);
    // float depth2=0.1+1.0/(len+0.1);
    for (int i = 0; i < 4; i++) {

        vec2 k = map(pos + (trace) * orientation);
        
        vec3 stage1 = baseColor* k.x*(1.0 - alpha) ;
        // stage=mix(stage,stage1,0.5);
        color+=(1.0-alpha)*mix(color,stage1,1.0-alpha);
        alpha += (1.0-alpha)*k.x;
        trace += 1.0;
    }
    //
    // float fogC=pow(0.95,depth);
    color=mix(fogColor,color,alpha);
    return color;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{

    vec2 uv = fragCoord.xy / iResolution.xy;
    vec2 coord = uv * 2.0 - 1.0;
    coord.x *= iResolution.x / iResolution.y;

    vec3 color = RayMarch(coord);

    // float fogC = pow(0.97, k.x);
    // vec3 fogColor = vec3(0.7);
    // baseColor = mix(fogColor, baseColor, fogC);
    fragColor = vec4(color, 1.0);
}