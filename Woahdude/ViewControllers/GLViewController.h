//
//  GLViewController.h
//  Woahdude
//
//  Created by Tawa Nicolas on 29/4/17.
//  Copyright © 2017 Tawa Nicolas. All rights reserved.
//

#import <GLKit/GLKit.h>

@interface GLViewController : GLKViewController

@property (assign, nonatomic) CGFloat red;
@property (assign, nonatomic) CGFloat green;
@property (assign, nonatomic) CGFloat blue;
@property (assign, nonatomic) CGFloat timeScale;

@property (strong, nonatomic) NSString *fileName;

@end
