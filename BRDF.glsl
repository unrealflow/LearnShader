#ifndef _B_R_D_F_
#define _B_R_D_F_

#define MOD2 vec2(3.07965, 3.4235)

float D_x[20] = float[20](0.000000f, 0.500000f, 0.250000f, 0.750000f, 0.125000f, 0.625000f, 0.375000f, 0.875000f, 0.062500f, 0.562500f, 0.312500f, 0.812500f, 0.187500f, 0.687500f, 0.437500f, 0.937500f, 0.031250f, 0.531250f, 0.281250f, 0.781250f );
float D_y[20] = float[20]( 0.000000f, 0.333333f, 0.666667f, 0.111111f, 0.444444f, 0.777778f, 0.222222f, 0.555556f, 0.888889f, 0.037037f, 0.370370f, 0.703704f, 0.148148f, 0.481482f, 0.814815f, 0.259259f, 0.592593f, 0.925926f, 0.074074f, 0.407407f );

float noise11( float a )
{
    vec2 p=vec2(a,sin(a * 930.1 + 4929.7) * (a+23.3280));
	vec2 p2 = fract(vec2(p) / MOD2);
    p2 += dot(p2.yx, p2.xy+19.19);
	return fract(p2.x * p2.y);
}

const float PI = 3.14159265359;
struct Mat
{
    float metallic;
    float roughness;
};
vec3 fresnelSchlick(float cosTheta, vec3 F0)
{
    // return F0 + (1.0 - F0) * pow(1.0 - cosTheta, 5.0);
    return F0 + (1.0 - F0) * exp2((-5.55473*cosTheta-6.98316)*cosTheta);
}
float DistributionGGX(vec3 N, vec3 H, float roughness)
{
    float a      = roughness*roughness;
    float a2     = a*a;
    float NdotH  = max(dot(N, H), 0.0);
    float NdotH2 = NdotH*NdotH;

    float nom   = a2;
    float denom = (NdotH2 * (a2 - 1.0) + 1.0);
    denom = PI * denom * denom;

    return nom / denom;
}

float GeometrySchlickGGX(float NdotV, float roughness)
{
    float r = (roughness + 1.0);
    float k = (r*r) / 8.0;

    float nom   = NdotV;
    float denom = NdotV * (1.0 - k) + k;

    return nom / denom;
}
float GeometrySmith(vec3 N, vec3 V, vec3 L, float roughness)
{
    float NdotV = max(dot(N, V), 0.0);
    float NdotL = max(dot(N, L), 0.0);
    float ggx2  = GeometrySchlickGGX(NdotV, roughness);
    float ggx1  = GeometrySchlickGGX(NdotL, roughness);

    return ggx1 * ggx2;
}
vec3 BRDF(Mat mat, vec3 v_color, vec3 L, vec3 V, vec3 N)
{
    vec3 H = normalize(V + L);

    vec3 F0 = vec3(0.04);
    F0 = mix(F0, v_color, mat.metallic);
    
    float NDF = DistributionGGX(N, H, mat.roughness);       
    float G   = GeometrySmith(N, V, L, mat.roughness);
    vec3 F = fresnelSchlick(max(dot(H, V), 0.0), F0);

    vec3 nominator = NDF * G * F;
    float denominator = 4.0 * max(dot(N, V), 0.0) * max(dot(N, L), 0.0) + 0.001;
    vec3 specular = nominator / denominator;

    vec3 kD = vec3(1.0) - F;
    kD *= 1.0 - mat.metallic;

    float NdotL = max(dot(N, L), 0.0);        
    vec3 Lo = (kD * v_color / PI + specular) * NdotL;

    return Lo;
}

#endif