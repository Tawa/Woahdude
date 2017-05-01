
void main( void ) {
	
	vec2 position = ( gl_FragCoord.xy * 2.0 -  resolution + mouse) / min(resolution.x, resolution.y);
	float f = 0.0;
	
	for(float i = 0.0; i < 50.0; i++){
		
		float s = sin(u_time + i ) * 0.5;
		float c = cos(u_time + i ) * 0.5;
		f += 0.0025 / abs(length(position * 1.6 - vec2(c, s)) - abs(sin(u_time)));
	}
	
	gl_FragColor = vec4(vec3(color * f), 1.0);
}
