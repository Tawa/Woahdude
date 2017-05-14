//
//  UIViewController+AlertViewController.m
//  Woahdude
//
//  Created by Tawa Nicolas on 14/5/17.
//  Copyright © 2017 Tawa Nicolas. All rights reserved.
//

#import "UIViewController+AlertViewController.h"

@implementation UIViewController (AlertViewController)

-(void)showError:(NSError *)error
{
	UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:[error localizedDescription] preferredStyle:UIAlertControllerStyleActionSheet];
	[alert addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil]];
	
	[self presentViewController:alert animated:YES completion:nil];
}

@end
