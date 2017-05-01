#ifdef GL_ES
precision mediump float;
#endif

uniform float time;
uniform vec2 mouse;
uniform vec4 color;
uniform vec2 resolution;

void main( void ) {
	vec2  pos = gl_FragCoord.xy;
	float index = 9.0;
	float accum = 0.1;
	float radius = min(resolution.x, resolution.y);
	float factor = 20.0/1280.0*resolution.x;
	
	vec2 center = resolution * 0.5;
	
	for( int i=0; i<50; i++) {
		index += 0.0250;
		
		vec2 sferePos = vec2(center.x + sin(time*index) * cos(time*(0.91-index*0.923)) * radius * 0.33,
							 center.y + cos(time*(0.0-index)) * radius * 0.33);
		
		accum += factor*sin(time*index)/distance(gl_FragCoord.xy, sferePos);
	}
	
	gl_FragColor = vec4(accum*0.5,
						accum*0.45 + 0.3 * sin(time),
						accum*0.15 + 0.4 * cos(time * 2.1), 1.0 );
}
