#define PI 3.141592654

uint GetIndex(vec2 fragCoord,vec2 iResolution)
{
    fragCoord-=0.5;
    return uint(fragCoord.y * iResolution.x + fragCoord.x);
}
vec2 GetUV(uint index,vec2 iResolution)
{
    float y=floor(float(index)/iResolution.x);
    float x=float(index)-y*iResolution.x;
    return (vec2(x,y)+0.5)/iResolution.xy;
}
// setting
// if FPS is low, the time_rate should be small;
const float time_rate=30.0;
const float time_begin=0.5;
const uint branch=2U;
const float stop_thre=0.3;
const float atten=0.8;
const float leaf_size=0.5;