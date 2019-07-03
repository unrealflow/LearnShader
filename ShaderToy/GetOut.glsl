#define PI 3.1415926
#define EPSILON 0.001
const int MAX_STEPS = 100;
const float MAX_DISTANCE = 80.0;

struct Light {
    vec3 position;
    vec3 color;
};

struct Material {
    vec3 albedo;
    float metallic;
    float roughness;
    vec3 reflection;
    vec3 refraction;
};
    
struct Hit {
    float dist;
    int matIndex; //material info at the intersection point
};

float sdPlane( vec3 p, vec4 n )
{
  // n must be normalized
  return dot(p, n.xyz) + n.w;
}

float sphereSDF(vec3 p, float r) {
    return length(p) - r;
}

Hit unionSDF(Hit d1, Hit d2) 
{
    if (d1.dist < d2.dist) {
        return d1;
    } else {
        return d2;
    }  
}

vec3 doTranslate(vec3 p, vec3 offset) 
{
    return p - offset;
}

Hit sceneSDF(vec3 p) {
    Hit rst;
    
    vec3 p1 = doTranslate(p, vec3(10.0*cos(iTime), 1.0, 10.0*sin(iTime)));
    Hit is0 = Hit(sphereSDF(p1, 1.0), 1);
    p1 = doTranslate(p, vec3(1.0, 1.5, -2.0));
    Hit is1 = Hit(sphereSDF(p1, 1.5 ), 2);
    
    Hit is2 = Hit(sdPlane(p, vec4(0.0, 1.0, 0.0, 0.0)), 3);
    Hit is3 = Hit(sdPlane( p, vec4(0.0, 0.0, 1.0, 20.0)), 3);
    Hit is4 = Hit(sdPlane( p, vec4(1.0, 0.0, 0.0, 20.0)), 3);
    Hit is5 = Hit(sdPlane( p, vec4(-1.0, 0.0, 0.0, 20.0)), 3);
    Hit is6 = Hit(sdPlane( p, vec4(0.0, 0.0, -1.0, 20.0)), 3);
    
    rst = unionSDF(is0, is1);
    rst = unionSDF(rst, is2);
    rst = unionSDF(rst, is3);
    rst = unionSDF(rst, is4);
    rst = unionSDF(rst, is5);
    rst = unionSDF(rst, is6);
    return rst;
}

vec3 getNormal(vec3 p) {
    return normalize(vec3(
        sceneSDF(vec3(p.x + EPSILON, p.y, p.z)).dist - sceneSDF(vec3(p.x - EPSILON, p.y, p.z)).dist,
        sceneSDF(vec3(p.x, p.y + EPSILON, p.z)).dist - sceneSDF(vec3(p.x, p.y - EPSILON, p.z)).dist,
        sceneSDF(vec3(p.x, p.y, p.z  + EPSILON)).dist - sceneSDF(vec3(p.x, p.y, p.z - EPSILON)).dist
    ));
}

Hit marching(vec3 ro, vec3 rd) 
{
    float tmax = MAX_DISTANCE;
    float t = 0.001;
    Hit result = Hit(-1.0, -1);
    
    for (int i = 0; i < MAX_STEPS; i++)
    {
        vec3 p = ro + rd * t;
        Hit res = sceneSDF(p);
        if (res.dist < EPSILON)
        {
            return result;
        }
        else if (t > tmax)
        {
            result.matIndex = -1;
            result.dist = tmax;
            break;
        }
        t += res.dist;
        result.dist = t;
        result.matIndex = res.matIndex;
    }
    
    return result;
}

float calcShadow(in vec3 ro, in vec3 rd) {
    float mint = 0.1;
    float t = mint;
    float res = 1.0;
    float k = 4.0;
    for (int i = 0; i < 40; i++)
    {
        float h = sceneSDF(ro + rd * t).dist;
        
		res = min( res, k * h / t );
        t += clamp( h, 0.02, 0.20 );
     
        if ( h < EPSILON ) 
        {
            res = min(res, 0.0);
            break;
        } 
    }
    return clamp( res, 0.0, 1.0 );
}


float calcAO( in vec3 pos, in vec3 nor )
{
	float occ = 0.0;
    float sca = 1.0;
    float h = 0.001;
    for( float i = 0.0; i < 5.0; i++ )
    {
        float d = sceneSDF( pos + h * nor ).dist;
        occ += ( h - d ) * sca;
        sca *= 0.85;
        h += 0.45 * i / 5.0;
    }
    return clamp( 1.0 - occ, 0.0, 1.0 );    
}

//Fresnel/reflectivity
vec3 Fs(vec3 h, vec3 v, vec3 f0)
{
    float dothv = max(dot(h, v), 0.0);
    return max(f0 + (1.0 - f0) * pow((1.0 - dothv), 5.0), 0.0);
}

//Distribution/concentration
float D_GGX(float dotnh, float roughness) 
{
    float a = roughness * roughness;
    float a2 = a * a;
    float dotnh2 = dotnh * dotnh;
    float denom =  max(dotnh2 * (a2 - 1.0) + 1.0, EPSILON);
    return a2 /(PI * denom * denom);
}

float G_SGGX(float dotnv, float roughness)
{
    float r = roughness + 1.0; 
    float k = (r * r) / 8.0;
    return dotnv / (dotnv * (1.0 - k) + k);
}

//Geometry/shadowing masking
float G_Smith(float dotnv, float dotnl, float roughness)
{
    
    float ggx1 = G_SGGX(dotnv, roughness);
    float ggx2 = G_SGGX(dotnl, roughness);
    return ggx1 * ggx2;
}

//Fresnel/reflectivity
vec3 Fs(float dothv, vec3 f0)
{
    vec3 F = f0 + (1.0 - f0) * pow((1.0 - dothv), 5.0);
    return max(F, 0.0);
}

vec3 shading(vec3 ro, vec3 p, vec3 normal, Light lightInfo, inout Material mat) 
{
    vec3 Lo = vec3(0.0);
    
    //material and light
    vec3 albedo = mat.albedo; //vec3(0.2, 0.87, 0.6);
    float roughness = mat.roughness;
    float metallic = mat.metallic;
    vec3 lightDir = lightInfo.position - p;
    vec3 lightColor = lightInfo.color; 
    
    //calculating vectors
    vec3 viewDir = ro - p;
    vec3 V = normalize(viewDir);
    vec3 N = normal;
    vec3 L = normalize(lightDir);
    vec3 H = normalize(V + L);
    
    float dist = length(lightDir);

    float sd = calcShadow(p, L);
    float att = 1.0 / ( dist);
    vec3 radiance = lightColor * att * sd;

    float dothv = max(dot(H, V), 0.0);
    float dotnh = max(dot(N, H), 0.0);
    float dotnv = max(dot(N, V), 0.0);
    float dotnl = max(dot(N, L), 0.0);
      
    //fresnel
    vec3 f0 = vec3(0.04); 
    f0 = mix(f0, albedo, metallic);
    vec3 F = Fs(dothv, f0);
    
    //cook-torrance specualr term
    float D = D_GGX(dotnh, roughness);
    float GS = G_Smith(dotnv, dotnl, roughness);
    vec3 nom = D * GS * F;
    float denom = 4.0 * dotnv * dotnl;
    vec3 Fct = nom / max(denom, EPSILON); //avoid zero denom

    vec3 Ks = F; //reflect
    vec3 Kd = 1.0 - Ks; 
    Kd *= 1.0 - metallic; //diffuse
    vec3 Fl = albedo/PI; //lambert
    
    mat.reflection = Ks;
    
    Lo += (Kd * Fl + Fct) * radiance * dotnl; 
    
    float ao = calcAO(p, N);
    vec3 ambient = vec3(0.01) * albedo * ao;
    return ambient + Lo;
}

mat3 getCamera( in vec3 ro, in vec3 ta) {
	vec3 cw = normalize(ta-ro);
	vec3 cp = vec3(0.0, 1.0, 0.0);
	vec3 cu = normalize( cross(cw,cp) );
	vec3 cv =          ( cross(cu,cw) );
    return mat3( cu, cv, cw );
}

//hacks for non-constant index expression
Material getMaterial(int index) {
    Material mat[4];
    mat[0] = Material(vec3(1.0), 0.5, 0.1, vec3(0.0), vec3(0.0)); //white
    mat[1] = Material(vec3(0.5, 0.8, 0.5), 0.9, 0.2, vec3(0.0), vec3(0.0)); //green
    mat[2] = Material(vec3(0.9, 0.9, 0.2), 0.9, 0.2, vec3(0.0), vec3(0.0)); //yellow
    mat[3] = Material(vec3(0.8, 0.5, 0.5), 0.5, 0.3, vec3(0.0), vec3(0.0)); //pink
    if (index == 0) {
        return mat[0];
    } else if (index == 1) {
        return mat[1];
    } else if (index == 2) {
        return mat[2];
    } else if (index == 3) {
        return mat[3];
    }
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
    vec2 uv = fragCoord/iResolution.xy;
    uv -= 0.5; 
    uv.x *= iResolution.x/iResolution.y; 
    
    vec3 col = vec3(0.0);
    vec2 mouse = vec2(0.01) + iMouse.xy  / iResolution.xy ;
    mouse -= 0.5;
    
    vec3 ro = vec3(10.0 * cos(mouse.x * 2.0 * PI), 6.0 + 5.0 * mouse.y, 10.0 * sin(mouse.x * 2.0 * PI));
    vec3 ta = vec3(0.0, 4.0, 0.0);
    mat3 cam = getCamera(ro, ta);
    vec3 rd = normalize(cam * vec3(uv, 1.0));
     
    Light lightInfo = Light(vec3(5.0 * sin(iTime), 10.0, 2.0), vec3(200.0));
    
    Hit icp;
    vec3 nor = vec3(0.0);  
    vec3 ori = ro;
    vec3 dir = rd;
    vec3 interP = vec3(0.0);
    vec3 mask = vec3(1.0);
    float travelDist = 0.0; //calculate how far a ray travels
     
    for (float i = 0.0; i < 3.0; i++) {
        icp = marching(ori, dir);
        interP = ori + (icp.dist) * dir; //interception point
        travelDist += length(ori - interP);
        nor = getNormal(interP);
        if (icp.dist >= MAX_DISTANCE) {
            col += vec3(0.0);
        } else {
            Material mat = getMaterial(icp.matIndex);
            col += mask * shading(ori, interP, nor, lightInfo, mat);
            
            vec3 ref = reflect(dir, nor);
            ori = interP + EPSILON*ref;
            dir = ref;
            mask *= mat.reflection * 0.8;
        }
    }
    
    //col = col/(col + vec3(1.0)); //Reinhard tone mapping
    col = vec3(1.0) - exp(-col * 0.5);//exposure
	col = pow(col, vec3(1.0/2.2)); 
    fragColor = vec4(col,1.0);
}