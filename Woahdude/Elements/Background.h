//
//  Header.h
//  Woahdude
//
//  Created by Tawa Nicolas on 29/4/17.
//  Copyright © 2017 Tawa Nicolas. All rights reserved.
//

#import <GLKit/GLKit.h>
#import <OpenGLES/ES2/glext.h>

typedef struct {
	float Position[2];
	float Color[4];
	float TexCoord[2];
} Vertex;

const Vertex Vertices[] = {
	{{-5, -5}, {1, 1, 1, 1}, {0, 0}},
	{{-5,  5}, {1, 1, 1, 1}, {0, 1}},
	{{ 5, -5}, {1, 1, 1, 1}, {1, 0}},
	{{ 5,  5}, {1, 1, 1, 1}, {1, 1}}
};

const GLubyte Indices[] = {
	0, 1, 2,
	2, 1, 3
};

@interface Background : NSObject
{
	GLuint _vertexBuffer;
	GLuint _indexBuffer;
	GLuint _vertexArray;
}

@property (strong, nonatomic) GLKBaseEffect *effect;

@end

@implementation Background

-(instancetype)init
{
	self.effect = [[GLKBaseEffect alloc] init];
	self.effect.transform.modelviewMatrix = GLKMatrix4MakeTranslation(5, 5, 0);
	glGenVertexArraysOES(1, &_vertexArray);
	glBindVertexArrayOES(_vertexArray);
	
	glGenBuffers(1, &_vertexBuffer);
	glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
	glBufferData(GL_ARRAY_BUFFER, sizeof(Vertices), Vertices, GL_STATIC_DRAW);
	
	glGenBuffers(1, &_indexBuffer);
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer);
	glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(Indices), Indices, GL_STATIC_DRAW);
	// New lines (were previously in draw)
	glEnableVertexAttribArray(GLKVertexAttribPosition);
	glVertexAttribPointer(GLKVertexAttribPosition, 2, GL_FLOAT, GL_FALSE, sizeof(Vertex), (const GLvoid *) offsetof(Vertex, Position));
	glEnableVertexAttribArray(GLKVertexAttribColor);
	glVertexAttribPointer(GLKVertexAttribColor, 4, GL_FLOAT, GL_FALSE, sizeof(Vertex), (const GLvoid *) offsetof(Vertex, Color));
	glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
	glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(Vertex), (const GLvoid *) offsetof(Vertex, TexCoord));
	
	glBindVertexArrayOES(0);
	
	self.effect.texture2d0.enabled = true;
	self.effect.texture2d0.name = [Background textureInfoName];
	
	return self;
}

-(void)render
{
	[self.effect prepareToDraw];
	
	glBindVertexArrayOES(_vertexArray);
	glDrawElements(GL_TRIANGLES, sizeof(Indices)/sizeof(Indices[0]), GL_UNSIGNED_BYTE, 0);

}

-(void)destroy
{
	glDeleteBuffers(1, &_vertexBuffer);
	glDeleteBuffers(1, &_indexBuffer);
	glDeleteVertexArraysOES(1, &_vertexArray);
	
	self.effect = nil;
	
	[Background deallocTextureInfo];
}

static GLKTextureInfo *textureInfo = nil;
+(GLuint)textureInfoName
{
	if (textureInfo == nil) {
		NSDictionary * options = [NSDictionary dictionaryWithObjectsAndKeys:
								  [NSNumber numberWithBool:YES],
								  GLKTextureLoaderOriginBottomLeft,
								  nil];
		
		NSError * error;
		NSString *path = [[NSBundle mainBundle] pathForResource:@"blob" ofType:@"png"];
		textureInfo = [GLKTextureLoader textureWithContentsOfFile:path options:options error:&error];
		if (textureInfo == nil) {
			NSLog(@"Error loading file: %@", [error localizedDescription]);
		}
	}
	return textureInfo.name;
}
+(void)deallocTextureInfo
{
	textureInfo = nil;
}

@end
