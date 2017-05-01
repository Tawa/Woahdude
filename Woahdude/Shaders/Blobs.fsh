#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 mouse;
uniform vec4 color;
uniform float time;
uniform vec2 resolution;

float w = resolution.x/2.0;
float h = resolution.y/2.0;
float PI = 3.141592653589793;

void main( void ) {
	float move = w / 2.0;
 
	vec2 pos1 = vec2(w + move * ( sin(time)), h);
	vec2 pos2 = mouse * resolution;
	vec2 pos3 = vec2( w + move * ( sin(time)),h + move * ( cos(time)));
 
	float dist1 = length(gl_FragCoord.xy - pos1);
	float dist2 = length(gl_FragCoord.xy - pos2);
	float dist3 = length(gl_FragCoord.xy - pos3);
 
	float size = 25.0;
	float c = 0.0;
	c += pow(size / dist1, 5.0);
	c += pow(size / dist2, 2.0);
	c += pow(size / dist3, 2.0);
 
	gl_FragColor = vec4(c*color.rgb, 1.0);
}
