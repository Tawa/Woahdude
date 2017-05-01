#ifdef GL_ES
precision mediump float;
#endif

uniform float time;
uniform vec2 mouse;
uniform vec4 color;
uniform vec2 resolution;

float saturate(float x){return clamp(x,0.,1.);}

vec4 tex(vec2 u){
	vec2 p=fract(fract(u)+(sin(u.y+time)/4.));
	float f=1.-saturate((max(length(p-vec2(0.25,0.5)),length(p-vec2(0.75,0.5)))-.5)*50.);
	f-=1.-saturate((length(p-.5)-(((sin(time+u.x)+2.)/3.)*.25))*50.);
	return vec4(f,f,f,0.) + color;
}

vec4 tex2( vec2 g )
{
	g /= 10.;
	float c = sign((mod(g.x, 0.1) - 0.05) * (mod(g.y, 0.1) - 0.05));
	
	return sqrt(vec4(c)) + color;
}

void main()
{
	vec2 position = ( gl_FragCoord.xy * 3.0 -  resolution ) / min(resolution.x, resolution.y) - mouse * 2.0 + vec2(0.5);
	vec2 uv = position * 2.;
	
	float t = time * .5;
	uv.y += sin(t) * .5;
	uv.x += cos(t) * .5;
	float a = atan(uv.x,uv.y)/1.57;
	float d = max(max(abs(uv.x),abs(uv.y)), min(abs(uv.x)+uv.y, length(uv)));
	
	vec2 k = vec2(a,.8/d + t);
	
	vec4 tx = tex(k*6.);
	vec4 tx2 = tex2(k*2.);
	
	// ground
	gl_FragColor = tx2;
	
	// wall
	if (d<=abs(uv.x)+0.05||d<=abs(uv.x)+uv.y)
		gl_FragColor = tx;
	
	gl_FragColor *= d;
	gl_FragColor.a = 1.;
	
}
