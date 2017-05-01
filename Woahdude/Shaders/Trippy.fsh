
void main( void ) {
	
	vec2 p = ( gl_FragCoord.xy - 0.5 / resolution.xy ) / resolution.y;
	
	p.x += 0.1 * sin(p.y * 3.14 + u_time);
	p.x = sin(p.x * 5.0);
	p.y = sin(p.y * 5.0);
	
	//	float g = distance(vec2(0.0,0.0), p);
	float g = distance(vec2(sin(u_time*0.1)), p);
	float d = sin(g * 3.14 * 5.0);
	
	vec3 ca = vec3(1.0, 0.0, 0.0);
	vec3 cb = vec3(0.0, 0.0, 1.0);
	vec3 cc = vec3(1.0, 1.0, 0.0);
	vec3 cd = vec3(1.0, 0.0, 1.0);
	
	float k = d * 0.5 + 0.5; //k가 d에 의해서 바뀌는 부분이 중요한 부분.
	vec3 c = vec3(0.0);
	
	c = mix(ca, cb, smoothstep(0.0, 0.5, k));
	c = mix(c, cc, smoothstep(0.5, 0.75, k));
	c = mix(c, cd, smoothstep(0.75, 1.0, k));
	
	gl_FragColor = vec4( vec3(c), 1.0) + color;
	
}
