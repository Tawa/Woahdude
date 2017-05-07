#ifdef GL_ES
precision mediump float;
#endif

uniform float time;
uniform vec2 mouse;
uniform vec2 resolution;

#define iGlobalTime (time*1.1+100.0)
#define iResolution resolution


//HSB Color to rgb
vec3 hsbToRGB(float h,float s,float b){
	return b*(1.0-s)+(b-b*(1.0-s))*clamp(abs(abs(6.0*(h-vec3(0,1,2)/3.0))-3.0)-1.0,0.0,1.0);
}

const float NUM_PARTICLES = 200.0;

float lerp(float a, float b, float w) {
	return a*w + b*cos(1.0 - w*w);
}

vec4 getParticleLight(float particle, vec2 coord) {
	float factor = abs(sin(time)) * particle / NUM_PARTICLES;
	//    float factor = particle / NUM_PARTICLES;
	
	float red = 1.3*sin(0.05*iGlobalTime);
	float blue = 1.3*cos(0.05*iGlobalTime);
	vec4 color = (0.02 / NUM_PARTICLES) * factor
	* vec4(0.5 + lerp(red*red, 0.5, factor), 1.0,
		   0.5 + lerp(blue*blue, 0.5, factor), 1.0);
	
	float scale = 0.05 + 0.4 * factor
	* (0.8 - 0.3*cos(iGlobalTime) - 0.1*cos(2.0*iGlobalTime));
	
	vec2 location = scale * vec2(
								 cos((3.0 + (fract(mouse.x-0.5)/3.14) * factor) * iGlobalTime),
								 sin((3.2 + (fract(mouse.y-0.5)/3.14) * factor) * iGlobalTime)
								 );
	
	vec2 diff = location - coord; //(coord - (vec2(cos(iGlobalTime),sin(iGlobalTime))-0.5)*0.1);
	//    diff *= sin(time*time);
	float r2 = dot(diff,diff);
	//    return color / r2; // vec4( hsbToRGB( log(diff.x+diff.y), 1.0, 1.0 ) / r2, 1.0 ); // color / r2;
	return vec4( hsbToRGB( particle/NUM_PARTICLES, 1.0, color.r+color.b) / r2, 1.0 ); // color / r2;
	
	
	//	hsbToRGB
	
}

vec2 normalizeCoord(vec2 fragCoord) {
	float scale = min(iResolution.x, iResolution.y);
	
	return vec2((fragCoord.x - iResolution.x/2.0) / scale,
				(fragCoord.y - iResolution.y/2.0) / scale);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
	vec2 coord = normalizeCoord(fragCoord);
	fragColor = vec4(0.0, 0.0, 0.0, 0.0);
	
	for (float i = 1.0; i <= NUM_PARTICLES; ++i) {
		fragColor += getParticleLight(i, coord);
	}
	
	vec2 uv = (fragCoord.xy/resolution.xx)+0.25;
	//fragColor.rgb /= sin(vec3(uv,1.-length(uv-.5))*80.0-40.0*sin(cos(time*0.1)+time*0.01));
	fragColor = clamp( fragColor, 0.0, 1.0 );
}

void main( void ) {
	
	mainImage( gl_FragColor, gl_FragCoord.xy );
}
