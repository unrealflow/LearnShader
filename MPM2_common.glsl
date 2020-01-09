#define PI 3.141592654
#define BIAS 0.5

const int p_size=10;
const float radius= 0.01;

ivec2 GetIndices(vec2 fragCoord)
{
    return ivec2(fragCoord-BIAS);
}
vec2 GetUV(ivec2 indices)
{
    return (vec2(indices)+BIAS)/iResolution.xy;
}
vec2 Rot(vec2 v, float angle)
{
    return vec2(v.x * cos(angle) + v.y * sin(angle),
        v.y * cos(angle) - v.x * sin(angle));
}