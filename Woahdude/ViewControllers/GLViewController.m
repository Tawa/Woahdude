//
//  GLViewController.m
//  Woahdude
//
//  Created by Tawa Nicolas on 29/4/17.
//  Copyright © 2017 Tawa Nicolas. All rights reserved.
//

#import "GLViewController.h"
#import "BaseShader.h"

@interface GLViewController () <GLKViewControllerDelegate>
{
	NSTimeInterval time;
}

@property (strong, nonatomic) BaseShader *shader;

@end

@implementation GLViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	GLKView *glView = (GLKView *)self.view;
	glView.contentScaleFactor = 1;
	glView.context = [BaseShader context];
	
	glClearColor(0, 0, 0, 1);
	
	self.delegate = self;
	self.timeScale = 1;
	time = 0;
}

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	self.shader = [[BaseShader alloc] initWithVertexShader:@"BaseVertex" fragmentShader:self.fileName];
}

-(void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
	glClear(GL_COLOR_BUFFER_BIT);
	[self.shader renderInRect:rect atTime:time];
}

-(void)glkViewControllerUpdate:(GLKViewController *)controller
{
	time += controller.timeSinceLastUpdate * _timeScale;
}

-(void)setRed:(CGFloat)red
{
	_red = red;
	[self updateBackground];
}

-(void)setGreen:(CGFloat)green
{
	_green = green;
	[self updateBackground];
}

-(void)setBlue:(CGFloat)blue
{
	_blue = blue;
	[self updateBackground];
}

-(void)updateBackground
{
	[self.shader r:_red g:_green b:_blue];
}

-(void)handleTouch:(UITouch *)touch
{
	CGPoint point = [touch locationInView:self.view];
	
	CGFloat mouseX = point.x/[UIScreen mainScreen].bounds.size.width;
	CGFloat mouseY = 1-point.y/[UIScreen mainScreen].bounds.size.height;
	
	[self.shader x:mouseX y:mouseY];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
	[self handleTouch:[touches anyObject]];
}

-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
	[self handleTouch:[touches anyObject]];
}

-(void)setScale:(float)scale
{
	GLKView *view = (GLKView *)self.view;
	
	view.contentScaleFactor = scale;
	
	[self.shader s:scale];
}

@end
