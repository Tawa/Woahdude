#ifdef GL_ES
precision mediump float;
#endif

uniform float time;
uniform vec2 mouse;
uniform vec4 color;
uniform vec2 resolution;

#define iterations 10
#define formuparam2 0.79

#define volsteps 5
#define stepsize 0.290

#define zoom 0.900
#define tile   0.850
#define speed2  0.10

#define brightness 0.002
#define darkmatter 0.500
#define distfading 0.560
#define saturation 0.700

#define transverseSpeed zoom*0.1

float triangle(float x, float a) {
	float output2 = .5*abs(  20.0*  ( (x/a) - floor( (x/a) + 0.5) ) ) - 1.0;
	return output2;
}

void main() {
	vec2 uv2 = 2. * gl_FragCoord.xy / vec2(512) - 1.;
	vec2 uvs = uv2 * vec2(512)  / 512.;
	
	float time2 = time;
	float speed = speed2;
	speed = .01 * cos(time2*0.02 + 3.1415926/4.0);
	//speed = 0.0;
	float formuparam = formuparam2;
	
	//get coords and direction
	vec2 uv = uvs;
	//mouse rotation
	float a_xz = 0.9;
	float a_yz = -.6;
	float a_xy = 0.9 + time*0.08;
	
	mat2 rot_xz = mat2(cos(a_xz),sin(a_xz),-sin(a_xz),cos(a_xz));
	mat2 rot_yz = mat2(cos(a_yz),sin(a_yz),-sin(a_yz),cos(a_yz));
	mat2 rot_xy = mat2(cos(a_xy),sin(a_xy),-sin(a_xy),cos(a_xy));
	
	
	float v2 =1.0;
	vec3 dir=vec3(uv*zoom,1.);
	vec3 from=vec3(0.0, 0.0,0.0);
	from.x -= 5.0*(1.0-1.0);
	from.y -= 5.0*(1.0-0.7);
	
	
	vec3 forward = vec3(0.,0.,1.);
	from.x += transverseSpeed*(11.0)*cos(0.01*time) + 0.001*time;
	from.y += transverseSpeed*(-21.0)*sin(0.01*time) +0.001*time;
	from.z += 0.003*time;
	
	dir.xy*=rot_xy;
	forward.xy *= rot_xy;
	dir.xz*=rot_xz;
	forward.xz *= rot_xz;
	dir.yz*= rot_yz;
	forward.yz *= rot_yz;
	
	from.xy*=-rot_xy;
	from.xz*=rot_xz;
	from.yz*= rot_yz;
	
	
	//zoom
	float zooom = (time2-22.)*speed;
	from += forward* zooom;
	float sampleShift = mod( zooom, stepsize );
	
	float zoffset = -sampleShift;
	sampleShift /= stepsize; // make from 0 to 1
	
	//volumetric rendering
	float s=0.24;
	float s3 = s + stepsize/0.5;
	vec3 v=vec3(0.);
	float t3 = 0.0;
	
	vec3 backCol2 = vec3(0.);
	for (int r=0; r<volsteps; r++) {
		vec3 p2=from+(s+zoffset)*dir;// + vec3(0.,0.,zoffset);
		vec3 p3=from+(s3+zoffset)*dir;// + vec3(0.,0.,zoffset);
		
		p2 = abs(vec3(tile)-mod(p2,vec3(tile*2.))); // tiling fold
		p3 = abs(vec3(tile)-mod(p3,vec3(tile*2.))); // tiling fold
		
		float pa,a=pa=0.;
		for (int i=0; i<iterations; i++) {
			p2=abs(p2)/dot(p2,p2)-formuparam; // the magic formula
			//p=abs(p)/max(dot(p,p),0.005)-formuparam; // another interesting way to reduce noise
			float D = abs(length(p2)-pa); // absolute sum of average change
			a += i > 7 ? min( 12., D) : D;
			pa=length(p2);
		}
		
		
		//float dm=max(0.,darkmatter-a*a*.001); //dark matter
		a*=a*a; // add contrast
		//if (r>3) fade*=1.-dm; // dark matter, don't render near
		// brightens stuff up a bit
		float s1 = s+zoffset;
		// need closed form expression for this, now that we shift samples
		float fade = pow(distfading,max(0.,float(r)-sampleShift));
		//t3 += fade;
		v+=fade;
		//backCol2 -= fade;
		
		// fade out samples as they approach the camera
		if( r == 0 )
			fade *= (1. - (sampleShift));
		// fade in samples as they approach from the distance
		if( r == volsteps-1 )
			fade *= sampleShift;
		v+=vec3(s1,s1*s1,s1*s1*s1*s1)*a*brightness*fade; // coloring based on distance
		
		backCol2 += mix(.4, 1., v2) * vec3(1.8 * t3 * t3 * t3, 1.4 * t3 * t3, t3) * fade;
		
		
		s+=stepsize;
		s3 += stepsize;
	}//фор
	
	v=mix(vec3(length(v)),v,saturation); //color adjust
	
	vec4 forCol2 = vec4(v*.01,1.);
	backCol2.b *= -3.8;
	backCol2.r *= 3.21;
	
	backCol2.b = 10.5*mix(backCol2.g, backCol2.b, 0.01);
	backCol2.g = 0.1;
	backCol2.bg = mix(backCol2.gb, backCol2.bg, 0.39*(cos(1.00) + 1.0));
	gl_FragColor = forCol2 + vec4(backCol2, 1.0) + color;
}
