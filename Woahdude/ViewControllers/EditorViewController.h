//
//  EditorViewController.h
//  Woahdude
//
//  Created by Tawa Nicolas on 7/5/17.
//  Copyright © 2017 Tawa Nicolas. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditorViewController : UIViewController

@property (assign, nonatomic) NSString *fileName;

@property (assign, nonatomic) BOOL isNew;
@property (assign, nonatomic) BOOL isFork;

@end
