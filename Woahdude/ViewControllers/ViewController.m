//
//  ViewController.m
//  Woahdude
//
//  Created by Tawa Nicolas on 29/4/17.
//  Copyright © 2017 Tawa Nicolas. All rights reserved.
//

#import "ViewController.h"
#import "GLViewController.h"

@interface ViewController()

@property (weak, nonatomic) IBOutlet UIStackView *controlsView;
@property (weak, nonatomic) IBOutlet UIStackView *topControlsView;
@property (weak, nonatomic) IBOutlet GLViewController *glViewController;

@end

@implementation ViewController

-(void)viewDidLoad
{
	[super viewDidLoad];
	
	self.glViewController = [[self childViewControllers] firstObject];
	self.glViewController.fileName = self.fileName;
	
	self.glViewController.red = self.redSlider.value;
	self.glViewController.green = self.greenSlider.value;
	self.glViewController.blue = self.blueSlider.value;
	
	self.redSlider.minimumTrackTintColor = [UIColor redColor];
	self.redSlider.maximumTrackTintColor = [UIColor redColor];
	self.greenSlider.minimumTrackTintColor = [UIColor greenColor];
	self.greenSlider.maximumTrackTintColor = [UIColor greenColor];
	self.blueSlider.minimumTrackTintColor = [UIColor blueColor];
	self.blueSlider.maximumTrackTintColor = [UIColor blueColor];
	
	[self.timeScaleSegment setSelectedSegmentIndex:3];
}

-(IBAction)tapAction:(UITapGestureRecognizer *)sender
{
	[self toggleUI];
}

-(BOOL)prefersStatusBarHidden
{
	return self.navigationController.navigationBarHidden;
}

-(void)toggleUI
{
	BOOL hide = !self.navigationController.navigationBarHidden;
	[self.navigationController setNavigationBarHidden:hide animated:YES];
	
	if (!hide) {
		[self.controlsView setHidden:NO];
		[self.topControlsView setHidden:NO];
	}
	[UIView animateWithDuration:0.3 animations:^{
		if (hide) {
			self.controlsView.alpha = 0;
			self.topControlsView.alpha = 0;
		} else {
			self.controlsView.alpha = 1;
			self.topControlsView.alpha = 1;
		}
	} completion:^(BOOL finished) {
		if (hide) {
			[self.controlsView setHidden:YES];
			[self.topControlsView setHidden:YES];
		}
	}];
}

-(void)viewDidLayoutSubviews
{
	[super viewDidLayoutSubviews];

	UIWindow *window = [[UIApplication sharedApplication].windows firstObject];
	CGRect frame = [window frame];
	frame = [window convertRect:frame toView:self.view];

	[self.containerView setFrame:frame];
}
- (IBAction)redChanged:(UISlider *)sender {
	self.glViewController.red = sender.value;
}
- (IBAction)greenChanged:(UISlider *)sender {
	self.glViewController.green = sender.value;
}
- (IBAction)blueChanged:(UISlider *)sender {
	self.glViewController.blue = sender.value;
}
- (IBAction)timeScaleChanged:(UISlider *)sender {
	self.glViewController.timeScale = sender.value;
}
- (IBAction)segmentValueChanged:(UISegmentedControl *)sender {
	CGFloat scale = 0;
	switch (sender.selectedSegmentIndex) {
		case 0:
			scale = -2;
			break;
		case 1:
			scale = -1;
			break;
		case 2:
			scale = 0;
			break;
		case 3:
			scale = 1;
			break;
		case 4:
			scale = 2;
			break;
		default:
			break;
	}
	
	[self.timeScaleSlider setValue:scale];
	self.glViewController.timeScale = scale;
}

@end
