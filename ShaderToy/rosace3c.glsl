// code golfed variant of (305 chars) https://shadertoy.com/view/Ms3SzB

// -5 by iapafoto

#define mainImage(O,u)                     \
    vec2 R = .1*iResolution.yy,            \
         U = .4*u/R,                       \
         K = ceil(U);                      \
    U = fract(U)-.5;                       \
    for( float i=0., A; i++ < 7.; )        \
        O = max(O,  sqrt( 1.3 + cos( A= K.x/K.y*(atan(U.y,U.x)+i*6.28) + iTime) ) * min(R/16.-R*abs(length(U)-.1*sin(A)-.25),.6).y) 
                   
void main()
{
    mainImage(gl_FragColor,gl_FragCoord.xy);
}      
                   
                   
/*
        

        
// -4 by iapafoto  -1 by Fab

#define mainImage(O,u)                     \
    vec2 R = iResolution.yy,               \
         U = 4.*u/R,                       \
         K = ceil(U);                      \
    U = fract(U)-.5;                       \
    for( float i=0., A; i++ < 7.; )        \
        O = max(O,   sqrt( 1.3 + cos( A= K.x/K.y*(atan(U.y,U.x)+i*6.28) + iTime) ) *.6 \
                   * min(R.y/50.*(.5- abs(8.*length(U)-.8*sin(A)-2.)), 1.)) 

/*




// 224 chars - init Fab version
       
#define mainImage(O,u)                     \
    vec2 R = iResolution.yy,               \
         U = 4.*u/R,                       \
         K = ceil(U);                      \
    U = fract(U)-.5;                       \
    for( float i=0., A; i++ < 7.; )        \
        O = max(O,   sqrt( 1.3 + cos( A= K.x/K.y*(atan(U.y,U.x)+i*6.28) + iTime) ) *.6 \
                   * min(R.y/50.*(.5- 8.*abs(length(U)-.1*sin(A)-.25)), 1.))  /*

*/