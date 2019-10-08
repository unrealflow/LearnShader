#iChannel0 "self"
#define PI 3.141592654

const vec3 origin=vec3(0.0,0.0,-1.0);
const float radius=10.0;
const float maxDepth=60.0;
vec3 rotz(vec3 ro,float angle)
{
    vec3 o;
    o.x=ro.x*cos(angle)-ro.y*sin(angle);
    o.y=ro.y*cos(angle)+ro.x*sin(angle);
    o.z=ro.z;
    return o;
}
float sdf(vec3 pos,float fre,float bias)
{
    float theta=sign(pos.x)*PI*0.5+atan(pos.y/pos.x);
    float t=cos(theta*fre+pos.z*10.5+bias);
    t=(t+1.0)*0.5;
    return radius-length(pos.xy)-t*1.1;
}

vec2 map(in vec3 ro,in float rd, in float ds)
{
    vec3 pos=origin+ro*rd;
    float a=exp(-ds);
    float c=sin(ds*2.0*PI);
    c=clamp(-0.1,1.0,c);
    return vec2(c,a);
}
vec4 draw(vec3 ro)
{
    vec3 baseColor=vec3(1.0,0.4,0.0);
    vec3 fogColor=vec3(0.0,1.0,1.0);
    float rd=0.0;
    vec2 f=vec2(0.0);
    float tp=0.1;
    float fre=1.0;
    for(int i=0;i<10;i++)
    {
        ro=rotz(ro,float(i)+tp*iTime);
        tp*=-0.5;
        vec3 pos=origin+ro*rd;
        float ds=0.0;
        ds+=sdf(pos,8.0*fre+sin(float(i)*PI),0.1);
        fre*=2.0;
        if(ds<0.1||f.y>1.0){
            break;
        }
        vec2 rez=map(ro,rd,ds);
        f.x+= rez.x*(1.0-f.y);
        f.y+=rez.y;
        rd+=ds*1.0;
    }
    float p=smoothstep(0.0,maxDepth,rd);
    return vec4(mix(f.x*baseColor,fogColor,p),1.0);

}


void mainImage(out vec4 fragColor, in vec2 fragCoord){

    vec2 uv = fragCoord / iResolution.xy;
    float f = iResolution.x / iResolution.y;
    vec2 coord = uv * 2.0 - vec2(1.0);
    coord.x *= f;
    // ray orientation
    vec3 ro=normalize(vec3(coord,1.0));
    

    fragColor=draw(ro)*0.1+0.9*vec4(texture(iChannel0,uv).xyz,1.0);

}
