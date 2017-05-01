//
//  GameScene.h
//  Woahdude
//
//  Created by Tawa Nicolas on 30/4/17.
//  Copyright © 2017 Tawa Nicolas. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface GameScene : SKScene

@property (strong, nonatomic) SKUniform *colorUniform;
@property (strong, nonatomic) SKUniform *mouseUniform;

@property (strong, nonatomic) NSString *fileName;

@end
