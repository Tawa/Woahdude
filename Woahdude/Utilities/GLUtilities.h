//
//  GLUtilities.h
//  Woahdude
//
//  Created by Tawa Nicolas on 30/4/17.
//  Copyright © 2017 Tawa Nicolas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES2/glext.h>

#import "CC3Foundation.h"
#import "CC3GLMatrix.h"
#import "CC3Kazmath.h"

@interface GLUtilities : NSObject

@property (assign, nonatomic) GLint positionSlot;
@property (assign, nonatomic) GLint colorSlot;
@property (assign, nonatomic) GLint texCoordSlot;
@property (assign, nonatomic) GLint projectionUniform;
@property (assign, nonatomic) GLint modelViewUniform;

-(GLint)compileShader:(NSString *)name type:(GLenum)type;
-(GLuint)compileProgram;

@end
