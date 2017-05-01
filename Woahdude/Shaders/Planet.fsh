precision highp float;

uniform float time;
uniform vec2 mouse;
uniform vec4 color;
uniform vec2 resolution;
struct Ray { vec3 o; vec3 d; };
struct Sphere { vec3 pos; float rad; };

float planetradius = 5000.0;
Sphere planet = Sphere(vec3(0), planetradius);

float minhit = 0.0;
float maxhit = 0.0;
float rsi2(in Ray ray, in Sphere sphere)
{
	vec3 oc = ray.o - sphere.pos;
	float b = 2.0 * dot(ray.d, oc);
	float c = dot(oc, oc) - sphere.rad*sphere.rad;
	float disc = b * b - 4.0 * c;
	if (disc < 0.0) return -1.0;
	float q = b < 0.0 ? ((-b - sqrt(disc))/2.0) : ((-b + sqrt(disc))/2.0);
	float t0 = q;
	float t1 = c / q;
	if (t0 > t1) {
		float temp = t0;
		t0 = t1;
		t1 = temp;
	}
	minhit = min(t0, t1);
	maxhit = max(t0, t1);
	if (t1 < 0.0) return -1.0;
	if (t0 < 0.0) return t1;
	else return t0;
}

vec3 getRay(vec2 UV){
	UV = UV * 2.0 - 1.0;
	return normalize(vec3(UV.x, - UV.y, -1.0));
}
vec3 getatm(float dst, vec3 dir){
	return dst * vec3(0.0, 0.3, 0.5);
}

float hash( float n ){
	return fract(sin(n)*758.5453);
}

float noise3d( in vec3 x ){
	vec3 p = floor(x);
	vec3 f = fract(x);
	f       = f*f*(3.0-2.0*f);
	float n = p.x + p.y*500.0 + 113.0*p.z;
	
	return mix(mix(	mix( hash(n+0.0), hash(n+1.0),f.x),
				   mix( hash(n+157.0), hash(n+158.0),f.x),f.y),
			   mix(	mix( hash(n+113.0), hash(n+114.0),f.x),
				   mix( hash(n+270.0), hash(n+271.0),f.x),f.y),f.z);
}

float noise2d( in vec2 x ){
	vec2 p = floor(x);
	vec2 f = smoothstep(0.0, 1.0, fract(x));
	float n = p.x + p.y*57.0;
	return mix(mix(hash(n+0.0),hash(n+1.0),f.x),mix(hash(n+51.0),hash(n+58.0),f.x),f.y);
}

float configurablenoise(vec3 x, float c1, float c2) {
	vec3 p = floor(x);
	vec3 f = fract(x);
	f       = f*f*(3.0-2.0*f);
	
	float h2 = c1;
	float h1 = c2;
#define h3 (h2 + h1)
	
	float n = p.x + p.y*h1+ h2*p.z;
	return mix(mix(	mix( hash(n+0.0), hash(n+1.0),f.x),
				   mix( hash(n+h1), hash(n+h1+1.0),f.x),f.y),
			   mix(	mix( hash(n+h2), hash(n+h2+1.0),f.x),
				   mix( hash(n+h3), hash(n+h3+1.0),f.x),f.y),f.z);
	
}

float supernoise3d(vec3 p){
	
	float a =  configurablenoise(p, 883.0, 971.0);
	float b =  configurablenoise(p + 0.5, 113.0, 157.0);
	return (a + b) * 0.5;
}
float supernoise3dX(vec3 p){
	
	float a =  configurablenoise(p, 883.0, 971.0);
	float b =  configurablenoise(p + 0.5, 113.0, 157.0);
	return (a * b);
}

float fbmHI(vec3 p){
	// p *= 0.1;
	p *= 1.2;
	//p += getWind(p * 0.2) * 6.0;
	float a = 0.0;
	float w = 1.0;
	float wc = 0.0;
	for(int i=0;i<4;i++){
		//p += noise(vec3(a));
		a += clamp(2.0 * abs(0.5 - (supernoise3dX(p))) * w, 0.0, 1.0);
		wc += w;
		w *= 0.5;
		p = p * 3.0;
	}
	return a / wc;// + noise(p * 100.0) * 11;
}

float softlight(float base, float blend){
	return (blend < 0.5) ? (2.0 * base * blend + base * base * (1.0 - 2.0 * blend)) : (sqrt(base) * (2.0 * blend - 1.0) + 2.0 * base * (1.0 - blend));
}
vec3 softlight3(vec3 base, vec3 blend){
	return vec3(softlight(base.x, blend.x), softlight(base.y, blend.y), softlight(base.z, blend.z));
}

vec3 getplanet(vec3 possurface, vec3 n, vec3 v,  vec3 sundir){
	
	vec3 planet = vec3(1);
	
	float elevation = smoothstep(0., 1., .75*sqrt(fbmHI( possurface+vec3(time, 0., 0.) )) );
	
	// polar elevation adjustments
	elevation -= pow(abs(possurface.y+sundir.y*-1.), 3.)*0.01;
	
#define ev elevation
	
	planet.rgb *= elevation;
	//return planet;
	
#define MIXIN(COLOR) planet = mix(COLOR.rgb, planet, COLOR.a)
	// terrain
	planet = vec3(.2);// rock
	MIXIN(0.3*vec4(1, 1, 0, smoothstep(0.37, 0.36, ev))); // coast
	MIXIN(0.4*vec4(.1,.4,.1, smoothstep(.6, .2, ev))); // grass
	MIXIN(vec4(0,.2,.1, smoothstep(.3, .4, ev))); // forest
	MIXIN(vec4(.3,.3,.2, smoothstep(.2, .3, ev))); // mountains
	MIXIN(.95*vec4(1., 1., 1., smoothstep(0.1, 0.2, ev))); // snow
	MIXIN(.99*vec4(1., 1., 1., smoothstep(0.9, 0.28, ev))); // caps
	return planet;
	
	// ocean
	float forward_facing = pow(1.0 - max(0.0, dot(n, v)), 3.0);
	planet = mix(planet,vec3(0.0, 0.1, 0.3)*(0.75 + 0.125 * forward_facing) , smoothstep(0.37, 0.44, ev));
	
	// solar reflection
	float sol = 2.0 * pow(max(0.0, dot(reflect(v,n), sundir)), 25.0 + 10000.0 * pow(ev * 1.2, 5.0));
	sol = pow(clamp(0., 1., sol), .04);
	//planet = (planet + sol*vec3(1,1,.9)*0.6)*sol;
	planet = softlight3(mix(planet, planet*planet*2.+0.5, .675-1.25*sol), sol*vec3(1,1,.9));
	
	return planet;
}

void main( void ) {
	
	float xpos = mouse.x * 20.0 - 10.0;
	float ypos =  (1.0 - mouse.y) * 20.0 - 10.0;
	float zpos = -10.0; // IOSOMEWHERE : how far away the planet is -1.0 = VERY CLOSE, -100.0 = VERY FAR
	vec2 position = ( gl_FragCoord.xy / resolution.xy );
	position.y = ((position.y * 2.0 - 1.0) * resolution.y/resolution.x) * 0.5 + 0.5;
	Sphere planet = Sphere(vec3(xpos, ypos, zpos), 5.0);
	Sphere atmosphere = Sphere(vec3(xpos, ypos, zpos), 5.5);
	Ray r = Ray(vec3(0.0), getRay(position));
	float planethit = rsi2(r, planet);
	float atmhit = rsi2(r, atmosphere);
	vec3 c = color.rgb;
	if(atmhit > 0.0){
		if(planethit > 0.0){
			c += getatm(abs(atmhit - planethit), r.d);
			vec3 n = normalize(planet.pos - (r.o + r.d * planethit));
			c += getplanet(r.o + r.d * planethit, n, r.d, normalize(vec3(sin(time*0.1), -2.*(mouse.y-.5), cos(time*0.1))));
		} else {
			vec3 p = normalize(planet.pos - (r.o + r.d * minhit));
			c += getatm(maxhit - minhit, r.d) * (1.0 / 6.0 * (1.0 - p.z));
		}
	}
	
	gl_FragColor = vec4(c, 1.0 );
	
}
