//
//  TableViewCell.m
//  Woahdude
//
//  Created by Tawa Nicolas on 29/4/17.
//  Copyright © 2017 Tawa Nicolas. All rights reserved.
//

#import "TableViewCell.h"
#import "BaseShader.h"

@interface TableViewCell ()
{
	NSTimeInterval time;
	NSTimeInterval startTime;
	NSTimeInterval lastTime;
	EAGLContext *context;
}

@property (strong, nonatomic) BaseShader *shader;

@end

@implementation TableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
	
	[_glView setDelegate:self];
	
	self.shader = nil;
	
	self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(refresh)];
	[self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
	
	time = 0;
	
	lastTime = [[NSDate date] timeIntervalSince1970];
	startTime = lastTime;
}

-(void)refresh
{
	NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970];
	NSTimeInterval deltaTime = currentTime - lastTime;

	lastTime = currentTime;
	time += deltaTime;
	[_glView display];
	
}

-(void)setData:(NSString *)data
{
	context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
	[_glView setContext:context];
	[EAGLContext setCurrentContext:context];
	self.shader = [[BaseShader alloc] initWithVertexShader:@"BaseVertex" fragmentShader:data];
	self.title.text = data;
	[_glView display];
}

-(void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
	glClearColor(0, 0.5, 1, 1);
	glClear(GL_COLOR_BUFFER_BIT);
	
	[self.shader renderInRect:rect atTime:time];
	
	glFlush();
}

@end
