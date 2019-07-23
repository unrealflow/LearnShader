#iChannel0 "self"
#iChannel1 "file://./SegmentTrails_bufB.glsl"

float pi = 3.14159265358979323;
#define clamps(x) clamp(x, 0., 1.)
vec3 rX(vec3 p, float a)
{ //YZ
    float c, s;
    vec3 q = p;
    c = cos(a);
    s = sin(a);
    p.y = c * q.y - s * q.z;
    p.z = s * q.y + c * q.z;
    return p;
}
vec3 rY(vec3 p, float a)
{ //XZ
    float c, s;
    vec3 q = p;
    c = cos(a);
    s = sin(a);
    p.x = c * q.x + s * q.z;
    p.z = -s * q.x + c * q.z;
    return p;
}
vec3 rZ(vec3 p, float a)
{ //XY
    float c, s;
    vec3 q = p;
    c = cos(a);
    s = sin(a);
    p.x = c * q.x - s * q.y;
    p.y = s * q.x + c * q.y;
    return p;
}
vec2 dirDist(float dir, float dist)
{
    return vec2(cos(dir) * dist, sin(dir) * dist);
}
// "Converted" from "C++" from here: https://stackoverflow.com/questions/849211/shortest-distance-between-a-point-and-a-line-segment
float segment_distance(vec2 v, vec2 w, vec2 p)
{
    // Return minimum distance between line segment vw and point p
    float l = distance(v, w); // i.e. |w-v|^2 -  avoid a sqrt
    float l2 = l * l;
    //if (l2 == 0.0) return distance(p, v);   // v == w case
    // Consider the line extending the segment, parameterized as v + t (w - v).
    // We find projection of point p onto the line.
    // It falls where t = [(p-v) . (w-v)] / |w-v|^2
    // We clamp t from [0,1] to handle points outside the segment vw.
    float t = max(0.0, min(1.0, dot(p - v, w - v) / l2));
    vec2 projection = v + t * (w - v); // Projection falls on the segment
    return distance(p, projection);
}

vec3 animation(vec2 uv, float time, float timeDelta)
{
    float circles = 0.;
    for (float k = 0.; k < 8.; k++)
    {
        float i = (k / 7.) * pi;
        float prevtime = min(time, time - timeDelta + .0075); // 0.0075 to reduce double drawing
        float DIRECTION = time * k * 0.1;
        float PREVDIRECTION = prevtime * k * 0.1;
        float DISTANCE = 0.2;
        vec3 POSITION = vec3(dirDist((DIRECTION), (DISTANCE)), 0.);
        vec3 PREVPOSITION = vec3(dirDist((PREVDIRECTION), (DISTANCE)), 0.);
        PREVPOSITION = rY(PREVPOSITION, prevtime * 1.1);
        PREVPOSITION = rZ(PREVPOSITION, prevtime * 2.15);
        PREVPOSITION = rX(PREVPOSITION, prevtime * 0.52);
        POSITION = rY(POSITION, time * 1.1);
        POSITION = rZ(POSITION, time * 2.15);
        POSITION = rX(POSITION, time * 0.52);
        circles = max(circles, clamps(circles * 0.1 + 1. - (segment_distance(PREVPOSITION.xy, POSITION.xy, uv) * 40.)));
    }
    circles = clamp(circles, 0., 1.);
    return vec3(circles);
}
void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 uv = fragCoord.xy / iResolution.xy;
    vec2 suv = uv - .5;
    suv.x /= iResolution.y / iResolution.x;
    float time = iTime;
    float timeDelta = iTimeDelta;
    vec3 drawing = vec3(0.0);
    // if (0.37 < uv.x && 0.63 > uv.x && 0.27 < uv.y && 0.73 > uv.y)
    // {
    //     drawing = animation(suv, time, timeDelta);
    // }

    // drawing = vec3(pow(drawing, vec3(2.5, 1.8, 1.)));
    drawing = animation(suv, time, timeDelta);

    fragColor = vec4(drawing*vec3(0.3,0.7,1.0), 1.);
}