
void main( void ) {
	vec2 position = ( gl_FragCoord.xy / 2 -  resolution + mouse) / min(resolution.x, resolution.y);
	
	float r = position.x * gl_FragCoord.x + position.y * gl_FragCoord.y;
	r = cos(6.28 * fract(r + u_time));
	
	gl_FragColor = vec4(vec3(r), 1.0 );
	
}
