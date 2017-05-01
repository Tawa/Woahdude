#ifdef GL_ES
precision mediump float;
#endif

#define TRACE_MAX_DIST 19.

uniform float time;
uniform vec2  mouse;
uniform vec4  color;
uniform vec2  resolution;

float vmax(vec3 v) { return max(v.x, max(v.y, v.z)); }

mat3 rotY(float angle)
{
	float c = cos(angle);
	float s = sin(angle);
	return mat3(c, 0., s, 0., 1., 0., -s, 0., c);
}

mat3 rotX(float angle)
{
	float c = cos(angle);
	float s = sin(angle);
	return mat3(1., 0., 0., 0., c, -s, 0., s, c);
}

float box(vec3 pos, vec3 size)
{
	return vmax(abs(pos) - size);
}

float world(vec3 pos)
{
	// return box(pos, vec3(.5));  // a box
	// return min(box(pos, vec3(.5)), pos.y + 1.); // a box with horizontal plane
	return min(box(rotX(time) * rotY(time) * pos, vec3(.5)), pos.y + .9); // a rotating box with horizontal plane
	//return min(length(pos) - .8, pos.y + 1.); // a sphere with horizontal plane
	//return length(pos) - .8; // just a sphere
}

vec3 normal(vec3 pos)
{
	vec2 delta = vec2(0, 0.001);
	float baseDist = world(pos);
	return normalize(vec3(world(pos + delta.yxx) - baseDist, world(pos + delta.xyx) - baseDist, world(pos + delta.xxy) - baseDist));
}

float trace(vec3 origin, vec3 direction, float current_dist, float max_dist)
{
	for (int i = 0; i < 128; ++i) {
		float new_dist = world(origin + direction*current_dist);
		current_dist += new_dist;
		if (new_dist < 0.01)
			break;
		if (current_dist > max_dist)
			break;
	}
	
	return current_dist;
}

vec3 enlight(vec3 pos, vec3 normal, vec3 albedo, vec3 lightpos, vec3 lightcolor, vec3 ambient)
{
	vec3 vectorToLight = lightpos - pos;
	float distanceToLight = length(vectorToLight);
	vec3 lightDirection = normalize(vectorToLight);
	
	// Next two lines is shadow
	float traceToLightPoint = trace(pos + normal*0.011, lightDirection, 0., distanceToLight);
	if (traceToLightPoint < distanceToLight) return ambient + vec3(0.);
	
	return ambient + max(0.0, dot(lightDirection, normal)) * lightcolor * albedo / dot(vectorToLight, vectorToLight);
}

void main( void ) {
	vec2 position = ( gl_FragCoord.xy / resolution.xy );
	position.y -= 0.5;
	position.x -= 0.5;
	float aspect = resolution.y / resolution.x;
	vec2 aspectedPosition = position * vec2(1., aspect);
	
	vec3 cameraPos = vec3(0, 0, 6.);
	vec3 traceDirection = normalize(vec3(aspectedPosition, -1));
	float resultDist = trace(cameraPos, traceDirection, 0., TRACE_MAX_DIST);
	
	vec3 resultColor = vec3(0.);
	
	if (resultDist < TRACE_MAX_DIST) {
		vec3 resultSurfacePosition = cameraPos + traceDirection * resultDist;
		//		 Show normals:
		resultColor = normal(resultSurfacePosition);
		//
		//		 Show depth:
		resultColor = vec3( 1./ resultDist);
		//
		//		 Show lit pixels:
		resultColor = enlight(resultSurfacePosition, normal(resultSurfacePosition), color.rgb, vec3(2.), vec3(2.), vec3(0.05));
	}
	
	gl_FragColor = vec4(resultColor, 1.);
}
