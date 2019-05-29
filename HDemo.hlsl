

uniform float iTime;
uniform float2 iTexCoord;



float3 CreatTails(float radius,float angle,float iTime,float len,float baselight,float3 tailsColor){

    float f4=(max(len,radius)-radius)*2.0;
    float k1=sin(angle+iTime-len*30.0)+0.7;

    float3 TrailColor=baselight+tailsColor*(k1)*(0.7+0.5*sin(iTime*2.0+len*100.0));
    return TrailColor*f4*k1;
}






float3 main()
{
	float2 center=float2(0.5,0.5);

	float2 r=iTexCoord-center;
	float len=length(r);

	
	float radius1=0.1;
	float f1=max(1.0-abs(pow((len-radius1)/radius1,2.0)),0.0);
	float f2=pow(f1,2.0);
	float f3=2.0;

	float f=f1*f2*f3;

	float3 CenterColor=float3(0.1,0.5,1.0);
	
	float radius2=0.1;
	float f4=(max(len,radius2)-radius2)*2.0;

	float angle=acos((r).x/len)*3.0;
	float k1=sin(angle*sign(r.y)+iTime*1.0-len*30.0)+0.7;
	float3 TrailColor1=float3(0.2,0.2,0.2+k1*(0.7+0.3*sin(iTime*2.0+len*100.0)));



	float3 FragColor=CenterColor*f+TrailColor1*f4*k1;
	return  FragColor;
}