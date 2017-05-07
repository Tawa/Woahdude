#ifdef GL_ES
precision mediump float;
#endif

uniform float time;
uniform vec2 mouse;
uniform vec4 color;
uniform vec2 resolution;
const float pi = 3.141592;
const float FAR = 80.0;

float sdBox( vec3 p, vec3 b) {
	vec3 d = abs(p) - b;
	return min(max(d.x,max(d.y,d.z)),0.0) + length(max(d,0.0));
}

float sdStarPetal( vec3 p, vec3 b, float r ) {
	vec3 d = abs(p) - b;
	return min(max(d.x,max(d.y,d.z)),0.0) + length(max(d,0.0)) - r;
}

float sdCapsule(vec3 p, vec3 a, vec3 b, float r) {
	vec3 pa = p - a;
	vec3 ba = b - a;
	float h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
	return length(pa - h * ba) - r;
}

float sdCappedCylinder( vec3 p, vec2 h ) {
	vec2 d = abs(vec2(length(p.xz),p.y)) - h;
	return min(max(d.x,d.y),0.0) + length(max(d,0.0));
}

float star1(vec2 p) {
	float n = 5.0;
	float theta = atan(p.y, p.x) - pi*0.5;
	float a = theta / pi * 0.5 + 0.5;
	float seg = a * n;
	
	float indent = 0.0;
	a = (floor(seg) + 0.5) / n;
	if(fract(seg) > 0.5) {
		a -= indent;
	}
	else a += indent;
	a *= 2.0 * pi;
	vec2 o = vec2(cos(a), sin(a));
	
	float col = abs(dot(o, p));
	//col = smoothstep(0.2, 0.0, col);
	//return clamp(col, 0.0, 1.0);
	return col;
}

float sdStar( vec3 p, vec2 h ) {
	p.y += -cos(p.x * pi * 0.3) * 0.6 + 0.45;
	float theta = atan(p.z, p.x) - pi;
	float a = theta / pi * 0.5 + 0.5;
	//h.x += sin(theta * 5.0) * 0.25;
	h.x = star1(p.xz) + 0.5;
	//h.y += cos(p.x) * 0.2;
	//h.y *= 0.01;
	vec2 d = abs(vec2(length(p.xz),p.y)) - h;
	return min(max(d.x,d.y),0.0) + length(max(d,0.0));
}

float superEllipsoid(vec3 p, float r, float t, vec3 s) {
	return pow(pow(abs(p.x/s.x), r) + pow(abs(p.y/s.y), r), t/r) + pow(abs(p.z/s.z), t) - 1.0;
}

float superEgg(vec3 p, float r, float h, float q) {
	return pow(abs(sqrt(p.x*p.x+p.y*p.y)/r),q) + pow(abs(p.z/h),q) - 1.0;
}

float sdTorus(vec3 p, vec2 t) {
	vec2 q = vec2(length(p.xz)-t.x,p.y);
	return length(q)-t.y;
}

float cp12(vec3 p) {
	p = abs(p);
	p = vec3(atan(p.x,p.z) / 3.1415 * sin(p.y), abs(length(p.xz) * 0.3), length(p.xy - p.z));
	p.x += sin(p.z);
	p.z += cos(p.x);
	float y = clamp(log(p.y/0.31), -0.64, 0.12);
	float s = max(p.x+y, max(p.y, p.z)+y) - 2.;
	return s;
}

vec3 tri(in vec3 x){return abs(fract(x)-.5);}
float surfFunc(in vec3 p){
	return dot(tri(p*0.5 + tri(p*0.25).yzx), vec3(0.666));
}

float smin(float a, float b, float k) {
	float h = clamp((b - a)/k *0.5 + 0.5, 0.0, 1.0);
	return mix(b, a, h) - k * h * (1.0 - h);
}

float hash(vec2 p) {
	return fract(sin(p.x * 15.57 + p.y * 37.89) * 43758.26);
}

vec3 roty(vec3 p, float theta) {
	float c = cos(theta);
	float s = sin(theta);
	mat3 m = mat3(
				  c, 0.0, -s,
				  0.0, 1.0, 0.0,
				  s, 0.0, c
				  );
	return m * p;
}

vec3 rotx(vec3 p, float theta) {
	float c = cos(theta);
	float s = sin(theta);
	mat3 m = mat3(
				  1.0, 0.0, 0.0,
				  0.0, c, -s,
				  0.0, s, c
				  );
	return m * p;
}

vec2 opU(vec2 a, vec2 b) {
	return a.x < b.x ? a : b;
}

vec2 map(vec3 p) {
	vec2 d = vec2(p.z + FAR, 0.0);
	d = opU(d, vec2(sdCappedCylinder(rotx(p, pi*0.5) * vec3(1.0, 1.0, 2.0), vec2(1.5, 1.5)), 0.0));
	d = opU(d, vec2(sdStar(p - vec3(0.0,0.8,-1.1), vec2(1.0, 0.16)), 1.0));
	d = opU(d, vec2(sdCapsule(p, vec3(0.5, 0.0, -1.7), vec3(0.5, 0.0, -2.4), 0.3), 0.0));
	d = opU(d, vec2(sdCapsule(p, vec3(0.5, 0.0, -2.4), vec3(0.5, -1.0, -3.2), 0.3), 0.0));
	float se = superEllipsoid(p*1.5 - vec3(0.7,0.7,-2.7), 1.2, 1.2, vec3(0.75, 0.75, 0.75));
	d = opU(d, vec2(se, 2.0));
	return d;
}

vec3 calcNormal(vec3 p) {
	vec2 e = vec2(-1.0, 1.0) * 0.001;
	return normalize(
					 e.xyy * map(p + e.xyy).x +
					 e.yxy * map(p + e.yxy).x +
					 e.yyx * map(p + e.yyx).x +
					 e.xxx * map(p + e.xxx).x
					 );
}

float calcAO(in vec3 ro, in vec3 rd) {
	float t = 0.0;
	float h = 0.0;
	float occ = 0.0;
	for(int i = 0; i < 5; i++) {
		t = 0.01 + 0.12*float(i)/4.0;
		h = map(ro + rd * t).x;
		occ += (t-h)*(4.0-float(i));
	}
	return clamp(1.0 - 2.0*occ, 0.0, 1.0);
}

float softshadow(in vec3 ro, in vec3 rd, in float tmin, in float tmax) {
	float t = tmin;
	float h = 0.0;
	float sh = 1.0;
	for(int i = 0; i < 20; i++) {
		if(t > tmax) continue;
		h = map(ro + rd * t).x;
		sh = min(sh, h/t*50.0);
		t += h * 0.5;
	}
	return clamp(sh, 0.0, 1.0);
}

vec2 trace(in vec3 ro, in vec3 rd){
	float t = 0.0;
	vec2 h = vec2(0.002, 0.0);
	for(int i = 0; i < 75; i++){
		
		/*
		 if(abs(h)<0.002*(t*.125 + 1.) || t>FAR) break;
		 t += step(h, 1.)*h*.2 + h*.35;
		 }
		 */
		if(abs(h.x)<0.001 || t>FAR) continue;
		//t += step(h, 1.)*h*.2 + h*.35;
		h = map(ro+rd*t);
		t += h.x * 0.5;
	}
	return vec2(min(t, FAR), h.y);
}

void main() {
	vec2 uv = (gl_FragCoord.xy - 0.5*resolution.xy) / resolution.x;
	
	vec3 ro = vec3(0.0, 2.0, 3.0) * 5.0 + vec3(mouse.x * 2.0 - 1.0, 0.0, 0.0) * 8.0;
	vec3 ta = vec3(0.0, 0.0, 0.0);
	
	vec3 cw = normalize(ta - ro);
	vec3 cup = vec3(0.0, 1.0, 0.0);
	vec3 cu = normalize(cross(cw, cup));
	vec3 cv = normalize(cross(cu, cw));
	
	float pi = 3.141592;
	float fovy = pi / 4.0;
	float f = tan(fovy * 0.5);
	vec3 rd = normalize(cu * uv.x + cv * uv.y + (1.0/f) * cw);
	
	//-----
	
	float e = 0.001;
	float h = 2.0 * e;
	vec2 tr = trace(ro, rd);
	float t = tr.x;
	
	float ff = clamp((t - 1.0) / 30.0, 0.0, 1.0);
	ff = exp(-3. * ff);
	vec3 sky = color.rgb;

	vec3 star = vec3(1.0, 0.7, 0.1) * 1.5;
	vec3 gem = vec3(1.6, 0.3, 0.99);
	vec3 arm = vec3(0.75, 0.2, 0.6);
	vec3 c = mix(arm, star, step(0.5, tr.y));
	c = mix(c, gem, step(1.5, tr.y));
	
	vec3 col = sky;
	
	vec3 lig_pos0 = vec3(0.0, 1.0, 0.0) * 10.0;
	vec3 lig_pos1 = vec3(-1.0, 1.0, 0.0) * 10.0;
	vec3 lig_pos2 = vec3(0.0, 1.0, 1.0) * 10.0;
	
	float dur = 1.0;
	float tt = mod(mouse.y, dur) / dur;
	
	
	vec3 lig_pos = mix(lig_pos0, lig_pos1, smoothstep(0.0, 0.333, tt));
	lig_pos = mix(lig_pos, lig_pos2, smoothstep(0.333, 0.666, tt));
	lig_pos = mix(lig_pos, lig_pos0, smoothstep(0.666, 1.0, tt));
	
	if(t < FAR) {
		vec3 pos = ro + rd * t;
		vec3 nor = calcNormal(pos);
		vec3 lig = normalize(lig_pos);
		float dif = clamp(dot(nor, lig), 0.0, 1.0);
		vec3 ref = reflect(rd, nor);
		float spe = pow(clamp(dot(ref, lig), 0.0, 1.0), 32.0);
		float sh = 0.5 + 0.5 * softshadow(pos, lig, 0.01, 10.0);
		float ao = calcAO(pos, nor);
		float fre = 1.0 - dot(nor, -rd);
		
		col = c * (dif + spe + fre * 0.9) * ao;
	}
	
	gl_FragColor = vec4(col, 1.0);
}
