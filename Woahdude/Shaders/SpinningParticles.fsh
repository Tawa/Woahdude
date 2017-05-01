#ifdef GL_ES
precision mediump float;
#endif

uniform highp float time;
uniform lowp vec4 color;
uniform lowp vec2 mouse;
uniform lowp vec2 resolution;

void main(void){
	vec2 position = ( gl_FragCoord.xy * 2.0 -  resolution + mouse) / min(resolution.x, resolution.y);
	vec2 uv = gl_FragCoord.xy/resolution.y - 0.5;
	float intensity = 0.;
	for (float i = 0.; i < 54.; i++)
	{
		float angle = i/27. * 3.14159;
		vec2 xy = vec2(0.5 * cos(angle), 0.5 * sin(angle)) + position;
		intensity += pow(1000000., (0.77 - length(xy) * 1.9) * (1. + 0.275 * fract(-i / 17. - time))) / 80000.;
	}
	gl_FragColor = vec4(clamp(intensity * color.rgb, vec3(0.), vec3(1.)), 1.);
}
