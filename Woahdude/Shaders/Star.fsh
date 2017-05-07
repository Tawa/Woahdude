#ifdef GL_ES
precision mediump float;
#endif

uniform float time;
uniform vec2 mouse;
uniform vec4 color;
uniform vec2 resolution;
const float PI = 3.141592;
const float n = 5.0;

float smin( float a, float b, float k ) {
	float h = clamp( 0.5+0.5*(b-a)/k, 0.0, 1.0 );
	return mix( b, a, h ) - k*h*(1.0-h);
}

float star1(vec2 p) {
	float theta = atan(p.y, p.x) - PI*0.5;
	float a = theta / PI * 0.5 + 0.5;
	float seg = a * n;
	
	float k = abs(fract(seg) - 0.5);
	k = k*k*(3.0-2.0*k)*k;
	float indent = 0.07 + k*sin(time)*0.1;
	a = (floor(seg) + 0.5) / n;
	if(fract(seg) > 0.5) {
		a -= indent;
	}
	else a += indent;
	a *= 2.0 * PI;
	vec2 o = vec2(cos(a), sin(a));
	
	float col = abs(dot(o, p));
	col = smoothstep(0.2, 0.0, col);
	return clamp(col, 0.0, 1.0);
}

float star2(vec2 p) {
	float theta = atan(p.y, p.x) - PI*0.5;
	float a = theta / PI * 0.5 + 0.5;
	float t = abs(fract(a * n) - 0.5);
	float k = t * 0.4;
	
	float col = length(p) + pow(k, 0.7) * 0.7;
	
	col = smoothstep(0.47, 0.0, col);
	return clamp(col, 0.0, 1.0);
}

float star3(vec2 p) {
	float theta = atan(p.y, p.x) - PI;
	float t = sin(theta * n) * 0.5 + 0.5;
	float k = t * 0.4;
	
	float col = length(p) + pow(k, 1.0) * 0.7;
	col = smin(col, length(p) + 0.2, 0.2);
	
	col = smoothstep(0.47, 0.0, col);
	//col = col > 0.1 ? 0.1 : col;
	return clamp(col, 0.0, 1.0);
}

float map(vec2 p) {
	float t = mod(time, 10.0) / 10.0;
	float d1 = star1(p);
	float d2 = star2(p);
	float d3 = star3(p);
	float d = mix(d1, d2, smoothstep(0.0, 0.333, t));
	d = mix(d, d3, smoothstep(0.333, 0.666, t));
	d = mix(d, d1, smoothstep(0.666, 1.0, t));
	return d1;
}

vec3 calcNormal(vec2 p) {
	vec2 e = vec2(0.001, 0.0);
	return normalize(vec3(
						  map(p + e.xy) - map(p - e.xy),
						  map(p + e.yx) - map(p - e.yx),
						  map(p) * 0.1
						  ));
}

void main( void ) {
	
	vec2 p = ( gl_FragCoord.xy - 0.5 * resolution.xy ) / resolution.x;

	vec3 c1 = vec3(0.8, 0.8, 0.2);
	vec3 c2 = vec3(1.0, 0.7, 0.1);
	vec3 c3 = vec3(1.0, 0.6, 0.05);
	float tt = map(p);
	vec3 c = mix(c1, c2, smoothstep(0.0, 0.02, tt));
	c = mix(c, c3, smoothstep(0.01, 1.0, tt));
	
	vec3 rd = normalize(vec3(p.x, p.y, -2.0));
	vec3 nor = calcNormal(p);
	vec3 lig = normalize(vec3(-(mouse.x*2.0-1.0)*2.0, -(mouse.y*2.0-1.0)*2.0, 2.0));
	float dif = clamp(dot(nor, lig), 0.0, 1.0);
	float spe = pow(clamp(dot(reflect(lig, nor), rd), 0.0, 1.0), 264.0);
	float fre = clamp(1.0 + dot(nor, rd), 0.0, 1.0);
	vec3 col = 1.2 * c * (dif + spe + fre * 0.1);
	
	gl_FragColor = vec4( col * color.rgb, 1.0 );
	
}
