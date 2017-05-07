#ifdef GL_ES
precision mediump float;
#endif

uniform float time;
uniform vec2 mouse;
uniform vec2 resolution;

uniform sampler2D backbuffer;
#define last_frame texture2D(backbuffer, gl_FragCoord.xy/resolution)

bool square(vec2 v, float l){
	return max(abs(v.x), abs(v.y)) < l/2.;
}

bool plus(vec2 v){
	v *= 3.;
	return square(v, 1.)
	|| square(v + vec2(0, 1), 1.)
	|| square(v + vec2(0,-1), 1.)
	|| square(v + vec2(-1,0), 1.)
	|| square(v + vec2( 1,0), 1.)
	;
}

float tmod(float t){
	const float m = 2.5;
	float mt = mod(t, m);
	if(mt >= 1./m) return 0.;
	return (3.14159/2.)*(mt*m);
}

vec4 white(vec2 v, float t){
	bool b = false;
	
	t *= 0.75;
	v += vec2(2.75, 1.25);
	
	vec2 _v = v;
	float _t = t;
	
#define _rot2(rot2_angle) mat2(sin(rot2_angle), cos(rot2_angle), cos(rot2_angle), -sin(rot2_angle))
#define _stamp b = b || plus(v*_rot2(tmod(t)));
#define _shift_right v.x -= 1.;v.y += 1./3.;t += 2.;
#define _reset v = _v; t = _t;
#define _shift_up v.x -= 1./3.;v.y -= 1.;t += 2./3.;
	
	_stamp;
	_shift_right; _stamp;
	_shift_right; _stamp;
	_shift_right; _stamp;
	_shift_right; _stamp;
	_reset;
	_shift_up; _stamp;
	_shift_right; _stamp;
	_shift_right; _stamp;
	_shift_right; _stamp;
	_shift_right; _stamp;
	_reset;
	_shift_up; _shift_up; _stamp;
	_shift_right; _stamp;
	_shift_right; _stamp;
	_shift_right; _stamp;
	_shift_right; _stamp;
	_reset;
	_shift_up; _shift_up; _shift_up; _stamp;
	_shift_right; _stamp;
	_shift_right; _stamp;
	_shift_right; _stamp;
	_shift_right; _stamp;
	
	return vec4(float(b));
}

vec4 black(vec2 v, float t){
	v.x -= 2./3.;
	v.y -= 1./3.;
	return 1.-white(v, t);
}

void main( void ) {
	vec2 p = 10. * ( gl_FragCoord.xy - 0.5 * resolution.xy ) / resolution.x;
	
	float wc = white(p, time).r;
	float bc = black(p, time+5./3.).r;
	float lc = last_frame.r;
	float la = last_frame.a;
	
	if(bc == wc){
		lc = wc;
		la = .5;
	}else if(la == 1.){
		lc = bc;
	}else if(la == 0.){
		lc = wc;
	}else if(lc == wc){
		la = 1.;
		lc = bc;
	}else{
		la = 0.;
		lc = wc;
	}
	
	gl_FragColor = vec4(lc, lc, lc, la);
}
