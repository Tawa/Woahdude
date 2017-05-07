#ifdef GL_ES
precision mediump float;
#endif

uniform float time;
uniform vec2 mouse;
uniform vec4 color;
uniform vec2 resolution;

float iGlobalTime = time;
vec2 iResolution = resolution;

// built for the Ello gif contest:
// https://ello.co/medialivexello/post/gif-exhibition
// Converted by Batblaster

#define PI 3.141592653589793
#define TAU 6.283185307179586

// from iq / bookofshaders
float cubicPulse( float c, float w, float x ){
	x = abs(x - c);
	if( x>w ) return 0.0;
	x /= w;
	return 1.0 - x*x*(3.0-2.0*x);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	float time = iGlobalTime * 0.55;
	float rainbowSpeed = 5.0;
	float colIntensity = 0.15;
	
	//////////////////////////////////////////////////////
	// Create tunnel coordinates (p) and remap to normal coordinates (uv)
	// Technique from @iq: https://www.shadertoy.com/view/Ms2SWW
	// and a derivative:   https://www.shadertoy.com/view/Xd2SWD
	vec2 p = (-iResolution.xy + 2.0*fragCoord)/iResolution.y;		// normalized coordinates (-1 to 1 vertically)
	vec2 uvOrig = p;
	// added twist by me ------------
	float rotZ = 1. - 0.23 * sin(1. * cos(length(p * 1.5)));
	p *= mat2(cos(rotZ), sin(rotZ), -sin(rotZ), cos(rotZ));
	//-------------------------------
	float a = atan(p.y,p.x);												// angle of each pixel to the center of the screen
	float rSquare = pow( pow(p.x*p.x,4.0) + pow(p.y*p.y,4.0), 1.0/8.0 );	// modified distance metric (http://en.wikipedia.org/wiki/Minkowski_distance)
	float rRound = length(p);
	float r = mix(rSquare, rRound, 0.5 + 0.5 * sin(time * 2.)); 			// interp between round & rect tunnels
	vec2 uv = vec2( 0.3/r + time, a/3.1415927 );							// index texture by (animated inverse) radious and angle
	//////////////////////////////////////////////////////
	
	// subdivide to grid
	uv += vec2(0., 0.25 * sin(time + uv.x * 1.2));			// pre-warp
	uv /= vec2(1. + 0.0002 * length(uvOrig));
	vec2 uvDraw = fract(uv * 12.);							// create grid
	
	// draw lines
	float col = cubicPulse(0.5, 0.06, uvDraw.x);
	col = max(col, cubicPulse(0.5, 0.06, uvDraw.y));
	
	// darker towards center, light towards outer
	col = col * r * 0.8;
	col += colIntensity * length(uvOrig);
	// NEW!
	// sine function creates monotonous sweep across color band, phase differences of 0, 120 and 240 degrees are added
	fragColor = vec4(vec3(col * sin(time*rainbowSpeed), col * sin(time*rainbowSpeed + 2.0*(PI/3.0)), col * sin(time*rainbowSpeed + 4.0*(PI/3.0))), 1.) + color;
}

void main( void ) {
	
	mainImage(gl_FragColor,gl_FragCoord.xy);
	
}
