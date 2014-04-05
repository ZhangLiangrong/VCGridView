//
//  VCGridView.h
//  VCGridView
//
//  Created by Vic on 12-10-5.
//  Copyright (c) 2012 ___Vic Studio___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VCGridCell.h"

@class VCGridView;
@protocol VCGridViewDataSource;
@class VCGridIndexPath;

//_______________________________________________________________________________________________________________
// this represents the display and behaviour of the cells.

@protocol VCGridViewDelegate<NSObject, UIScrollViewDelegate>

@optional

-(void)didHighlightRowAtIndexPath:(VCGridIndexPath*)indexPath inGridView:(VCGridView*)view;
-(void)didUnhighlightRowAtIndexPath:(VCGridIndexPath*)indexPath inGridView:(VCGridView*)view;

-(void)didSelectCellAtIndexPath:(VCGridIndexPath*)indexPath inGridView:(VCGridView*)view;      //when a cell is selected, it was highlight
-(void)didDeselectRowAtIndexPath:(VCGridIndexPath*)indexPath inGridView:(VCGridView*)view;

@end


@interface VCGridView : UIScrollView

@property (nonatomic, weak)   id <VCGridViewDataSource> dataSource;   //Datasource changes will call reloadData automatically.
@property (nonatomic, weak)   id <VCGridViewDelegate>   delegate;
@property (nonatomic, readwrite, strong) UIView *backgroundView;


- (void)reloadData;           //reloadData will remove all visible cells and rebuild.

- (NSInteger)numberOfColumnInRow:(NSUInteger)row;

- (NSInteger)numberOfRow;

- (VCGridIndexPath *)indexPathForCell:(VCGridCell *)cell;                      // returns nil if cell is not visible

- (VCGridCell *)cellForRowAtIndexPath:(VCGridIndexPath *)indexPath;            // returns nil if cell is not visible or index path is out of range

- (NSArray *)visibleCells;           //return all visible cells order by frame.

- (void)scrollToRowAtIndexPath:(VCGridIndexPath *)indexPath animated:(BOOL)animated;   //if indexPath not visible

// Selects and deselects rows. This method will not call gridView delegate method didSelectCellAtIndexPath:inGridView: eg.
- (void)selectRowAtIndexPath:(VCGridIndexPath *)indexPath animated:(BOOL)animated;
- (void)deselectRowAtIndexPath:(VCGridIndexPath *)indexPath animated:(BOOL)animated;

//@property(nonatomic,strong) UIView *gridHeaderView;                            // accessory view for above row content. default is nil.
//@property(nonatomic,strong) UIView *gridFooterView;                            // accessory view below content. default is nil.

- (VCGridCell*)dequeueReusableCellWithIdentifier:(NSString *)identifier;  // Used by the delegate to acquire an already allocated cell, in lieu of allocating a new one.

@end

//_______________________________________________________________________________________________________________
// this protocol represents the data model object. as such, it supplies no information about appearance (including the cells)

@protocol VCGridViewDataSource <NSObject>

@required

-(NSInteger)numberOfRowInGridView:(VCGridView*)view;                                        //Default is 0.

-(NSInteger)numberOfColumnInRow:(NSInteger)row inGridView:(VCGridView*)view;                //Default is 0.

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:

-(VCGridCell*)cellForIndexPath:(VCGridIndexPath*)indexPath inGridView:(VCGridView*)view;    //Must return a VCGridCell, can't not be nil.

@optional

-(CGFloat)heightForRow:(NSInteger)row inGridView:(VCGridView*)view;                             //Default is 44.0 px.

-(CGFloat)widthForColumn:(NSInteger)column inRow:(NSInteger)row inGridView:(VCGridView*)view;   //Default is 44.0 px.

@end

//_______________________________________________________________________________________________________________
// row and column

@interface VCGridIndexPath : NSObject

@property(nonatomic,assign)NSInteger row;
@property(nonatomic,assign)NSInteger column;

+(VCGridIndexPath*)indexPathForRow:(NSInteger)row column:(NSInteger)column;

@end


