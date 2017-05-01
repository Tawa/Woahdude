#ifdef GL_ES
precision mediump float;
#endif

uniform highp float time;
uniform lowp vec4 color;
uniform lowp vec2 mouse;
uniform lowp vec2 resolution;

void main(void){
	vec2 position = ( gl_FragCoord.xy -  resolution + mouse) / min(resolution.x, resolution.y);
	
	float r = position.x * gl_FragCoord.x + position.y * gl_FragCoord.y;
	r = cos(6.28 * fract(r + time));
	
	gl_FragColor = vec4(vec3(r), 1.0 );
	
}
