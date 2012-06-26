//
//  EasyTableView.h
//  EasyTableView
//
//  Created by Aleksey Novicov on 5/30/10.
//  Copyright 2010 Yodel Code. All rights reserved.
//
//
/* ===========================================================================
 
 NOTES:	EasyTableView addresses two concerns. The first is the ability to have
 a table view that only partially fills the screen. Normally one would use
 UITableViewController but that requires table views that fill the whole
 screen. EasyTableView addresses this problem by acting as the controller
 for the embedded table view, and exposing table view functionality
 with it's own delegate methods.
 
 The second concern addressed by EasyTableView is horizontal table views.
 Table views were initially designed to be vertical only. EasyTableView
 solves this problem by rotating the table view, and provides the same
 interface as creating a vertical EasyTableView.
 
 Now you can create simple partial screen table views, either vertically
 or horizontally, with the same interface!
 
 KNOWN LIMITATIONS:
 
 This implementation currently only supports one section. The view relies
 on three reserved view tags, 800 - 802.
 
 A horizontal EasyTableView will correctly auto-resize it's overall length only.
 A horizontal EasyTableView will NOT necessarily correctly auto-resize it's height.
 */

#import <UIKit/UIKit.h>

#define TABLEVIEW_TAG			800
#define ROTATED_CELL_VIEW_TAG	801
#define CELL_CONTENT_TAG		802

typedef enum {
	EasyTableViewOrientationTopToBottom,
	EasyTableViewOrientationLeftToRight,
	EasyTableViewOrientationBottomToTop,
	EasyTableViewOrientationRightToLeft,
} EasyTableViewOrientation;


@class EasyTableView;


@protocol EasyTableViewDelegate <NSObject>
@optional
- (void)easyTableView:(EasyTableView *)tableView didSelectCellAtIndexPath:(NSIndexPath *)indexPath;
- (void)easyTableView:(EasyTableView *)tableView didScrollToContentOffset:(CGPoint)contentOffset;
@end


@protocol EasyTableViewDataSource <NSObject>
- (NSUInteger)easyTableView:(EasyTableView *)tableView numberOfCellsInSection:(NSInteger)section;
- (CGFloat)easyTableView:(EasyTableView *)tableView heightOrWidthForCellAtIndexPath:(NSIndexPath *)indexPath;
- (UIView *)easyTableView:(EasyTableView *)tableView viewForRect:(CGRect)rect forCellAtIndexPath:(NSIndexPath *)indexPath;
- (void)easyTableView:(EasyTableView *)tableView setDataInView:(UIView *)view forCellAtIndexPath:(NSIndexPath *)indexPath;
@optional
- (NSString *)easyTableView:(EasyTableView *)easyTableView reuseIdentifierForCellAtIndexPath:(NSIndexPath *)indexPath;
- (NSUInteger)numberOfSectionsInEasyTableView:(EasyTableView *)easyTableView;
- (UIView*)easyTableView:(EasyTableView *)easyTableView viewForHeaderInSection:(NSInteger)section;
- (UIView*)easyTableView:(EasyTableView *)easyTableView viewForFooterInSection:(NSInteger)section;
@end


@interface EasyTableView : UIView

@property (nonatomic, unsafe_unretained) id<EasyTableViewDelegate> delegate;
@property (nonatomic, unsafe_unretained) id<EasyTableViewDataSource> dataSource;
@property (nonatomic, unsafe_unretained, readonly) UITableView *tableView;
@property (nonatomic, unsafe_unretained, readonly) NSArray *visibleViews;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;
@property (nonatomic, strong) UIColor *cellBackgroundColor;
@property (nonatomic, assign, readonly) EasyTableViewOrientation orientation;
@property (nonatomic, assign) CGPoint contentOffset;

- (id)initWithFrame:(CGRect)frame orientation:(EasyTableViewOrientation)orientation itemSize:(CGFloat)itemSize;
- (void)reloadData;
- (CGPoint)offsetForView:(UIView *)cell;
- (void)setContentOffset:(CGPoint)offset animated:(BOOL)animated;
- (void)selectCellAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated;
- (UIView *)viewAtIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath*)indexPathForView:(UIView *)cell;

@end
