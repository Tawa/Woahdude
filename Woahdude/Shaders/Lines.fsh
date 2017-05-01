// by Yamada
precision highp float;

uniform float time;
uniform vec2 mouse;
uniform vec2 resolution;

const float PI = 3.1415;
const float OMEGA = 4.0;
const float STEP = 10.0;
const float TIME_SCALE = 0.24;

vec3 drawCircle(vec2 uv, vec3 color0, vec3 color, float r, vec2 p, float w)
{
	return vec3(color * w /  abs(distance(uv, p) - r)) + color0;
}

vec3 drawPoint(vec2 uv, vec3 color0, vec3 color, float r, vec2 p)
{
	return vec3(color * r /  distance(uv, p)) + color0;
}

vec3 drawSegment(vec2 uv, vec3 color0, vec3 color, vec2 p0, vec2 p1, float w)
{
	vec2 a = uv - p0;
	vec2 b = p1 - p0;
	vec2 c = b * max(min(dot(a, b) / dot(b, b), 1.0), 0.0);
	float d = distance(a, c);
	return color * (w / d) + color0;
}

vec3 drawFourier(vec2 uv, vec3 color0, float amp, float t, float omega, vec2 p)
{
	vec2 pp = uv - p;
	
	vec3 dstColor = color0;
	
	float y = 0.0;
	vec2 p0 = vec2(p.x, 0.0);
	
	for(float i = 0.0; i < STEP; i++) {
		float n = 2.0 * i + 1.0;
		float ampn = amp / n;
		vec2 p1 = vec2(p0.x + ampn * cos(n * t), p0.y + ampn * sin(n * t));
		y += ampn * sin(n * (omega * pp.x + t));
		
		dstColor = drawCircle(uv, dstColor, vec3(0.5), ampn, p0, 0.0025);
		dstColor = drawPoint(uv, dstColor, vec3(0.5), 0.0125, p1);
		dstColor = drawSegment(uv, dstColor, vec3(1.0, 0.0, 0.0), p0, p1, 0.001);
		p0 =  p1;
	}
	
	vec2 p1 = vec2(p.x + 2.0 * PI / omega, p0.y);
	dstColor = drawPoint(uv, dstColor, vec3(1.0), 0.0125, p1);
	dstColor = drawSegment(uv, dstColor, vec3(1.0), p0, p1, 0.005);
	
	float dist = distance(pp, vec2(pp.x, y));
	dstColor += 0.005 / dist;
	return dstColor;
}

void main( void ) {
	vec2 p = (2.0 * gl_FragCoord.xy / resolution.xy -1.0) * resolution.xy / min(resolution.x, resolution.y);
	
	vec3 color = vec3(0.0);
	float t = time * TIME_SCALE;
	
	float r = 0.6;
	vec2 offset = vec2(-0.5, 0.0);
	color = drawFourier(p, color, r, t * OMEGA, OMEGA, offset);
	
	gl_FragColor = vec4(color, 1.0);
}
