#iChannel0 "self"

#define PI 3.141592654

#define P_NUMS 10U
#define Radius 0.005
float RadicalInverse(uint Base, uint i)
{
    float Digit, Radical, Inverse;
    Digit = Radical = 1.0 / float(Base);
    Inverse = 0.0;
    while (i > 0U) {
        // i余Base求出i在"Base"进制下的最低位的数
        // 乘以Digit将这个数镜像到小数点右边
        Inverse += Digit * float(i % Base);
        Digit *= Radical;

        // i除以Base即可求右一位的数
        i /= Base;
    }
    return Inverse;
}
//半径1的圆
vec2 GetPoint(uint i)
{
    float a = RadicalInverse(3U, i) * 2.0 * PI;
    float b = RadicalInverse(5U, i);
    return vec2(b * sin(a), b * cos(a));
}
vec3 DrawPoint(vec2 center, vec2 coord)
{
    float l = distance(center, coord);
    vec3 color = vec3(0.3, 1.0, 0.0);

    float f = 1.0 - smoothstep(0.0, Radius * (1.0 + length(coord)), l);
    return color * f;
}
vec2 NoisePos(vec2 inPos, float fre, float bias)
{
    float p = iTime * fre*1.0 - bias;
    float f0 = sin(p + inPos.x * 2.0 * PI) * 2.0 * PI;
    float f1 = cos(p + inPos.y * 2.0 * PI) * 2.0 * PI;
    float f3 = sin(f1 + f0 * inPos.y * 2.0 * PI) * 2.0 * PI;
    float f4 = sin(f0 + f1 * inPos.x * 2.0 * PI);
    return vec2(f4 * sin(f3), f4 * cos(f3));
}
vec3 track(vec2 inPos, vec2 coord)
{
    vec2 pos = vec2(0.0);
    vec3 color = vec3(0.0);
    for (int i = 0; i < 20; i++) {
        float bias = 0.01 * float(i);
        pos = NoisePos(inPos, 0.02, (1.0001-length(pos))*0.002 * float(i));
        color += DrawPoint(pos, coord);
    }
    return color;
}

void main()
{
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    float f = iResolution.x / iResolution.y;
    vec2 coord = uv * 2.0 - vec2(1.0);
    coord.x *= f;
    vec3 color = vec3(0.0);

    for (uint i = 0U; i < P_NUMS; i++) {
        vec2 pos = GetPoint(i);
        vec3 tpColor = track(pos, coord);
        float fc = smoothstep(-0.7, 0.7, sin(iTime+float(i)));
        color += mix(tpColor, tpColor.zxy, fc);
    }
    color += texture(iChannel0, uv).xyz * 0.99;
    gl_FragColor = vec4(color, 1.0);
}