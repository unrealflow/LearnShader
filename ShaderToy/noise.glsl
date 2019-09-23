// Created by inigo quilez - iq/2013
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
 
// Gradient Noise (http://en.wikipedia.org/wiki/Gradient_noise), not to be confused with
// Value Noise, and neither with Perlin's Noise (which is one form of Gradient Noise)
// is probably the most convenient way to generate noise (a random smooth signal with 
// mostly all its energy in the low frequencies) suitable for procedural texturing/shading,
// modeling and animation.
//
// It produces smoother and higher quality than Value Noise, but it's of course slighty more
// expensive.
//
// The princpiple is to create a virtual grid/latice all over the plane, and assign one
// random vector to every vertex in the grid. When querying/requesting a noise value at
// an arbitrary point in the plane, the grid cell in which the query is performed is
// determined (line 32), the four vertices of the grid are determined and their random
// vectors fetched (lines 37 to 40). Then, the position of the current point under 
// evaluation relative to each vertex is doted (projected) with that vertex' random
// vector, and the result is bilinearly interpolated (lines 37 to 40 again) with a 
// smooth interpolant (line 33 and 35).
 
// 算法解析：创建一个由若干虚拟晶格组成的平面，接着给每个晶格的顶点赋予一个随机的向量（通过hash函数生成），
// 然后通过fract函数将该点平移到【x:0-1, y:0-1】的空间中，再计算到各个晶格顶点的距离向量，
// 然后将这两个向量进行dot，最后dot的结果利用ease curves（即u）进行双线性插值。
 
// 注意：Gradient Noise并不是Value Noise，也不是Perlin Noise，而是基于Perlin Noise的一种分形布朗运动
//（Fractal Brownian Motion,FBM）的叠加
 
vec2 hash22( vec2 p )
{
	p = vec2( dot(p,vec2(127.1,311.7)),
			  dot(p,vec2(269.5,183.3)) );
 
	return -1.0 + 2.0*fract(sin(p)*43758.5453123);
}
 
float hash21(vec2 p)
{
	return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
    //vec3 p3  = fract(vec3(p.xyx) * .1931);
    //p3 += dot(p3, p3.yzx + 19.19);
    //return fract((p3.x + p3.y) * p3.z);
}
 
// =================================================================================
 
float noise( in vec2 p )
{
    vec2 i = floor( p );
    vec2 f = fract( p );
	
    // Ease Curve
	//vec2 u = f*f*(3.0-2.0*f);
    vec2 u = f*f*f*(6.0*f*f - 15.0*f + 10.0);
 
    return mix( mix( dot( hash22( i + vec2(0.0,0.0) ), f - vec2(0.0,0.0) ), 
                     dot( hash22( i + vec2(1.0,0.0) ), f - vec2(1.0,0.0) ), u.x),
                mix( dot( hash22( i + vec2(0.0,1.0) ), f - vec2(0.0,1.0) ), 
                   dot( hash22( i + vec2(1.0,1.0) ), f - vec2(1.0,1.0) ), u.x), u.y);
    
    //return dot(hash22(i+vec2(0.0, 0.0)), f-vec2(0.0, 0.0));
    //return dot(hash22(i+vec2(1.0, 0.0)), f-vec2(1.0, 0.0));
    //return mix(dot(hash22(i+vec2(0.0, 0.0)), f-vec2(0.0, 0.0)),
    //           dot(hash22(i+vec2(1.0, 0.0)), f-vec2(1.0, 0.0)), u.x);
    
    //return dot(hash22(i+vec2(0.0, 1.0)), f-vec2(0.0, 1.0));
    //return dot(hash22(i+vec2(1.0, 1.0)), f-vec2(1.0, 1.0));
    //return mix(dot(hash22(i+vec2(0.0, 1.0)), f-vec2(0.0, 1.0)),
    //           dot(hash22(i+vec2(1.0, 1.0)), f-vec2(1.0, 1.0)), u.x);
}
 
float noise_fractal(in vec2 p)
{
	p *= 5.0;
    mat2 m = mat2( 1.6,  1.2, -1.2,  1.6 );
	float f  = 0.5000*noise(p); p = m*p;
	f += 0.2500*noise(p); p = m*p;
	f += 0.1250*noise(p); p = m*p;
	f += 0.0625*noise(p); p = m*p;
    
    return f;
}
 
 
float noise_sum_abs(vec2 p)
{
    float f = 0.0;
    p = p * 7.0;
    f += 1.0000 * abs(noise(p)); p = 2.0 * p;
    f += 0.5000 * abs(noise(p)); p = 2.0 * p;
    f += 0.2500 * abs(noise(p)); p = 2.0 * p;
    f += 0.1250 * abs(noise(p)); p = 2.0 * p;
    f += 0.0625 * abs(noise(p)); p = 2.0 * p;
 
    return f;
}
 
float value_noise(vec2 p)
{
    p *= 56.0;
    vec2 pi = floor(p);
    //vec2 pf = p - pi;
    vec2 pf = fract(p);
 
    vec2 w = pf * pf * (3.0 - 2.0 * pf);
 
    // 它把原来的梯度替换成了一个简单的伪随机值，我们也不需要进行点乘操作，
    // 而直接把晶格顶点处的随机值按权重相加即可。
    return mix(mix(hash21(pi + vec2(0.0, 0.0)), hash21(pi + vec2(1.0, 0.0)), w.x),
              mix(hash21(pi + vec2(0.0, 1.0)), hash21(pi + vec2(1.0, 1.0)), w.x),
              w.y);
}
 
float simplex_noise(vec2 p)
{
    const float K1 = 0.366025404; // (sqrt(3)-1)/2;
    const float K2 = 0.211324865; // (3-sqrt(3))/6;
	// 变换到新网格的(0, 0)点
    vec2 i = floor(p + (p.x + p.y) * K1);
	// i - (i.x+i.y)*K2换算到旧网格点
    // a:变形前输入点p到该网格点的距离
    vec2 a = p - (i - (i.x + i.y) * K2);
    vec2 o = (a.x < a.y) ? vec2(0.0, 1.0) : vec2(1.0, 0.0);
    // 新网格(1.0, 0.0)或(0.0, 1.0)
    // b = p - (i+o - (i.x + i.y + 1.0)*K2);
    vec2 b = a - o + K2;
    // 新网格(1.0, 1.0)
    // c = p - (i+vec2(1.0, 1.0) - (i.x+1.0 + i.y+1.0)*K2);
    vec2 c = a - 1.0 + 2.0 * K2;
	// 计算每个顶点的权重向量，r^2 = 0.5
    vec3 h = max(0.5 - vec3(dot(a, a), dot(b, b), dot(c, c)), 0.0);
    // 每个顶点的梯度向量和距离向量的点乘，然后再乘上权重向量
    vec3 n = h * h * h * h * vec3(dot(a, hash22(i)), dot(b, hash22(i + o)), dot(c, hash22(i + 1.0)));
	
    // 之所以乘上70，是在计算了n每个分量的和的最大值以后得出的，这样才能保证将n各个分量相加以后的结果在[-1, 1]之间
    return dot(vec3(70.0, 70.0, 70.0), n);
}
 
// -----------------------------------------------
 
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 p = fragCoord.xy / iResolution.xy;
 
	vec2 uv = p * vec2(iResolution.x/iResolution.y,1.0);
	
	float f = 0.0;
	
    // 1: perlin noise	
	if( p.x<0.2 )
	{
		f = noise( 16.0 * uv );
	}
    // 2: fractal noise (4 octaves)
    else if(p.x>=0.2 && p.x<0.4)	
	{
		f = noise_fractal(uv);
	}
    // 3：fractal abs noise
    else if(p.x>=0.4 && p.x<0.6)
    {
    	f = noise_sum_abs(uv);
    }
    // 4: value noise
    else if(p.x>=0.6 && p.x<0.8)
    {
    	f = value_noise(uv);
    }
    // 5:simplex_noise
    else
    {
    	f = simplex_noise(16.0*uv);
    }
 
	f = 0.5 + 0.5*f;
	
    // // 分割线：注意如果第三个参数超过了限定范围就不进行插值
    // f *= smoothstep(0.0, 0.005, abs(p.x-0.2));
    // f *= smoothstep(0.0, 0.005, abs(p.x-0.4));	
	// f *= smoothstep(0.0, 0.005, abs(p.x-0.6));
    // f *= smoothstep(0.0, 0.005, abs(p.x-0.8));
    
	fragColor = vec4( f, f, f, 1.0 );
}