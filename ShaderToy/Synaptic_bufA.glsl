// Synaptic by nimitz (twitter: @stormoid)
// https://www.shadertoy.com/view/MdG3Dd
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License
// Contact the author for other licensing options

//Velocity handling
#iChannel0 "self"
#iChannel1 "file://./ShaderToy/image/noise_256.png"
const float initalSpeed = 10.;
#define time iTime

vec3 hash3(vec3 p)
{
    p = fract(p * vec3(443.8975,397.2973, 491.1871));
    p += dot(p.zxy, p.yxz+19.1);
    return fract(vec3(p.x * p.y, p.z*p.x, p.y*p.z))-0.5;
}

vec3 update(in vec3 vel, vec3 pos, in float id)
{   
    vel.xyz = vel.xyz*.999 + (hash3(vel.xyz + time)*2.)*7.;
    
    float d = pow(length(pos)*1.2, 0.75);
    vel.xyz = mix(vel.xyz, -pos*d, sin(-time*.55)*0.5+0.5);
    
    return vel;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 q = fragCoord.xy / iResolution.xy;
    
    vec4 col= vec4(0);
    vec2 w = 1./iResolution.xy;
    
    vec3 pos = texture(iChannel0, vec2(q.x,100.*w)).xyz;
    vec3 velo = texture(iChannel0, vec2(q.x,0.0)).xyz;
    velo = update(velo, pos, q.x);
    
    if (fragCoord.y < 30.)
    {
    	col.rgb = velo;
    }
    else
    {
        pos.rgb += velo*0.002;
        col.rgb = pos.rgb;
    }
	
    //Init
    if (iFrame < 10) 
    {
        if (fragCoord.y < 30.)
        	col = ((texture(iChannel1, q*1.0))-.5)*10.;
        else
        {
            col = ((texture(iChannel1, q*1.0))-.5)*.5;
        }
    }
    
	fragColor = col;
}