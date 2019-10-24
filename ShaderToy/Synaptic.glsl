// Synaptic by nimitz (twitter: @stormoid)
// https://www.shadertoy.com/view/MdG3Dd
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License
// Contact the author for other licensing options

//Code is in the other tabs:
//Buf A = Particle velocity and position handling
//Buf B = Rendering

#iChannel0 "file://./ShaderToy/Synaptic_bufB.glsl"
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	fragColor = vec4(texture(iChannel0, fragCoord.xy/iResolution.xy).rgb, 1.0);
}