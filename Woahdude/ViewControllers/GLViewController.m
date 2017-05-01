//
//  GLViewController.m
//  Woahdude
//
//  Created by Tawa Nicolas on 29/4/17.
//  Copyright © 2017 Tawa Nicolas. All rights reserved.
//

#import "GLViewController.h"
#import "GameScene.h"

@implementation SKScene (Unarchive)

+(instancetype)unarchiveFromFile:(NSString *)file
{
	NSString *nodePath = [[NSBundle mainBundle] pathForResource:file ofType:@"sks"];
	
	NSData *data = [NSData dataWithContentsOfFile:nodePath options:NSDataReadingMappedIfSafe error:nil];
	
	NSKeyedUnarchiver *arch = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
	[arch setClass:self forClassName:@"SKScene"];
	SKScene *scene = [arch decodeObjectForKey:NSKeyedArchiveRootObjectKey];
	[arch finishDecoding];
	
	return scene;
}

@end

@interface GLViewController ()

@property (strong, nonatomic) GameScene *scene;

@end

@implementation GLViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	SKView *skView = (SKView *)self.view;
	skView.showsFPS = YES;
	skView.showsNodeCount = YES;
	
	self.scene = [GameScene unarchiveFromFile:@"GameScene"];
	self.scene.scaleMode = SKSceneScaleModeFill;
	
}

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	SKView *skView = (SKView *)self.view;
	self.scene.fileName = self.fileName;
	[skView presentScene:self.scene];
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
	self.scene.colorUniform.vectorFloat4Value = vector4((float)self.red, (float)self.green, (float)self.blue, 1.f);
}

@end
