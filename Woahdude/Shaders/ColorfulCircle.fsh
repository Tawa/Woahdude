
void main(void){
	vec2 position = ( gl_FragCoord.xy * 2.0 -  resolution + mouse) / min(resolution.x, resolution.y);
	
	float f = 0.0;
	float PI = 3.141592;
	for(float i = 0.0; i < 20.0; i++){
		
		float s = sin(u_time + i * PI / 10.0) * 0.8;
		float c = cos(u_time + i * PI / 10.0) * 0.8;
		
		f += 0.001 / (abs(position.x + c) * abs(position.y + s));
	}
	
	
	gl_FragColor = vec4(vec3(f * color), 1.0);
}
