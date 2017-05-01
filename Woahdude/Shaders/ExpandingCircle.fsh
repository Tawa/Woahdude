#ifdef GL_ES
precision mediump float;
#endif

uniform highp float time;
uniform lowp vec4 color;
uniform lowp vec2 mouse;
uniform lowp vec2 resolution;

void main(void){
	vec2 position = ( gl_FragCoord.xy * 3.0 -  resolution ) / min(resolution.x, resolution.y) - mouse * 2.0 + vec2(0.5);
	float f = 0.0;
	
	for(float i = 0.0; i < 50.0; i++){
		
		float s = sin(time + i ) * 0.5;
		float c = cos(time + i ) * 0.5;
		f += 0.0025 / abs(length(position * 1.6 - vec2(c, s)) - abs(sin(time)));
	}
	
	gl_FragColor = vec4(vec3(color * f), 1.0);
}
