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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [data count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TableViewCell *cell = (TableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
	NSURL *url = [data objectAtIndex:indexPath.row];
	NSString *fileName = [[url lastPathComponent] stringByDeletingPathExtension];

	[cell setData:fileName];
    return cell;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(TableViewCell *)sender
{
	NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
	NSURL *url = [data objectAtIndex:indexPath.row];
	NSString *fileName = [[url lastPathComponent] stringByDeletingPathExtension];
	
	ViewController *target = [segue destinationViewController];
	target.fileName = fileName;
}

@end
