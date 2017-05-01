#ifdef GL_ES
precision mediump float;
#endif

uniform float time;
uniform vec2 mouse;
uniform vec4 color;
uniform vec2 resolution;

// Created by Stephane Cuillerdier - Aiekick/2017 (twitter:@aiekick)
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
// Tuned via XShade (http://www.funparadigm.com/xshade/)

// this tech can be used to easily compute the df of a polygon mesh.
// we just need to pass as a uniform the point list and lets the shader compute the df
// the thick may be tuned to avoid the clamp of the df by the display color

// https://www.shadertoy.com/view/MsjyWR

// modified version for glsl 1, a little bit not logic due to the mouse

#define count 6
#define thick 0.18
#define zoom 1.5

vec4 col;

// compute the df from a points array
float computeDf(in vec2 vUV, in vec2 vArr[count+1], in float vDFThick)
{
	float d = 1e3;
	for (int i = 0; i < count+1;  i++)
	{
		// p = current point
		// lp = last point
		vec2 p = vArr[i], lp = p, np = p;
		
		// circular
		if (i==0) lp = vArr[count]; else lp = vArr[i-1];
		
		// 2d line df
		vec2 a = vUV - lp;
		vec2 b = p - lp;
		float h = clamp(dot(a,b)/dot(b,b),0.,1.);
		float c = length(a-b*h) + vDFThick;
		
		// df min
		d = min(d, c);
		
		// facultative : display the current point just for the demo
		col += .0001/dot(vUV-p,vUV-p);
	}
	
	return d;
}

void main()
{
	col = color;
	
	vec2 uv = (gl_FragCoord.xy *2. - resolution.xy)/resolution.y*zoom;
	
	vec2 mo = mouse * resolution;
	
	// array of points
	vec2 arr[count+1]; // count + 1 is for the adding of the mouse point if needed at line 67
	
	// generate a basic polygon arrangement
	float radius = .9;
	for (int i = 0; i < count;  i++)
	{
		float a = float(i) / float (count) * 3.14159 * 2.;
		arr[i] = radius * vec2(cos(a), sin(a));
	}
	
	vec2 p = (mo.xy *2. - resolution.xy)/resolution.y*zoom;
	arr[count] = p;
	
	// fro saving teh good thumbail :)
	if (mo.x < 200. && mo.y > 570.) arr[count] = vec2(0);
	
	float d = computeDf(uv, arr, thick);
	
	// display the computed df
	gl_FragColor = vec4(1)-col + d;
}
