//
//  EditorViewController.m
//  Woahdude
//
//  Created by Tawa Nicolas on 7/5/17.
//  Copyright © 2017 Tawa Nicolas. All rights reserved.
//

#import "EditorViewController.h"
#import "QEDTextView.h"
#import "Shaders.h"

@interface EditorViewController () <UITextViewDelegate>

@property (nonatomic, strong) QEDTextView *textView;

@end

@implementation EditorViewController

#pragma mark - View Lifecycle

-(void)awakeFromNib
{
	[super awakeFromNib];
	
	self.fileName = nil;
	
	self.isNew = NO;
	self.isFork = NO;

	UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleDone target:self action:@selector(saveAction:)];
	
	[self.navigationItem setRightBarButtonItem:saveButton animated:YES];
}

-(void)setFileName:(NSString *)fileName
{
	_fileName = fileName;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.view.backgroundColor = [UIColor whiteColor];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
	
	QEDTextView *textView = [[QEDTextView alloc] initWithFrame:self.view.bounds];
	textView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
	textView.delegate = self;
	
	self.textView = textView;
	
	[self.view addSubview:textView];

	if (!self.isNew) {
		NSString *path = [[NSBundle mainBundle] pathForResource:self.fileName ofType:@"fsh"];

		if (self.isCustom) {
			NSString *docDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
			path = [[docDir stringByAppendingPathComponent:self.fileName] stringByAppendingPathExtension:@"fsh"];
		}

		NSError *error;
		NSString *content = [NSString stringWithContentsOfFile:path encoding:kCFStringEncodingUTF8 error:&error];
		
		if (error) {
			self.textView.text = @"Error!";
		} else {
			self.textView.text = content;
		}
	} else {
		
	}
	
	if (self.isFork || self.isNew) {
		NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
		formatter.dateStyle = NSDateFormatterMediumStyle;
		formatter.timeStyle = NSDateFormatterMediumStyle;
		
		self.fileName = [formatter stringFromDate:[NSDate date]];
	}
	self.navigationItem.title = self.fileName;
}

#pragma mark - Notification Handlers

- (void)keyboardWillShow:(NSNotification*)aNotification
{
	UIBarButtonItem *dismissButton = [[UIBarButtonItem alloc] initWithTitle:@"Dismiss" style:UIBarButtonItemStyleDone target:self action:@selector(dismissKeyboard)];
	
	[self.navigationItem setRightBarButtonItem:dismissButton animated:YES];
	
	[self moveTextViewForKeyboard:aNotification up:YES];
}

- (void)keyboardWillHide:(NSNotification*)aNotification
{
	UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleDone target:self action:@selector(saveAction:)];
	
	[self.navigationItem setRightBarButtonItem:saveButton animated:YES];

	[self moveTextViewForKeyboard:aNotification up:NO];
}


#pragma mark - Convenience

- (void)moveTextViewForKeyboard:(NSNotification*)aNotification up:(BOOL)up
{
	NSDictionary* userInfo = [aNotification userInfo];
	NSTimeInterval animationDuration;
	UIViewAnimationCurve animationCurve;
	CGRect keyboardEndFrame;
	
	[[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
	[[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
	[[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:animationDuration];
	[UIView setAnimationCurve:animationCurve];
	
	CGRect newFrame = _textView.frame;
	CGRect keyboardFrame = [self.view convertRect:keyboardEndFrame toView:nil];
	newFrame.size.height -= keyboardFrame.size.height * (up?1:-1);
	_textView.frame = newFrame;
	
	[UIView commitAnimations];
}

- (void)dismissKeyboard
{
	[_textView resignFirstResponder];
}

-(void)saveAction:(id)sender
{
	NSString *newFileName = self.fileName;
	NSString *docDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
	NSString *dirName = [docDir stringByAppendingPathComponent:newFileName];
	
	NSError *error;
	[self.textView.text writeToFile:[dirName stringByAppendingPathExtension:@"fsh"] atomically:YES encoding:NSASCIIStringEncoding error:&error];
	
	if (error) {
		NSLog(@"Error = %@", [error localizedDescription]);
	} else {
		if (self.isNew || self.isFork) {
			[[[Shaders sharedInstance] shaders] addObject:newFileName];
			[Shaders save];
			[self.navigationController popToRootViewControllerAnimated:YES];
		} else {
			[self.navigationController popViewControllerAnimated:YES];
		}
	}
}

@end
