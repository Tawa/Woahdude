//
//  TableViewController.m
//  Woahdude
//
//  Created by Tawa Nicolas on 29/4/17.
//  Copyright © 2017 Tawa Nicolas. All rights reserved.
//

#import "TableViewController.h"
#import "TableViewCell.h"
#import "ViewController.h"
#import "EditorViewController.h"
#import "Shaders.h"
#import "UIViewController+AlertViewController.h"

@interface TableViewController ()
{
	NSArray *data;
}

@end

@implementation TableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	data = [[NSBundle mainBundle] URLsForResourcesWithExtension:@"fsh" subdirectory:nil];
}

-(void)pause:(BOOL)pause
{
	for (TableViewCell *cell in self.tableView.visibleCells) {
		[cell.displayLink setPaused:pause];
	}
}

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	[self.tableView reloadData];
}

-(void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	[self pause:NO];
}

-(void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];

	[self pause:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section == 1) {
		return [data count];
	}
	
	return [[Shaders sharedInstance].shaders count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TableViewCell *cell = (TableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
	
	NSURL *url;
	NSString *fileName;
	
	if (indexPath.section == 1) {
		url = [data objectAtIndex:indexPath.row];
	} else {
		url = [[Shaders sharedInstance].shaders objectAtIndex:indexPath.row];
	}
	fileName = [[url lastPathComponent] stringByDeletingPathExtension];

	[cell setData:fileName custom:indexPath.section == 0];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	if (section == 0 && [[Shaders sharedInstance].shaders count] == 0) {
		return 0;
	}
	return 50;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	UILabel *label = [[UILabel alloc] init];
	if (section == 1) {
		[label setText:@"\tPredefined"];
	} else {
		[label setText:@"\tCustom"];
	}
	[label sizeToFit];
	
	[label setTextColor:[UIColor whiteColor]];
	[label setBackgroundColor:[UIColor darkGrayColor]];
	
	return label;
}

-(BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
	if (indexPath.section == 1) {
		return NO;
	}
	if (action == @selector(delete:)) {
		return YES;
	}
	
	return NO;
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section == 1) {
		return UITableViewCellEditingStyleNone;
	}
	
	return UITableViewCellEditingStyleDelete;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *fileName = [[Shaders sharedInstance].shaders objectAtIndex:indexPath.row];

	NSString *docDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
	NSString *path = [[docDir stringByAppendingPathComponent:fileName] stringByAppendingPathExtension:@"fsh"];
	NSError *error = nil;
	[[NSFileManager sharedInstance] removeItemAtPath:path error:&error];
	
	if (error) {
		[self showError:error];
	} else {
		[[Shaders sharedInstance].shaders removeObjectAtIndex:indexPath.row];
		[Shaders save];
		[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
	}
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(TableViewCell *)sender
{
	NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
	if ([[segue identifier] isEqualToString:@"createNewShader"]) {
		EditorViewController *target = [segue destinationViewController];
		target.isCustom = indexPath.section == 0;
		target.isNew = YES;
	} else {
		ViewController *target = [segue destinationViewController];
		
		if (indexPath.section == 1) {
			NSURL *url = [data objectAtIndex:indexPath.row];
			NSString *fileName = [[url lastPathComponent] stringByDeletingPathExtension];
			
			target.fileName = fileName;
			target.isCustom = NO;
		} else {
			NSString *fileName = [[Shaders sharedInstance].shaders objectAtIndex:indexPath.row];
			target.isNew = YES;

			target.fileName = fileName;
			target.isCustom = YES;
		}
	}
}

@end
