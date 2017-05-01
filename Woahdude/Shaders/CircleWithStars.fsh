#ifdef GL_ES
precision mediump float;
#endif

#define COUNT 18.0

uniform highp float time;
uniform lowp vec4 color;
uniform lowp vec2 mouse;
uniform lowp vec2 resolution;

void main(void){
	vec2 position = ( gl_FragCoord.xy * 3.0 -  resolution ) / min(resolution.x, resolution.y) - mouse * 2.0 + vec2(0.5);
	
	float f = 0.0;
	float PI = 3.141592;
	for(float i = 0.0; i < COUNT; i++){
		
		float s = sin(time + i * 2.0 * PI / COUNT) * 0.8;
		float c = cos(time + i * 2.0 * PI / COUNT) * 0.8;
		
		f += 0.001 / (abs(position.x + c) * abs(position.y + s));
	}
	
	
	gl_FragColor = vec4(vec3(f * color), 1.0);
}
