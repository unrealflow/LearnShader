#iChannel0 "self"
#define PI 3.141592654

uint GetIndex(vec2 fragCoord)
{
    return uint(fragCoord.y * iResolution.x + fragCoord.x);
}
vec2 Rot(vec2 v, float angle)
{
    return vec2(v.x * cos(angle) + v.y * sin(angle),
        v.y * cos(angle) - v.x * sin(angle));
}
float RadicalInverse(uint Base, uint i)
{
    float Digit, Radical, Inverse;
    Digit = Radical = 1.0 / float(Base);
    Inverse = 0.0;
    while (i > 0U) {
        Inverse += Digit * float(i % Base);
        Digit *= Radical;

        i /= Base;
    }
    return Inverse;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 uv = fragCoord / iResolution.xy;
    uint index = GetIndex(fragCoord - 0.5);
    if (index > 1000U) {
        fragColor = vec4(0.0);
        return;
    }
    if (iFrame < 2) {
        float x = RadicalInverse(2U, index);
        float y = RadicalInverse(3U, index);
        vec2 p = vec2(x, y) * 0.5 + 0.25;
        fragColor = vec4(p, normalize((p - 0.5)));
        return;
    }

    vec4 data = texture(iChannel0, uv);
    vec2 pos = data.xy;
    vec2 dir = data.zw;

    pos = pos + dir * 0.003;
    dir = Rot(dir, 0.003 * length(dir) * cos(0.1399 * float(index)));

    if (iMouse.w > 0.1) {
        vec2 pd = iMouse.xy / iResolution.xy - pos;
        vec2 fa = cos(length(pd)) * normalize(pd);
        dir += 0.03 * fa;
    } else {
        float kt=iTime*1.0;
        vec2 pd = 0.5+0.3*vec2(cos(kt),sin(kt)) - pos;
        vec2 fa = cos(length(pd)) * normalize(pd);
        dir += 0.02 * fa*(1.0+cos(kt*0.3));
    }

    if (pos.x < 0.0 || pos.x > 1.0) {
        pos.x = fract(2.0 - pos.x);
        dir.x = -dir.x;
    }
    if (pos.y < 0.0 || pos.y > 1.0) {
        pos.y = fract(2.0 - pos.y);
        dir.y = -dir.y;
    }
    if (length(dir) > 1.0) {
        dir *= 0.99;
    }else
    {
        dir*=1.01;
    }
    fragColor = vec4(pos, dir);
}