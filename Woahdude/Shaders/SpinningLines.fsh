#ifdef GL_ES
precision mediump float;
#endif

uniform highp float time;
uniform lowp vec4 color;
uniform lowp vec2 mouse;
uniform lowp vec2 resolution;

void main(void){
	const float pi = 3.14159265;
	const float i_max = pi;
	const float d_i = i_max / 8.;
	vec2 u = gl_FragCoord.xy - resolution*0.5;
	float a = 0.32;
	float b = 0.2;
	float d = 1.0125 / 32.;
	float c = 159. * d;
	
	float fi=atan(u.x,u.y);
	
	vec3 col = color.rgb;
	for (float i=0.; i<i_max; i+=d_i)
	{
		float temp1 = i + c*fi-fi + time;
		float temp2 = i + d*fi+fi - time;
		col += 0.0005 / abs(a + b*sin(temp1)*sin(temp2) - length(u)/(resolution.y/1.15));
	}
	gl_FragColor = vec4(col, 0.0);
}
