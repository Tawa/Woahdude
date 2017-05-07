#ifdef GL_ES
precision mediump float;
#endif

uniform float time;
uniform vec2 mouse;
uniform vec4 color;
uniform vec2 resolution;
const float PI = 3.141592;

void main( void ) {
	
	vec2 p = ( gl_FragCoord.xy - 0.5 * resolution.xy ) / resolution.x;
	
	float theta = atan(p.y, p.x);
	float a = theta / PI * 0.5 + 0.5;
	float k = sin(theta * 5.0 + PI) * 0.05;
	float r = 0.1;
	vec2 q = vec2( r * cos(theta * 50.0 + PI + time), r * sin(theta * 51.0 + PI) );
	
	float c = length(p) + sin(k);
	c = abs(dot(normalize(q), p));
	c = smoothstep(0.3, 0.31, c);
	
	gl_FragColor = vec4( vec3( c ) * color.rgb, 1.0 );
	
}
