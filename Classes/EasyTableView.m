//
//  EasyTableView.m
//  EasyTableView
//
//  Created by Aleksey Novicov on 5/30/10.
//  Copyright 2010 Yodel Code. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "EasyTableView.h"

#define kDefaultCellWidthOrHeight 44.0

#define EasyTableViewOrientationIsHorizontal(orientation) ((orientation) == EasyTableViewOrientationLeftToRight || (orientation) == EasyTableViewOrientationRightToLeft)
#define EasyTableViewOrientationIsVertical(orientation) ((orientation) == EasyTableViewOrientationTopToBottom || (orientation) == EasyTableViewOrientationBottomToTop)


@interface EasyTableView() <UITableViewDelegate, UITableViewDataSource>
- (void)createTable;
- (void)prepareRotatedView:(UIView *)rotatedView forCellAtIndexPath:(NSIndexPath *)indexPath;
- (void)setDataForRotatedView:(UIView *)rotatedView forIndexPath:(NSIndexPath *)indexPath;
- (CGPoint)rotatedOffset:(CGPoint)offset;
@end


@implementation EasyTableView
@synthesize delegate = _delegate, dataSource = _dataSource, cellBackgroundColor = _cellBackgroundColor, selectedIndexPath = _selectedIndexPath, orientation = _orientation;

#pragma mark -
#pragma mark Initialization


- (id)initWithFrame:(CGRect)frame orientation:(EasyTableViewOrientation)orientation {
    if (self = [super initWithFrame:frame]) {
        _orientation = orientation;
		[self createTable];
	}
    return self;
}


- (void)createTable {
	// Save the orientation so that the table view cell knows how to set itself up
	
	UITableView *tableView;
	if (EasyTableViewOrientationIsHorizontal(_orientation)) {
		int xOrigin	= (self.bounds.size.width - self.bounds.size.height)/2;
		int yOrigin	= (self.bounds.size.height - self.bounds.size.width)/2;
		tableView	= [[UITableView alloc] initWithFrame:CGRectMake(xOrigin, yOrigin, self.bounds.size.height, self.bounds.size.width)];
	} else {
		tableView	= [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
    }
	
	tableView.tag				= TABLEVIEW_TAG;
	tableView.delegate			= self;
	tableView.dataSource		= self;
	tableView.autoresizingMask	= UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	
	// Rotate the tableView as required by the orientation
	if (_orientation == EasyTableViewOrientationLeftToRight) {
		tableView.transform	= CGAffineTransformMakeRotation(-M_PI/2);
    } else if (_orientation == EasyTableViewOrientationBottomToTop) {
		tableView.transform	= CGAffineTransformMakeRotation(M_PI);
    } else if (_orientation == EasyTableViewOrientationRightToLeft) {
		tableView.transform	= CGAffineTransformMakeRotation(M_PI/2);
    }
	
	tableView.showsVerticalScrollIndicator	 = NO;
	tableView.showsHorizontalScrollIndicator = NO;
	
	[self addSubview:tableView];
}


- (void)reloadData {
    [self.tableView reloadData];
}


#pragma mark -
#pragma mark Properties

- (UITableView *)tableView {
	return (UITableView *)[self viewWithTag:TABLEVIEW_TAG];
}


- (NSArray *)visibleViews {
	NSArray *visibleCells = [self.tableView visibleCells];
	NSMutableArray *visibleViews = [NSMutableArray arrayWithCapacity:[visibleCells count]];
	
	for (UIView *aView in visibleCells) {
		[visibleViews addObject:[aView viewWithTag:CELL_CONTENT_TAG]];
	}
    
	return visibleViews;
}

- (CGPoint)rotatedOffset:(CGPoint)offset {
	if (_orientation == EasyTableViewOrientationLeftToRight) {
		offset = CGPointMake(offset.y, offset.x);
    } else if (_orientation == EasyTableViewOrientationBottomToTop) {
        offset = CGPointMake(self.bounds.size.width - offset.x, self.bounds.size.height - offset.y);
    } else if (_orientation == EasyTableViewOrientationRightToLeft) {
        offset = CGPointMake(self.bounds.size.height - offset.y, self.bounds.size.width - offset.x);
    }
	return offset;
}


- (CGPoint)contentOffset {
	return [self rotatedOffset:self.tableView.contentOffset];
}


- (void)setContentOffset:(CGPoint)offset {
    self.tableView.contentOffset = [self rotatedOffset:offset];
}


- (void)setContentOffset:(CGPoint)offset animated:(BOOL)animated {
    offset = [self rotatedOffset:offset];
	[self.tableView setContentOffset:offset animated:animated];
}


#pragma mark -
#pragma mark Selection

- (void)selectCellAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated {
	self.selectedIndexPath	= indexPath;
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:animated];
}


- (void)setSelectedIndexPath:(NSIndexPath *)indexPath {
	if (![_selectedIndexPath isEqual:indexPath]) {
		_selectedIndexPath = indexPath;
		if ([_delegate respondsToSelector:@selector(easyTableView:didSelectCellAtIndexPath:)]) {
			[_delegate easyTableView:self didSelectCellAtIndexPath:indexPath];
		}
	}
}

#pragma mark -
#pragma mark Multiple Sections

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if ([_dataSource respondsToSelector:@selector(easyTableView:viewForHeaderInSection:)]) {
        UIView *headerView = [_dataSource easyTableView:self viewForHeaderInSection:section];
        if (EasyTableViewOrientationIsHorizontal(_orientation)) {
			return headerView.frame.size.width;
		} else {
			return headerView.frame.size.height;
        }
    }
    return 0.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if ([_dataSource respondsToSelector:@selector(easyTableView:viewForFooterInSection:)]) {
        UIView *footerView = [_dataSource easyTableView:self viewForFooterInSection:section];
        if (EasyTableViewOrientationIsHorizontal(_orientation)) {
			return footerView.frame.size.width;
		} else {
			return footerView.frame.size.height;
        }
    }
    return 0.0;
}

- (UIView *)viewToHoldSectionView:(UIView *)sectionView {
	// Enforce proper section header/footer view height abd origin. This is required because
	// of the way UITableView resizes section views on orientation changes.
	if (EasyTableViewOrientationIsHorizontal(_orientation)) {
		sectionView.frame = CGRectMake(0, 0, sectionView.frame.size.width, self.frame.size.height);
    }
	
	UIView *rotatedView = [[UIView alloc] initWithFrame:sectionView.frame];
	
	if (_orientation == EasyTableViewOrientationLeftToRight) {
		rotatedView.transform = CGAffineTransformMakeRotation(M_PI/2);
		sectionView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    } else if (_orientation == EasyTableViewOrientationBottomToTop) {
		rotatedView.transform = CGAffineTransformMakeRotation(M_PI);
		sectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    } else if (_orientation == EasyTableViewOrientationRightToLeft) {
		rotatedView.transform = CGAffineTransformMakeRotation(-M_PI/2);
		sectionView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
    } else {
		sectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    }
    
	[rotatedView addSubview:sectionView];
	return rotatedView;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if ([_dataSource respondsToSelector:@selector(easyTableView:viewForHeaderInSection:)]) {
		UIView *sectionView = [_dataSource easyTableView:self viewForHeaderInSection:section];
		return [self viewToHoldSectionView:sectionView];
    }
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if ([_dataSource respondsToSelector:@selector(easyTableView:viewForFooterInSection:)]) {
		UIView *sectionView = [_dataSource easyTableView:self viewForFooterInSection:section];
		return [self viewToHoldSectionView:sectionView];
    }
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([_dataSource respondsToSelector:@selector(numberOfSectionsInEasyTableView:)]) {
        return [_dataSource numberOfSectionsInEasyTableView:self];
    }
    return 1;
}

#pragma mark -
#pragma mark Location and Paths

- (UIView *)viewAtIndexPath:(NSIndexPath *)indexPath {
	UIView *cell = [self.tableView cellForRowAtIndexPath:indexPath];
	return [cell viewWithTag:CELL_CONTENT_TAG];
}

- (NSIndexPath *)indexPathForView:(UIView *)view {
	NSArray *visibleCells = [self.tableView visibleCells];
	
	__block NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
	
	[visibleCells enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		UITableViewCell *cell = obj;
        
		if ([cell viewWithTag:CELL_CONTENT_TAG] == view) {
            indexPath = [self.tableView indexPathForCell:cell];
			*stop = YES;
		}
	}];
	return indexPath;
}

- (CGPoint)offsetForView:(UIView *)view {
	// Get the location of the cell
	CGPoint cellOrigin = [view convertPoint:view.frame.origin toView:self];
	
	// No need to compensate for orientation since all values are already adjusted for orientation
	return cellOrigin;
}

#pragma mark -
#pragma mark TableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
	[self setSelectedIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([_dataSource respondsToSelector:@selector(easyTableView:heightOrWidthForCellAtIndexPath:)]) {
        return [_dataSource easyTableView:self heightOrWidthForCellAtIndexPath:indexPath];
    }
    return kDefaultCellWidthOrHeight;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	// Don't allow the currently selected cell to be selectable
	if ([_selectedIndexPath isEqual:indexPath]) {
		return nil;
	}
	return indexPath;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	if ([_delegate respondsToSelector:@selector(easyTableView:didScrollToContentOffset:)]) {
		[_delegate easyTableView:self didScrollToContentOffset:self.contentOffset];
    }
}

#pragma mark -
#pragma mark TableViewDataSource

- (void)setBoundsForCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    CGFloat heightOrWidth = [_dataSource easyTableView:self heightOrWidthForCellAtIndexPath:indexPath];
	if (EasyTableViewOrientationIsHorizontal(_orientation)) {
		cell.bounds	= CGRectMake(0, 0, self.bounds.size.height, heightOrWidth);
	} else {
		cell.bounds	= CGRectMake(0, 0, self.bounds.size.width, heightOrWidth);
	}
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *defaultIdentifier = @"EasyTableViewCell";
    
    NSString *reuseIdentifier = defaultIdentifier;
    if ([_dataSource respondsToSelector:@selector(easyTableView:reuseIdentifierForCellAtIndexPath:)]) {
        reuseIdentifier = [_dataSource easyTableView:self reuseIdentifierForCellAtIndexPath:indexPath];
    }
    
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
		
        [self setBoundsForCell:cell atIndexPath:indexPath];
		
		cell.contentView.frame = cell.bounds;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		
		// Add a view to the cell's content view that is rotated to compensate for the table view rotation
		CGRect viewRect;
        if (EasyTableViewOrientationIsHorizontal(_orientation)) {
			viewRect = CGRectMake(0, 0, cell.bounds.size.height, cell.bounds.size.width);
		} else {
			viewRect = CGRectMake(0, 0, cell.bounds.size.width, cell.bounds.size.height);
        }
		
		UIView *rotatedView				= [[UIView alloc] initWithFrame:viewRect];
		rotatedView.tag					= ROTATED_CELL_VIEW_TAG;
		rotatedView.center				= cell.contentView.center;
		rotatedView.backgroundColor		= self.cellBackgroundColor;
		
        if (_orientation == EasyTableViewOrientationLeftToRight) {
            rotatedView.transform = CGAffineTransformMakeRotation(M_PI/2);
			rotatedView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        } else if (_orientation == EasyTableViewOrientationBottomToTop) {
            rotatedView.transform = CGAffineTransformMakeRotation(M_PI);
            rotatedView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        } else if (_orientation == EasyTableViewOrientationRightToLeft) {
            rotatedView.transform = CGAffineTransformMakeRotation(-M_PI/2);
			rotatedView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        } else {
            rotatedView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        }
		
		// We want to make sure any expanded content is not visible when the cell is deselected
		rotatedView.clipsToBounds = YES;
		
		// Prepare and add the custom subviews
		[self prepareRotatedView:rotatedView forCellAtIndexPath:indexPath];
		
		[cell.contentView addSubview:rotatedView];
	}
    [self setBoundsForCell:cell atIndexPath:indexPath];
	
	[self setDataForRotatedView:[cell.contentView viewWithTag:ROTATED_CELL_VIEW_TAG] forIndexPath:indexPath];
    return cell;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSUInteger numOfItems = 0;
	
	if ([_dataSource respondsToSelector:@selector(easyTableView:numberOfCellsInSection:)]) {
		numOfItems = [_dataSource easyTableView:self numberOfCellsInSection:section];
		
		// Animate any changes in the number of items
		[tableView beginUpdates];
		[tableView endUpdates];
	}
	
    return numOfItems;
}

#pragma mark -
#pragma mark Rotation

- (void)prepareRotatedView:(UIView *)rotatedView forCellAtIndexPath:(NSIndexPath *)indexPath {
    UIView *content = [_dataSource easyTableView:self viewForRect:rotatedView.bounds forCellAtIndexPath:indexPath];
	
	// Add a default view if none is provided
	if (content == nil) {
		content = [[UIView alloc] initWithFrame:rotatedView.bounds];
    }
	
	content.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	content.tag = CELL_CONTENT_TAG;
	[rotatedView addSubview:content];
}


- (void)setDataForRotatedView:(UIView *)rotatedView forIndexPath:(NSIndexPath *)indexPath {
	UIView *content = [rotatedView viewWithTag:CELL_CONTENT_TAG];
    [_dataSource easyTableView:self setDataInView:content forCellAtIndexPath:indexPath];
}


@end

