#ifdef GL_ES
precision mediump float;
#endif

uniform float time;
uniform vec2 mouse;
uniform vec4 color;
uniform vec2 resolution;
const float pi = 3.141592;

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

float map(vec3 p) {
	
	float d = 1000.0;
	float r = length(p.xz);
	for(int i = 0; i < 5; i++) {
		float theta = float(i) / 5.0 * pi * 2.0;
		vec3 q = roty(p, theta);
		q.z += 0.5;
		q.x *= 1.8;
		q.y += -cos(r * pi * 0.5) * 0.2;
		q = roty(q, pi * 0.25);
		d = min(d, sdStarPetal(q - vec3(0.0, 0.0, 0.0), vec3(1.0, 0.15, 1.0) * 0.5, 0.3));
	}
	vec3 qq = p;
	qq.y += -cos(r * pi * 0.5) * 0.2;
	d = max(d, sdBox(qq, vec3(2.0, 0.15, 2.0)));
	
	return d;
}

vec3 calcNormal(vec3 p) {
	vec2 e = vec2(-1.0, 1.0) * 0.001;
	return normalize(
					 e.xyy * map(p + e.xyy) +
					 e.yxy * map(p + e.yxy) +
					 e.yyx * map(p + e.yyx) +
					 e.xxx * map(p + e.xxx)
					 );
}

float calcAO(in vec3 ro, in vec3 rd) {
	float t = 0.0;
	float h = 0.0;
	float occ = 0.0;
	for(int i = 0; i < 5; i++) {
		t = 0.01 + 0.12*float(i)/4.0;
		h = map(ro + rd * t);
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
		h = map(ro + rd * t);
		sh = min(sh, h/t*50.0);
		t += h * 0.5;
	}
	return clamp(sh, 0.0, 1.0);
}

float trace(in vec3 ro, in vec3 rd){
	float FAR = 50.0;
	float t = 0.0, h;
	for(int i = 0; i < 72; i++){
		h = map(ro+rd*t);
		if(abs(h)<0.002*(t*.125 + 1.) || t>FAR) break;
		t += step(h, 1.)*h*.2 + h*.35;
	}
	
	return min(t, FAR);
}

void main() {
	vec2 uv = (gl_FragCoord.xy - 0.5*resolution.xy) / resolution.x;
	
	vec3 ro = vec3(0.0, 10.0, 5.0 - mouse.y * 4.0) + vec3(mouse.x * 2.0 - 1.0, 0.0, 0.0) * 3.0;
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
	float t = trace(ro, rd);
	
	float ff = clamp((t - 1.0) / 30.0, 0.0, 1.0);
	ff = exp(-3. * ff);
	vec3 sky = color.rgb;//vec3(0., .9, 2.8);
	vec3 star = vec3(1.0, 0.71, 0.1);
	vec3 col = sky;
	
	vec3 lig_pos0 = vec3(0.0, 1.0, 0.0) * 10.0;
	vec3 lig_pos1 = vec3(-1.0, 1.0, 0.0) * 10.0;
	vec3 lig_pos2 = vec3(0.0, 1.0, 1.0) * 10.0;
	
	float dur = 10.0;
	float tt = mod(time, dur) / dur;
	
	
	vec3 lig_pos = mix(lig_pos0, lig_pos1, smoothstep(0.0, 0.333, tt));
	lig_pos = mix(lig_pos, lig_pos2, smoothstep(0.333, 0.666, tt));
	lig_pos = mix(lig_pos, lig_pos0, smoothstep(0.666, 1.0, tt));
	
	//vec3 lig_pos = vec3(1.0);
	if(t < 50.0) {
		vec3 pos = ro + rd * t;
		vec3 nor = calcNormal(pos);
		vec3 lig = normalize(lig_pos);
		float dif = clamp(dot(nor, lig), 0.0, 1.0);
		vec3 ref = reflect(rd, nor);
		float spe = pow(clamp(dot(ref, lig), 0.0, 1.0), 64.0);
		float sh = 0.5 + 0.5 * softshadow(pos, lig, 0.01, 10.0);
		float fre = 1.0 - dot(nor, -rd);
		
		col = star * (dif + fre * 0.75);
		//col = mix(sky, col, ff);
	}
	
	gl_FragColor = vec4(col, 1.0);
}
