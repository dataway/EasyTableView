//
//  EasyTableViewController.m
//  EasyTableViewController
//
//  Created by Aleksey Novicov on 5/30/10.
//  Copyright Yodel Code LLC 2010. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "EasyTableViewController.h"
#import "EasyTableView.h"

#define SHOW_MULTIPLE_SECTIONS		1		// If commented out, multiple sections with header and footer views are not shown

#define PORTRAIT_WIDTH				768
#define LANDSCAPE_HEIGHT			(1024-20)
#define HORIZONTAL_TABLEVIEW_HEIGHT	140
#define VERTICAL_TABLEVIEW_WIDTH	180
#define TABLE_BACKGROUND_COLOR		[UIColor clearColor]

#define BORDER_VIEW_TAG				10

#ifdef SHOW_MULTIPLE_SECTIONS
	#define NUM_OF_CELLS			10
	#define NUM_OF_SECTIONS			2
#else
	#define NUM_OF_CELLS			21
#endif

@interface EasyTableViewController (MyPrivateMethods)
- (void)setupHorizontalView;
- (void)setupVerticalView;
@end

@implementation EasyTableViewController

@synthesize bigLabel, verticalView, horizontalView;



- (void)viewDidLoad {
    [super viewDidLoad];
	[self setupVerticalView];
	[self setupHorizontalView];
}


- (void)viewDidUnload {
	[super viewDidUnload];	
	self.bigLabel = nil;
}


- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark -
#pragma mark EasyTableView Initialization

- (void)setupHorizontalView {
	CGRect frameRect	= CGRectMake(0, LANDSCAPE_HEIGHT - HORIZONTAL_TABLEVIEW_HEIGHT, PORTRAIT_WIDTH - VERTICAL_TABLEVIEW_WIDTH, HORIZONTAL_TABLEVIEW_HEIGHT);
	EasyTableView *view	= [[EasyTableView alloc] initWithFrame:frameRect orientation:EasyTableViewOrientationRightToLeft];
	self.horizontalView = view;
	
	horizontalView.delegate						= self;
	horizontalView.dataSource					= self;
	horizontalView.tableView.backgroundColor	= TABLE_BACKGROUND_COLOR;
	horizontalView.tableView.allowsSelection	= YES;
	horizontalView.tableView.separatorColor		= [UIColor darkGrayColor];
	horizontalView.cellBackgroundColor			= [UIColor darkGrayColor];
	horizontalView.autoresizingMask				= UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
	
	[self.view addSubview:horizontalView];
}


- (void)setupVerticalView {
	CGRect frameRect	= CGRectMake(PORTRAIT_WIDTH - VERTICAL_TABLEVIEW_WIDTH, 0, VERTICAL_TABLEVIEW_WIDTH, LANDSCAPE_HEIGHT);
	EasyTableView *view	= [[EasyTableView alloc] initWithFrame:frameRect orientation:EasyTableViewOrientationTopToBottom];
	self.verticalView	= view;
	
	verticalView.delegate					= self;
	verticalView.dataSource					= self;
	verticalView.tableView.backgroundColor	= TABLE_BACKGROUND_COLOR;
	verticalView.tableView.allowsSelection	= YES;
	verticalView.tableView.separatorColor	= [[UIColor blackColor] colorWithAlphaComponent:0.1];
	verticalView.cellBackgroundColor		= [[UIColor blackColor] colorWithAlphaComponent:0.1];
	verticalView.autoresizingMask			= UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	
	// Allow verticalView to scroll up and completely clear the horizontalView
	verticalView.tableView.contentInset		= UIEdgeInsetsMake(0, 0, HORIZONTAL_TABLEVIEW_HEIGHT, 0);
	
	[self.view addSubview:verticalView];
}


#pragma mark -
#pragma mark Utility Methods

- (void)borderIsSelected:(BOOL)selected forView:(UIView *)view {
	UIImageView *borderView		= (UIImageView *)[view viewWithTag:BORDER_VIEW_TAG];
	NSString *borderImageName	= (selected) ? @"selected_border.png" : @"image_border.png";
	borderView.image			= [UIImage imageNamed:borderImageName];
}


#pragma mark -
#pragma mark EasyTableViewDelegate

// These delegate methods support both example views - first delegate method creates the necessary views

- (UIView *)easyTableView:(EasyTableView *)tableView viewForRect:(CGRect)rect forCellAtIndexPath:(NSIndexPath *)indexPath {
	CGRect labelRect		= CGRectMake(10, 10, rect.size.width-20, rect.size.height-20);
	UILabel *label			= [[UILabel alloc] initWithFrame:labelRect];
	label.textAlignment		= UITextAlignmentCenter;
	label.textColor			= [UIColor whiteColor];
	label.font				= [UIFont boldSystemFontOfSize:60];
	
	// Use a different color for the two different examples
	if (tableView == horizontalView) {
        if (indexPath.row % 2 == 0) {
            label.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.3];
        } else {
            label.backgroundColor = [[UIColor yellowColor] colorWithAlphaComponent:0.3];
        }
	} else {
		label.backgroundColor = [[UIColor orangeColor] colorWithAlphaComponent:0.3];
    }
	
	UIImageView *borderView		= [[UIImageView alloc] initWithFrame:label.bounds];
	borderView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	borderView.tag				= BORDER_VIEW_TAG;
	
	[label addSubview:borderView];
		 
	return label;
}

- (NSString *)easyTableView:(EasyTableView *)tableView reuseIdentifierForCellAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row % 2 == 0) {
        return @"redCell";
    } else {
        return @"yellowCell";
    }
}

// Second delegate populates the views with data from a data source

- (void)easyTableView:(EasyTableView *)tableView setDataInView:(UIView *)view forCellAtIndexPath:(NSIndexPath *)indexPath {
	UILabel *label	= (UILabel *)view;
	label.text		= [NSString stringWithFormat:@"%i", indexPath.row];
	
	// selectedIndexPath can be nil so we need to test for that condition
	BOOL isSelected = (tableView.selectedIndexPath) ? ([tableView.selectedIndexPath compare:indexPath] == NSOrderedSame) : NO;
	[self borderIsSelected:isSelected forView:view];		
}

// Optional delegate to track the selection of a particular cell

- (void)easyTableView:(EasyTableView *)tableView selectedView:(UIView *)selectedView atIndexPath:(NSIndexPath *)indexPath deselectedView:(UIView *)deselectedView {
	[self borderIsSelected:YES forView:selectedView];		
	
	if (deselectedView) 
		[self borderIsSelected:NO forView:deselectedView];
	
	UILabel *label	= (UILabel *)selectedView;
	bigLabel.text	= label.text;
}

- (CGFloat)easyTableView:(EasyTableView *)tableView heightOrWidthForCellAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.horizontalView) {
        if (indexPath.row % 2 == 0) {
            return HORIZONTAL_TABLEVIEW_HEIGHT;
        } else {
            return 2 * HORIZONTAL_TABLEVIEW_HEIGHT;
        }
    } else {
        return VERTICAL_TABLEVIEW_WIDTH;
    }
}

#pragma mark -
#pragma mark Optional EasyTableView delegate methods for section headers and footers

#ifdef SHOW_MULTIPLE_SECTIONS

// Delivers the number of sections in the TableView
- (NSUInteger)numberOfSectionsInEasyTableView:(EasyTableView*)tableView{
    return NUM_OF_SECTIONS;
}

// Delivers the number of cells in each section, this must be implemented if numberOfSectionsInEasyTableView is implemented
-(NSUInteger)easyTableView:(EasyTableView *)tableView numberOfCellsInSection:(NSInteger)section {
    return NUM_OF_CELLS;
}

// The height of the header section view MUST be the same as your HORIZONTAL_TABLEVIEW_HEIGHT (horizontal EasyTableView only)
- (UIView *)easyTableView:(EasyTableView*)tableView viewForHeaderInSection:(NSInteger)section {
    UILabel *label = [[UILabel alloc] init];
	label.text = @"HEADER";
	label.textColor = [UIColor whiteColor];
	label.textAlignment = UITextAlignmentCenter;
   
	if (tableView == self.horizontalView) {
		label.frame = CGRectMake(0, 0, VERTICAL_TABLEVIEW_WIDTH, HORIZONTAL_TABLEVIEW_HEIGHT);
	}
	if (tableView == self.verticalView) {
		label.frame = CGRectMake(0, 0, VERTICAL_TABLEVIEW_WIDTH, 20);
	}

    switch (section) {
        case 0:
            label.backgroundColor = [UIColor redColor];
            break;
        default:
            label.backgroundColor = [UIColor blueColor];
            break;
    }
    return label;
}

// The height of the footer section view MUST be the same as your HORIZONTAL_TABLEVIEW_HEIGHT (horizontal EasyTableView only)
- (UIView *)easyTableView:(EasyTableView*)tableView viewForFooterInSection:(NSInteger)section {
    UILabel *label = [[UILabel alloc] init];
	label.text = @"FOOTER";
	label.textColor = [UIColor yellowColor];
	label.textAlignment = UITextAlignmentCenter;
	label.frame = CGRectMake(0, 0, VERTICAL_TABLEVIEW_WIDTH, 20);
    
	if (tableView == self.horizontalView) {
		label.frame = CGRectMake(0, 0, VERTICAL_TABLEVIEW_WIDTH, HORIZONTAL_TABLEVIEW_HEIGHT);
	}
	if (tableView == self.verticalView) {
		label.frame = CGRectMake(0, 0, VERTICAL_TABLEVIEW_WIDTH, 20);
	}
	
    switch (section) {
        case 0:
            label.backgroundColor = [UIColor purpleColor];
            break;
        default:
            label.backgroundColor = [UIColor brownColor];
            break;
    }
    
    return label;
}

#endif

#pragma mark - Flipside View Controller

- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller {
        [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)showInfo:(id)sender {
	FlipsideViewController *controller = [[FlipsideViewController alloc] initWithNibName:@"FlipsideViewController" bundle:nil];
	controller.delegate = self;
	controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	[self presentModalViewController:controller animated:YES];
}

@end
