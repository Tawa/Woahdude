//
//  ViewController.m
//  Woahdude
//
//  Created by Tawa Nicolas on 29/4/17.
//  Copyright © 2017 Tawa Nicolas. All rights reserved.
//

#import "ViewController.h"
#import "GLViewController.h"
#import "EditorViewController.h"

@interface ViewController()

@property (weak, nonatomic) IBOutlet UIStackView *controlsView;
@property (weak, nonatomic) IBOutlet UIStackView *topControlsView;
@property (weak, nonatomic) IBOutlet GLViewController *glViewController;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editButton;

@end

@implementation ViewController

-(void)awakeFromNib
{
	[super awakeFromNib];
	
	self.isNew = NO;
}

-(void)viewDidLoad
{
	[super viewDidLoad];
	
	self.glViewController = [[self childViewControllers] firstObject];
	self.glViewController.fileName = self.fileName;
	self.glViewController.isCustom = self.isCustom;
	
	self.navigationItem.title = self.fileName;
	
	self.glViewController.red = self.redSlider.value;
	self.glViewController.green = self.greenSlider.value;
	self.glViewController.blue = self.blueSlider.value;
	
	self.redSlider.minimumTrackTintColor = [UIColor redColor];
	self.redSlider.maximumTrackTintColor = [UIColor redColor];
	self.greenSlider.minimumTrackTintColor = [UIColor greenColor];
	self.greenSlider.maximumTrackTintColor = [UIColor greenColor];
	self.blueSlider.minimumTrackTintColor = [UIColor blueColor];
	self.blueSlider.maximumTrackTintColor = [UIColor blueColor];
	
	[self.timeScaleSegment setSelectedSegmentIndex:2];
	
	[self.editButton setEnabled:self.isNew];
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
	if (ABS(self.glViewController.timeScale) < 0.1) {
		self.glViewController.timeScale = 0;
	}
}
- (IBAction)segmentValueChanged:(UISegmentedControl *)sender {
	GLKView *view = (GLKView *)self.glViewController.view;
	CGFloat scale = 0;
	switch (sender.selectedSegmentIndex) {
		case 0:
			scale = 0.25f;
			break;
		case 1:
			scale = 0.5f;
			break;
		case 2:
			scale = 1.f;
			break;
		case 3:
			scale = 1.5f;
			break;
		case 4:
			scale = 2.f;
			break;
		default:
			break;
	}
	
	view.contentScaleFactor = scale;
	[self.glViewController setScale:scale];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	EditorViewController *editor = [segue destinationViewController];
	editor.fileName = self.fileName;
	editor.isCustom = self.isCustom;
	if ([[segue identifier] isEqualToString:@"editSegue"]) {
	} else if ([[segue identifier] isEqualToString:@"forkSegue"]) {
		editor.isFork = YES;
	}
}

@end
