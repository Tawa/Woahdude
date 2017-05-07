//
//  BaseShader.h
//  Woahdude
//
//  Created by Tawa Nicolas on 1/5/17.
//  Copyright © 2017 Tawa Nicolas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface BaseShader : NSObject

-(instancetype)initWithVertexShader:(NSString *)vsh fragmentShader:(NSString *)fsh;
-(void)renderInRect:(CGRect)rect atTime:(NSTimeInterval)time;

-(void)r:(float)r g:(float)g b:(float)b;
-(void)x:(float)x y:(float)y;
-(void)s:(float)s;

+(EAGLContext *)context;

@end
