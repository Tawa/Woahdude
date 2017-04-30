//
//  TableViewCell.m
//  Woahdude
//
//  Created by Tawa Nicolas on 29/4/17.
//  Copyright © 2017 Tawa Nicolas. All rights reserved.
//

#import "TableViewCell.h"

@implementation TableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)layoutSubviews
{
	[super layoutSubviews];
	
//	[self.selectedBackgroundView setFrame:CGRectMake(8, 8, self.frame.size.width-16, self.frame.size.height-16)];
}

@end
