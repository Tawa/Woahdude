//
//  GLViewController.m
//  Woahdude
//
//  Created by Tawa Nicolas on 29/4/17.
//  Copyright © 2017 Tawa Nicolas. All rights reserved.
//

#import "GLViewController.h"
#import "Background.h"

@interface GLViewController ()

@property (strong, nonatomic) EAGLContext *context;
@property (strong, nonatomic) Background *background;

@end

@implementation GLViewController

#pragma mark - View lifecycle

- (void)setupGL {
	
	[EAGLContext setCurrentContext:self.context];
	glEnable(GL_CULL_FACE);
	
	glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	
	self.background = [Background new];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
	GLKView *glView = (GLKView *)self.view;
	[glView setContext:self.context];
	
	if (!self.context) {
		NSLog(@"Failed to create ES context");
	}
	
	[self setupGL];
	
	[self setDelegate:self];
}

-(void)dealloc
{
	[EAGLContext setCurrentContext:nil];
	self.context = nil;
	[self.background destroy];
}

-(void)viewDidLayoutSubviews
{
	[super viewDidLayoutSubviews];
	
	UIWindow *window = [[UIApplication sharedApplication].windows firstObject];
	CGRect frame = [window frame];
	frame = [window convertRect:frame toView:self.view];
	
	CGFloat w = frame.size.width;
	CGFloat h = frame.size.height;
	CGFloat offset = ((h-w)*0.5)*10/w;
	self.background.effect.transform.projectionMatrix = GLKMatrix4MakeOrtho(0, 10, 10+offset, -offset, -1, 1);
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - GLKViewDelegate

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
	glClearColor(self.red, self.green, self.blue, 1.0);
	glClear(GL_COLOR_BUFFER_BIT);

	[self.background render];
}

#pragma mark - GLKViewControllerDelegate

-(void)glkViewControllerUpdate:(GLKViewController *)controller
{
	
}

@end
