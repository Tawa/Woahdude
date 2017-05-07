//
//  Shaders.m
//  Woahdude
//
//  Created by Tawa Nicolas on 7/5/17.
//  Copyright © 2017 Tawa Nicolas. All rights reserved.
//

#import "Shaders.h"

@implementation Shaders

+(BOOL)shouldCacheSharedInstance
{
	return YES;
}

+(NSString *)fileName
{
	return @"shaders";
}

-(instancetype)init
{
	self = [super init];
	
	if (self) {
		self.shaders = [NSMutableArray array];
	}
	
	return self;
}

@end
