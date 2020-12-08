#include "BRDF.glsl"
#iChannel0 "self"
#iChannel1 "scene_GBuffer.glsl"

vec3 CalN(sampler2D GBuffer,vec2 uv,vec2 w)
{
    vec3 d=texture(GBuffer,uv).xyz;
    vec3 d_up=texture(GBuffer,uv+vec2(0.0,w.y)).xyz;
    vec3 d_down=texture(GBuffer,uv-vec2(0.0,w.y)).xyz;
    vec3 d_left=texture(GBuffer,uv-vec2(w.x,0.0)).xyz;
    vec3 d_right=texture(GBuffer,uv+vec2(w.x,0.0)).xyz;

    vec3 N1=cross(d_up-d,d_left-d);
    vec3 N2=cross(d_left-d,d_down-d);
    vec3 N3=cross(d_down-d,d_right-d);
    vec3 N4=cross(d_right-d,d_up-d);

    return -normalize(N1+N2+N3+N4);
}
float InScatter(vec3 start, vec3 rd, vec3 lightPos, float d)
{
    vec3 q = start - lightPos;
    float b = dot(rd, q);
    float c = dot(q, q);
    float iv = 1.0f / sqrt(c - b*b);
    float l = iv * (atan( (d + b) * iv) - atan( b*iv ));

    return l;
}
vec2 Pos2uv(vec3 pos,vec3 origin)
{
    vec3 dir=normalize(pos-origin);
    dir/=dir.z;
    vec2 coord=dir.xy;
    coord.x*=iResolution.y/iResolution.x;
    vec2 uv=(coord+1.0)/2.0;
    return uv;
}
float Shadow(sampler2D GBuffer,vec3 pos,vec3 origin,vec3 lightPos,int index)
{

    int rank=10;
    vec3 tdir=lightPos-pos;
    float maxPath=length(tdir);
    tdir=normalize(tdir);
    float k=1.1;
    float minstep=maxPath*(k-1.0)/(pow(k,float(rank))-1.0);

    float shadow=1.0;

    for(int i=0;i<rank;i++)
    {
        pos+=minstep*tdir*fract(D_x[index]+noise11(pos.x+pos.y+pos.z));
        vec2 uv=Pos2uv(pos,origin);
        if(uv.x<0.0||uv.x>1.0||uv.y<0.0||uv.y>1.0)
        {
            return 1.0;
        }
        float depth=texture(GBuffer,uv).z;
        if(depth<pos.z)
        {
            return 1.0-shadow;
        }
        minstep*=k; 
        shadow*=0.8;
    }

    return 1.0;
}
void mainImage(out vec4 fragColor, in vec2 fragCoord)
{ 
    vec2 w=1.0/iResolution.xy;
    vec2 uv = fragCoord.xy / iResolution.xy;
    vec2 coord = uv * 2.0 - 1.0;
    coord.x *= iResolution.x / iResolution.y;

    vec3 lightPos=vec3(-1.0,1.5,3.0);


    int index=iFrame%16;
    vec3 bias=vec3(float(index)/16.0,D_x[index],D_y[index]);
    bias=fract(bias+vec3(noise11(uv.x),noise11(uv.y),noise11(uv.x+uv.y)));
    bias=bias*2.0-1.0;
    vec3 lightPos2=lightPos+bias*0.1;

    Mat m;
    m.roughness=0.5;
    m.metallic=0.5;
    


    vec3 origin=vec3(coord,0.0);
    vec3 dir=normalize(vec3(coord,1.0));
    vec3 N=CalN(iChannel1,uv,w);
    vec3 pos = texture(iChannel1,uv).xyz;
    float dis=distance(pos,lightPos);

    vec3 L=normalize(lightPos-pos);
    vec3 V=-dir;
    vec3 v_color=vec3(1.0,0.9,0.6);
    vec3 l_color=vec3(0.03,0.75,0.97);
    l_color=1.0-0.2*l_color;
    float shadow=Shadow(iChannel1,pos,origin,lightPos2,index);
    vec3 p_color=l_color*shadow*20.0*BRDF(m,v_color,L,V,N)/(dis*dis+1e-5);

    
    // float klv=DistributionGGX(dir,normalize(lightPos-origin),0.1);
    // vec3 lightView=l_color*klv;
    // p_color=pos;
    vec3 sky_color=vec3(0.73,0.05,0.07);
    sky_color=1.0-0.4*sky_color;
    vec3 fogColor=0.3*sky_color+0.5*l_color;
    float k=InScatter(origin,dir,lightPos,pos.z)*0.3;

    // vec3 color=mix(p_color,fogColor,shadow*vec3(1.0-pow(0.9,pos.z)));
    vec3 color=mix(p_color,fogColor,k*shadow);


    // color=max(lightView,color);

    fragColor = vec4(color, 0.0);
    // fragColor = vec4(shadow);
    vec4 preColor=texture(iChannel0,uv);
    float fp=preColor.w+(1.0-preColor.w)*0.05;
    fp=min(0.98,fp);
    fragColor=mix(fragColor,preColor,fp);
    fragColor.w=fp;
    
}