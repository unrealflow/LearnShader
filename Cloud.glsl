
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
    float timeSpeed = 0.9;
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
    vec3 baseColor = vec3(0.8,0.8,1.0);
    vec3 fogColor = 0.3*vec3(0.4,0.4,1.0);
    vec3 orientation = normalize(vec3(coord, 1.0));

    vec3 pos = vec3(coord, 0.0);
    vec3 color = vec3(0.0);
    float alpha = 0.0;
    float trace = 3.0;
    float len = length(coord);
    vec3 stage=vec3(0.6);
    float fogC=1.0;
    for (int i = 0; i < 20; i++) {

        vec3 _pos=pos + (trace) * orientation;
        vec2 k = map(_pos);
        vec2 k1=map(_pos+0.09);
        vec2 k2=map(_pos-0.09);

        
        vec3 stage1 = baseColor;

        stage1=mix(stage1,vec3(1.0,0.5,0.0),0.3*(k1.x+k2.x-k.x))* k.x;

        float fog_cur=pow(0.9,trace);
        stage1=mix(stage1,fogColor,(fogC-fog_cur));
        fogC=fog_cur;
        stage1*=(1.0 - alpha) ;
        color+=(1.0-alpha)*mix(color,stage1,1.0-alpha);
        alpha += (1.0-alpha)*k.x;
        trace += 1.0;
    }
    color=mix(fogColor*8.0,color,alpha);
    return color;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{

    vec2 uv = fragCoord.xy / iResolution.xy;
    vec2 coord = uv * 2.0 - 1.0;
    coord.x *= iResolution.x / iResolution.y;

    vec3 color = RayMarch(coord);

    fragColor = vec4(color, 1.0);
}