//
//  BaseShader.m
//  Woahdude
//
//  Created by Tawa Nicolas on 1/5/17.
//  Copyright © 2017 Tawa Nicolas. All rights reserved.
//

#import "BaseShader.h"

static GLfloat const BaseShaderQuad[8] = {
	-1.f, -1.f,
	-1.f,  1.f,
	 1.f, -1.f,
	 1.f,  1.f
};

@interface BaseShader ()
{
	float r,g,b;
	float x,y;
	float s;
}

// Program Handle
@property (assign, nonatomic, readonly) GLuint program;

// Attribute Handles
@property (assign, nonatomic, readonly) GLuint aPosition;

// Uniform Handles
@property (assign, nonatomic, readonly) GLuint uResolution;
@property (assign, nonatomic, readonly) GLuint uTime;
@property (assign, nonatomic, readonly) GLuint uColor;
@property (assign, nonatomic, readonly) GLuint uMouse;

@end

@implementation BaseShader

-(instancetype)initWithVertexShader:(NSString *)vsh fragmentShader:(NSString *)fsh
{
	self = [super init];
	
	if (self) {
		// Program
		_program = [self programWithVertexShader:vsh fragmentShader:fsh];
		
		// Attributes
		_aPosition = glGetAttribLocation(_program, "position");
		
		// Uniform
		_uResolution = glGetUniformLocation(_program, "resolution");
		_uTime = glGetUniformLocation(_program, "time");
		_uColor = glGetUniformLocation(_program, "color");
		_uMouse = glGetUniformLocation(_program, "mouse");
		
		r = 0.5f;
		g = 0.5f;
		b = 0.5f;
		
		x = 0.5f;
		y = 0.5f;
		
		s = [UIScreen mainScreen].scale;
		
		// Configure OpenGL ES
		[self configureOpenGLES];
	}
	
	return self;
}

-(void)r:(float)red g:(float)green b:(float)blue
{
	r = red;
	g = green;
	b = blue;
}

-(void)x:(float)mouseX y:(float)mouseY
{
	x = mouseX;
	y = mouseY;
}

#pragma mark - Render
-(void)renderInRect:(CGRect)rect atTime:(NSTimeInterval)time
{
	// Uniforms
	glUniform2f(_uResolution, CGRectGetWidth(rect)*s, CGRectGetHeight(rect)*s);
	glUniform1f(_uTime, time);
	glUniform4f(_uColor, r, g, b, 1);
	glUniform2f(_uMouse, x, y);
	
	// Draw
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

#pragma mark Configurations
-(void)configureOpenGLES
{
	// Program
	glUseProgram(_program);
	
	// Attributes
	glEnableVertexAttribArray(_aPosition);
	glVertexAttribPointer(_aPosition, 2, GL_FLOAT, GL_FALSE, 0, BaseShaderQuad);
}

#pragma mark - Compile and Link
-(GLuint)programWithVertexShader:(NSString *)vsh fragmentShader:(NSString *)fsh
{
	// Build shaders
	GLuint vertexShader = [self shaderWithName:vsh type:GL_VERTEX_SHADER];
	GLuint fragmentShader = [self shaderWithName:fsh type:GL_FRAGMENT_SHADER];
	
	// Create program
	GLuint programHandle = glCreateProgram();
	
	// Attach shaders
	glAttachShader(programHandle, vertexShader);
	glAttachShader(programHandle, fragmentShader);
	
	// Link program
	glLinkProgram(programHandle);
	
	// Check for errors
	GLint linkSuccess;
	glGetProgramiv(programHandle, GL_LINK_STATUS, &linkSuccess);
	if (linkSuccess == GL_FALSE) {
		GLchar messages[1024];
		glGetProgramInfoLog(programHandle, sizeof(messages), 0, &messages[0]);
		NSLog(@"%@: - GLSL Program Error: %s", NSStringFromClass([self class]), messages);
	}
	
	glDeleteShader(vertexShader);
	glDeleteShader(fragmentShader);
	
	return programHandle;
}

-(GLuint)shaderWithName:(NSString *)name type:(GLenum)type
{
	NSString *file;
	if (type == GL_VERTEX_SHADER) {
		file = [[NSBundle mainBundle] pathForResource:name ofType:@"vsh"];
	} else if (type == GL_FRAGMENT_SHADER){
		file = [[NSBundle mainBundle] pathForResource:name ofType:@"fsh"];
	}
	
	// Create the shader source
	const GLchar *source = (GLchar *)[[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil] UTF8String];
	
	// Create the shader object
	GLuint shaderHandle = glCreateShader(type);
	
	// Load the shader source
	glShaderSource(shaderHandle, 1, &source, 0);
	
	// Compile the shader
	glCompileShader(shaderHandle);
	
	// Check for errors
	GLint compileSuccess;
	glGetShaderiv(shaderHandle, GL_COMPILE_STATUS, &compileSuccess);
	if (compileSuccess == GL_FALSE) {
		GLchar messages[1024];
		glGetShaderInfoLog(shaderHandle, sizeof(messages), 0, &messages[0]);
		NSLog(@"%@: - GLSL Shader Error: %s", NSStringFromClass([self class]), messages);
	}
	
	return shaderHandle;
}

+(EAGLContext *)context
{
	static EAGLContext *context = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
	});
	[EAGLContext setCurrentContext:context];
	
	return context;
}

@end
