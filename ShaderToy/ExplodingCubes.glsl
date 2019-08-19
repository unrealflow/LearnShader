
// Exploding Cubes by Kali 

//#define set4x4x4
#define set5x5x5
//#define set6x6x6

#ifdef set4x4x4
	#define cubes 64
	#define cubesize 0.75
#endif

#ifdef set5x5x5
	#define cubes 125
	#define cubesize 0.6
#endif

#ifdef set6x6x6
	#define cubes 216
	#define cubesize 0.5
#endif


#define lightdir normalize(vec3(0.,-0.5,1.))

// pseudorandom function
float rand(vec2 co){
	return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

// 3D rotation function
mat3 rotmat(vec3 v, float angle)
{
	float c = cos(angle);
	float s = sin(angle);
	
	return mat3(c + (1.0 - c) * v.x * v.x, (1.0 - c) * v.x * v.y - s * v.z, (1.0 - c) * v.x * v.z + s * v.y,
		(1.0 - c) * v.x * v.y + s * v.z, c + (1.0 - c) * v.y * v.y, (1.0 - c) * v.y * v.z - s * v.x,
		(1.0 - c) * v.x * v.z - s * v.y, (1.0 - c) * v.y * v.z + s * v.x, c + (1.0 - c) * v.z * v.z
		);
}

// cube intersection function
bool cube ( in vec3 p, in vec3 dir, in vec3 pos, in float size, inout vec2 startend, inout vec3 side, inout vec3 hit)
{
	float fix=.00001;
	vec3 minim=pos-vec3(size)*.5;
	vec3 maxim=pos+vec3(size)*.5;
	vec3 omin = ( minim - p ) / dir;
	vec3 omax =( maxim - p ) / dir;
	vec3 maxi= max ( omax, omin );
	vec3 mini = min ( omax, omin );
	startend.y = min ( maxi.x, min ( maxi.y, maxi.z ) );
	startend.x = max ( max ( mini.x, 0.0 ), max ( mini.y, mini.z ) );
	float rayhit=0.;
	if (startend.y-startend.x>fix) rayhit=1.;
	hit=p+startend.x*dir;
	// get normal
		side=vec3(0.,0.,-1.);
		if (abs(hit.x-minim.x)<fix) side=vec3( 1., 0., 0.);
		if (abs(hit.y-minim.y)<fix) side=vec3( 0., 1., 0.);
		if (abs(hit.z-minim.z)<fix) side=vec3( 0., 0., 1.);
		if (abs(hit.x-maxim.x)<fix) side=vec3(-1., 0., 0.);
		if (abs(hit.y-maxim.y)<fix) side=vec3( 0.,-1., 0.);
	return rayhit>0.5;
}


// main code
void mainImage( out vec4 fragColor, in vec2 fragCoord )

{
	vec2 uv = gl_FragCoord.xy / iResolution.xy-.5;
	uv.y*=iResolution.y/iResolution.x;

	//ray origin and direction
	vec3 rdir=vec3(uv*1.8,1.);
	vec3 rori=vec3(0.,0.,-10.);

	vec3 col=vec3(.59); // background

	// variables
	vec2 startend, nearest=vec2(1000.,0.);
	vec3 normal, hitpos, chitpos, cpos, cnor;
	float hit=0.;
	mat3 crot;
	float root3=floor(pow(float(cubes),1./3.));

	// time manipulation
	float cyc=mod(iTime,15.);
	float shake=clamp(cyc,3.,5.);
	if (cyc<5.) rori+=sin(shake*1000.)*.05*(shake-3.); //shake it baby!!
	float ti=5.-abs(max(0.,cyc-5.)-5.);
	if (cyc>10.) ti=pow(ti/5.,3.)*5.;
	
	// camera rotation
	mat3 camrot=rotmat(normalize(vec3(1.,0.5,ti*.5)),iTime);
	
	// ratrace cubes
	for (int i=0; i<cubes; i++) {	
		// get cube id
		vec3 posid=vec3(floor(float(i)/float(cubes)*root3), 
					  mod(floor(float(i)/root3),root3),
					  mod(float(i),root3));
		
		// get cube position
		vec3 pos=posid*cubesize-cubesize*root3*.5+cubesize*.5;
		
		// random aceleration
		float r=rand(posid.xy*20.25684265+posid.z*38.56485);
		
		// variable for animating the explosion
		float anim=ti*(.25+r*3.)*(1.+length(pos)*.3);
		
		// rotation matrix for the cube
		mat3 rot=camrot*rotmat(normalize(vec3(pos)),anim*2.*sign(r-.5));
		
		// intersect cube and find nearest hit, then save useful data
		bool intersect=cube(rori*rot, rdir*rot, pos*(1.+anim), cubesize*.9, startend, normal, hitpos);
		if (length(pos)>.01 && intersect && startend.x<nearest.x) {
			nearest=startend;
			cpos=posid;
			chitpos=hitpos;
			cnor=normal;
			hit=1.;
			crot=rot;
		}
	}	
	
	// color and lighting if we hit a cube
	if (hit>0.5) {
		// external light shading
		col=(.05+cpos/root3)*(max(0.,dot(cnor,lightdir*crot))*1.3+.15*(1.-sign(ti)));				
		vec3 r = reflect(vec3(0.,0.,1.)*crot,cnor);
		col+=pow(max(0.,dot(lightdir*crot,-r)),30.)*.5;				

		// explosion light shading
		vec3 expdir=normalize(chitpos);
		float expbri=(shake-3.)*(2.-sign(ti)*1.5);
		col+=vec3(1.,.8,.5)*expbri*(max(0.,dot(cnor,expdir))*1.5+sign(ti)*.2);				
		r = reflect(vec3(0.,0.,1.)*crot,cnor);
		col+=pow(max(0.,dot(expdir,-r)),30.)*expbri;				
		
		// distance fading
		col=mix(vec3(.5),col,exp(-.0007*pow(nearest.x,3.)));
	}
	// explosion shine
	float et=pow(ti,.7)+.1;
	float e=pow(max(0.,et-length(uv)-abs(sin(-iTime*8.+atan(uv.x,uv.y)*6.))*.025)/et,5.);
	col=mix(col,col+vec3(e,e*e,e*e*e*.6),clamp((nearest.x-9.)*.3,0.,1.));

	// explosion flash
	if (cyc>5. && cyc<5.1) col+=vec3(.5);
	
	// gamma correction
	col=pow(col,vec3(1.3));

	fragColor = vec4(col,1.0);
}