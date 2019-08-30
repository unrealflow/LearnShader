#define PI 3.141592654

vec3 noise(vec2 uv)
{
    float pTime = floor(2.0*iTime);
    float n_1 = sin(uv.x + pTime) * 20.*PI;
    float n_2 = sin(n_1 + uv.y + pTime) * 20.*PI;
    float n_3 = sin(n_1*uv.x+n_2*uv.y+n_2+n_1)*20.*PI;
    float n_4 = sin(n_2*uv.x+n_3*uv.y+n_2+n_3)*20.*PI;
    return vec3(sin(n_4), cos(n_4),sin(n_3+n_4));
}

void main()
{
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    gl_FragColor = vec4(noise(uv), 1.0);
}