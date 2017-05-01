//
//  GLUtilities.m
//  Woahdude
//
//  Created by Tawa Nicolas on 30/4/17.
//  Copyright © 2017 Tawa Nicolas. All rights reserved.
//

#import "GLUtilities.h"

@implementation GLUtilities

-(GLint)compileShader:(NSString *)name type:(GLenum)type
{
	GLuint shader;
	NSString *shaderPath = [[NSBundle mainBundle] pathForResource:name ofType:@"glsl"];
	NSError *error = nil;
	NSString *shaderString = [NSString stringWithContentsOfFile:shaderPath encoding:NSUTF8StringEncoding error:&error];
	
	if (error) {
		NSLog(@"Error loading shader: %@", [error localizedDescription]);
		return -1;
	}
	
	shader = glCreateShader(type);
	if (shader == 0) {
		NSLog(@"glCreateShader failed");
		return -1;
	}
	
	const char *shaderStringUTF8 = shaderString.UTF8String;
	GLint shaderStringLength = (GLint)(shaderString.length);
	glShaderSource(shader, 1, &shaderStringUTF8, &shaderStringLength);
	
	glCompileShader(shader);
	GLint success;
	glGetShaderiv(shader, GL_COMPILE_STATUS, &success);
	
	if (success == GL_FALSE) {
		GLchar *infoLog = malloc(256);
		GLsizei infoLogLength;
		
		glGetShaderInfoLog(shader, 256, &infoLogLength, infoLog);
		NSLog(@"Error compiling shader: %@", [NSString stringWithCString:infoLog encoding:kCFStringEncodingUTF8]);
		
		return -1;
	}
	
	return shader;
}

-(GLuint)compileProgram
{
	GLint vertexShader = [self compileShader:@"SimpleVertex" type:GL_VERTEX_SHADER];
	GLint fragmentShader = [self compileShader:@"SimpleFragment" type:GL_FRAGMENT_SHADER];
	
	GLuint program = glCreateProgram();
	glAttachShader(program, vertexShader);
	glAttachShader(program, fragmentShader);
	glLinkProgram(program);
	
	GLint success;
	glGetProgramiv(program, GL_LINK_STATUS, &success);
	if (success == GL_FALSE) {
		NSLog(@"glLinkProgram failed");
		return -1;
	}
	
	glUseProgram(program);
	
	_positionSlot = glGetAttribLocation(program, "Position");
	_colorSlot = glGetAttribLocation(program, "SourceColor");
	_texCoordSlot = glGetAttribLocation(program, "TexCoord");
	glEnableVertexAttribArray(_positionSlot);
	glEnableVertexAttribArray(_colorSlot);
	glEnableVertexAttribArray(_texCoordSlot);
	
	_projectionUniform = glGetUniformLocation(program, "Projection");
	_modelViewUniform = glGetUniformLocation(program, "Modelview");
	
	return program;
}

@end
