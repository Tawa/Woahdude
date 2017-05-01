//
//  GameScene.m
//  Woahdude
//
//  Created by Tawa Nicolas on 30/4/17.
//  Copyright © 2017 Tawa Nicolas. All rights reserved.
//

#import "GameScene.h"

@implementation GameScene
{
	float mouseX, mouseY;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	
	if (self) {
		self.anchorPoint = CGPointZero;
		mouseX = 0.5;
		mouseY = 0.5;
	}
	
	return self;
}

-(void)didMoveToView:(SKView *)view
{
	self.colorUniform = [SKUniform uniformWithName:@"color" vectorFloat4:vector4(0.5f,0.5f,0.5f,1.0f)];
	self.mouseUniform = [SKUniform uniformWithName:@"mouse" vectorFloat2:vector2(mouseX,mouseY)];
	
	CGSize size = [UIScreen mainScreen].bounds.size;
	size.width *= 2;
	size.height *= 2;

	SKSpriteNode *shaderContainer = [SKSpriteNode spriteNodeWithColor:[UIColor clearColor] size:[UIScreen mainScreen].bounds.size];
	shaderContainer.anchorPoint = CGPointZero;
	shaderContainer.position = CGPointZero;
	shaderContainer.size = size;
	[self addChild:shaderContainer];

	SKShader* shader_move = [SKShader shaderWithFileNamed:self.fileName];
	shader_move.uniforms = @[
							 self.mouseUniform,
							 self.colorUniform,
							 [SKUniform uniformWithName:@"resolution" vectorFloat2:vector2((float)size.width, (float)size.height)]
							 ];

	shaderContainer.shader = shader_move;
}

-(void)update:(NSTimeInterval)currentTime
{
	self.mouseUniform.vectorFloat2Value = vector2(mouseX,mouseY);
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
	CGPoint point = [touch locationInNode:self];
	mouseX = self.frame.size.width - point.x * 2;
	mouseY = 2 * point.y - self.frame.size.height;
}

-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
	CGPoint point = [touch locationInNode:self];
	mouseX = self.frame.size.width - point.x * 2;
	mouseY = 2 * point.y - self.frame.size.height;
}

@end
