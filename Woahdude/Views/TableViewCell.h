//
//  TableViewCell.h
//  Woahdude
//
//  Created by Tawa Nicolas on 29/4/17.
//  Copyright © 2017 Tawa Nicolas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>

@interface TableViewCell : UITableViewCell <GLKViewDelegate>

@property (weak, nonatomic) IBOutlet GLKView *glView;
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (strong, nonatomic) CADisplayLink *displayLink;

-(void)setData:(NSString *)data;

@end
