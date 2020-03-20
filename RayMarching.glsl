#define PI 3.141592654

const vec3 _origin =vec3(0.0,0.0,-2.0);
const vec3 _front=normalize(vec3(0.0,0.0,1.0));
const vec3 _up=normalize(vec3(0.0,1.0,0.0));

vec2 Rot(vec2 v, float angle)
{
    return vec2(v.x * cos(angle) + v.y * sin(angle),
        v.y * cos(angle) - v.x * sin(angle));
}

vec3 RayGen(vec2 coord)
{
    vec3 _right=cross(_front,_up);
    
    vec3 dir=normalize(_front+_up*coord.y+_right*coord.x);
    return dir;
}

float SDF_sphere(vec3 pos,out vec3 N)
{
    float radius=0.5;
    vec3 location=vec3(0.0,-0.0,0.0);
    N=normalize(pos-location);
    return distance(location,pos)-radius;
}
float SDF_cube(vec3 pos,out vec3 N)
{
    vec3 rX=vec3(0.5,0.0,0.0);
    vec3 rY=vec3(0.0,0.5,0.0);
    vec3 rZ=vec3(0.0,0.0,0.5);
    vec3 center=vec3(0.0,-0.0,0.0);
    vec3 D=pos-center;
    float tx=abs(dot(D,rX))/rX.x-rX.x;
    float ty=abs(dot(D,rY))/rY.y-rY.y;
    float tz=abs(dot(D,rZ))/rZ.z-rZ.z;

    if(tx>ty){
        if(tx>tz){
            N=sign(dot(D,rX))*normalize(rX);
            return tx;
        }else
        {
            N=sign(dot(D,rZ))*normalize(rZ);
            return tz;
        }
    }else
    {
        if(ty>tz)
        {
            N=sign(dot(D,rY))*normalize(rY);
            return ty;
        }else
        {
            N=sign(dot(D,rZ))*normalize(rZ);
            return tz;
        }
    }
    return tx;
}

vec3 fbm_noise(vec3 pos,float ft)
{
    vec3 kp=pos;
    float fre=1.0;
    float ap=0.5;
    vec3 d=vec3(1.0);
    for(int i=0;i<3;i++)
    {
        // kp=mix(kp,kp.yzx,0.1);
        kp+=sin(0.75*kp.zxy * fre+ft*iTime);
        d -= abs(cross(sin(kp), cos(kp.zxy)) * ap);
        fre*=1.9;
        ap*=0.5;
    }
    return vec3(abs(d-0.5));
}
vec3 RayMain(vec2 uv,float aspect)
{
    vec2 coord=uv*2.0-1.0;
    coord.y/=aspect;

    // vec3 dir=RayGen(coord);
    vec3 dir=_front+vec3(coord,0.0);
    float fmin=0.1;
    float fmax=100.0;
    float f=fmin;
    vec3 res=vec3(0.0);
    for(int i=0;i<20;i++)
    {
        if(f>fmax)
        {
            return vec3(0.0);
        } 
        vec3 p=_origin+f*dir;
        vec3 N;
        float k=SDF_sphere(p,N);
        if(abs(k)<0.01)
        {
            // return vec3(1.0)*dot(-dir,N);
            return res;
        }
        vec3 fn=fbm_noise(p*10.0,0.5);
        f+=k*0.3*(dot(fn,fn.zxy));
        // f+=k*0.8;
        res+=(1.0-res)*0.3*fn;
    }
    return res;
}
vec3 RayCloud(vec2 uv,float aspect)
{
    vec2 coord=uv*2.0-1.0;
    coord.y/=aspect;

    
    float fmin=0.1;
    float fmax=100.0;
    float f=fmin;
    float stride=0.5;
    vec3 res=vec3(0.0);
    for(int i=0;i<20;i++)
    {
        vec3 dir=RayGen(coord);
        if(f>fmax)
        {
            return vec3(0.0);
        } 
        vec3 p=_origin+f*dir;
        // p*=2.0;
        vec3 color=fbm_noise(p,0.2);
        float color2=fbm_noise(p*0.5+100.0,0.1).x;
        color*=smoothstep(0.1,0.9,color2);

        res+=(1.0-res)*color*0.5;
       
        f+=stride;
        // coord=Rot(coord,0.01*iTime);
    }

    return res;
}
void mainImage(out vec4 fragColor,in vec2 fragCoord)
{
    vec2 uv=fragCoord/iResolution.xy;
    vec3 color=vec3(uv,0.0);
    float aspect=iResolution.x/iResolution.y;
    color=RayMain(uv,aspect);
    // color=RayCloud(uv,aspect);
    fragColor=vec4(color,1.0);
}
