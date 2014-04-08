//
//  VCGridView.m
//  VCGridView
//
//  Created by Vic on 12-10-5.
//  Copyright (c) 2012 ___Vic Studio___. All rights reserved.
//

#import "VCGridView.h"

@class GridRowInfo;
@class GridCellInfo;

#define kVCGridCellDefaultHeight (44.0f)
#define kVCGridCellDefaultWidth  (44.0f)

//_______________________________________________________________________________________________________________
// This items represents the row info and cell info. Not public.

@interface GridRowInfo : NSObject

@property(nonatomic,assign)CGFloat posY;
@property(nonatomic,assign)CGFloat rowHeight;
@property(nonatomic,assign)NSInteger rowIndex;
@property(nonatomic,strong)NSMutableArray *cellInfoArray;

@end

@interface GridCellInfo : NSObject

@property(nonatomic,assign)CGFloat posX;
@property(nonatomic,assign)CGFloat width;
@property(nonatomic,assign)NSInteger columnIndex;

@end


//_______________________________________________________________________________________________________________
// VCGridView Implementation

@interface VCGridView()

@property(nonatomic,strong)NSMutableArray *rowInfoArray;
@property(nonatomic,strong)NSMutableSet *reuseCellSet;
@property(nonatomic,strong)NSMutableSet *onuseCellSet;
@property(nonatomic,assign)VCGridCell *touchCell;

@end

@implementation VCGridView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.reuseCellSet = [NSMutableSet set];
        self.onuseCellSet = [NSMutableSet set];
        self.alwaysVerticalScrollEnabled = YES;
    }
    return self;
}

-(void)setDataSource:(id<VCGridViewDataSource>)dataSource
{
    if(_dataSource != dataSource){
        _dataSource = dataSource;
        [self reloadData];
    }
}

-(void)setGridOffset:(CGPoint)gridOffset
{
    if(!CGPointEqualToPoint(_gridOffset, gridOffset)){
        _gridOffset = gridOffset;
        [self reloadData];
    }
}

#pragma mark - 
#pragma mark - Data method

-(CGSize)loadGridInfoFromDatasource
{
    CGSize contentSize = CGSizeMake(0, 0);
    NSInteger row = 0;
    if([self.dataSource respondsToSelector:@selector(numberOfRowInGridView:)]){
        row = [self.dataSource numberOfRowInGridView:self];
    }
    self.rowInfoArray = [NSMutableArray arrayWithCapacity:row];
    CGFloat posY = self.gridOffset.y;
    for(NSInteger i = 0; i < row && row > 0; i++){
        GridRowInfo *rowInfo = [[GridRowInfo alloc] init];
        rowInfo.rowIndex = i;
        rowInfo.rowHeight = kVCGridCellDefaultHeight;
        if([self.dataSource respondsToSelector:@selector(heightForRow:inGridView:)]){
            rowInfo.rowHeight = [self.dataSource heightForRow:i inGridView:self];
        }
        NSInteger columnCount = 0;
        if([self.dataSource respondsToSelector:@selector(numberOfColumnInRow:inGridView:)]){
            columnCount = [self.dataSource numberOfColumnInRow:i inGridView:self];
        }
        CGFloat posX = self.gridOffset.x;
        for(NSInteger j = 0 ; j < columnCount && columnCount > 0; j++){
            CGFloat width =  kVCGridCellDefaultWidth;
            if([self.dataSource respondsToSelector:@selector(widthForColumn:inRow:inGridView:)]){
                width = [self.dataSource widthForColumn:j inRow:i inGridView:self];
            }
            GridCellInfo *info = [[GridCellInfo alloc] init];
            info.width = width;
            info.posX = posX;
            info.columnIndex  = j;
            posX += width;
            [rowInfo.cellInfoArray addObject:info];
        }
        rowInfo.posY = posY;
        posY += rowInfo.rowHeight;
        [self.rowInfoArray addObject:rowInfo];
        if(posX > contentSize.width){
            contentSize.width = posX;
        }
    }
    contentSize.height = posY;
    return contentSize;
}

#pragma mark - 
#pragma mark - Layout method

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    NSMutableArray *useArray = [NSMutableArray array];
    for(NSInteger row = 0 ;row < self.rowInfoArray.count; row++){
        GridRowInfo *rowInfo = [self.rowInfoArray objectAtIndex:row];
        if(rowInfo.posY + rowInfo.rowHeight < self.contentOffset.y){
            continue;
        }
        if(rowInfo.posY > self.contentOffset.y + self.bounds.size.height){
            break;
        }
        for(NSInteger column = 0 ; column < rowInfo.cellInfoArray.count ; column ++){
            GridCellInfo *cellInfo = [rowInfo.cellInfoArray objectAtIndex:column];
            if(cellInfo.posX + cellInfo.width < self.contentOffset.x){
                continue;
            }
            if(cellInfo.posX > self.contentOffset.x + self.bounds.size.width){
                break;
            }
            CGRect cellRect = CGRectMake(cellInfo.posX, rowInfo.posY, cellInfo.width, rowInfo.rowHeight);
            VCGridCell *cell = [self onUseCellForRect:cellRect];
            if(!cell){
                cell = [self.dataSource cellForIndexPath:[VCGridIndexPath indexPathForRow:rowInfo.rowIndex column:cellInfo.columnIndex] inGridView:self];
                NSAssert([cell isKindOfClass:[VCGridCell class]], @"Not a support grid cell!");
                cell.frame = cellRect;
                [self insertSubview:cell atIndex:0];
            }
            [useArray addObject:cell];
        }
    }
    [self fireOnUseCellNotInArray:useArray];
    [self.onuseCellSet removeAllObjects];
    [self.onuseCellSet addObjectsFromArray:useArray];

}

-(VCGridCell*)onUseCellForRect:(CGRect)rect
{
    if(!CGRectIsEmpty(rect)){
        for(VCGridCell *cell in self.onuseCellSet){
            if(CGRectEqualToRect(rect,cell.frame)){
                return cell;
            }
        }
    }
    return nil;
}

-(void)fireOnUseCellNotInArray:(NSArray*)useArray
{
    for(VCGridCell *cell in self.onuseCellSet){
        if(![useArray containsObject:cell]){
            [self.reuseCellSet addObject:cell];
            [cell removeFromSuperview];
        }
    }
}

-(void)removeAllGridCell
{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:self.subviews.count];
    for(UIView *view in self.subviews){
        if([view isKindOfClass:[VCGridCell class]]){
            [array addObject:view];
        }
    }
    for(UIView *view in array){
        [view removeFromSuperview];
    }
}

#pragma mark - 
#pragma mark - Touch Method

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    VCGridCell *touchCell = [self cellForPoint:point];
    if(touchCell){
        if([self.delegate respondsToSelector:@selector(didHighlightRowAtIndexPath:inGridView:)]){
            [self.delegate didHighlightRowAtIndexPath:[self indexPathForCell:touchCell] inGridView:self];
        }
        [touchCell setHighlighted:YES animated:YES];
    }
    self.touchCell = touchCell;
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    VCGridCell *touchCell = [self cellForPoint:point];
    if(touchCell != self.touchCell){
        [self.touchCell setHighlighted:NO];
        if([self.delegate respondsToSelector:@selector(didUnhighlightRowAtIndexPath:inGridView:)]){
            [self.delegate didUnhighlightRowAtIndexPath:[self indexPathForCell:self.touchCell] inGridView:self];
        }
        [touchCell setHighlighted:YES animated:YES];
        if([self.delegate respondsToSelector:@selector(didHighlightRowAtIndexPath:inGridView:)]){
            [self.delegate didHighlightRowAtIndexPath:[self indexPathForCell:touchCell] inGridView:self];
        }
    }
    self.touchCell = touchCell;
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.touchCell setSelected:YES animated:YES];
    VCGridIndexPath *indexPath = [self indexPathForCell:self.touchCell];
    if([self.delegate respondsToSelector:@selector(didSelectCellAtIndexPath:inGridView:)]){
        [self.delegate didSelectCellAtIndexPath:indexPath inGridView:self];
    }
    self.touchCell = nil;
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.touchCell setHighlighted:NO];
    if([self.delegate respondsToSelector:@selector(didUnhighlightRowAtIndexPath:inGridView:)]){
        [self.delegate didUnhighlightRowAtIndexPath:[self indexPathForCell:self.touchCell] inGridView:self];
    }
    self.touchCell = nil;
}

#pragma mark -
#pragma mark - Public Method

- (void)reloadData
{
    [self removeAllGridCell];
    if([self.onuseCellSet count] > 0){
        [self.reuseCellSet addObjectsFromArray:[self.onuseCellSet allObjects]];
        [self.onuseCellSet removeAllObjects];
    }
    CGSize contentSize = [self loadGridInfoFromDatasource];
    if(self.alwaysVerticalScrollEnabled){
        if(contentSize.height <= self.frame.size.height){
            contentSize.height = self.frame.size.height + self.gridOffset.y + 1;
        }
    }
    if(self.alwaysHorizontalScrollEnabled){
        if(contentSize.width <= self.frame.size.width){
            contentSize.width = self.frame.size.width + self.gridOffset.x + 1;
        }
    }
    [self setContentSize:contentSize];
    [self setNeedsLayout];
}

- (NSInteger)numberOfColumnInRow:(NSUInteger)row
{
    if(row > self.rowInfoArray.count || self.rowInfoArray.count == 0){
        return 0;
    }
    GridRowInfo *info = [self.rowInfoArray objectAtIndex:row];
    return [info.cellInfoArray count];
}

- (NSInteger)numberOfRow
{
    return [self.rowInfoArray count];
}

- (VCGridIndexPath *)indexPathForCell:(VCGridCell *)cell
{
    for(VCGridCell * useCell in self.onuseCellSet){
        if(cell == useCell){
            return [self indexPathForFrame:cell.frame];
        }
    }
    return nil;
}

- (VCGridCell *)cellForRowAtIndexPath:(VCGridIndexPath *)indexPath
{
    CGRect frame = [self frameForIndexPath:indexPath];
    return [self onUseCellForRect:frame];
}

- (NSArray *)visibleCells
{
    //sort by frame
    NSArray *allCells = [self.onuseCellSet allObjects];
    NSArray *sortArray = [allCells sortedArrayUsingComparator:^NSComparisonResult(VCGridCell *obj1, VCGridCell *obj2) {
        NSComparisonResult result;
        if(obj1.frame.origin.y < obj2.frame.origin.y){
            result = NSOrderedAscending;
        }else if(obj1.frame.origin.y == obj2.frame.origin.y){
            if(obj1.frame.origin.x < obj2.frame.origin.x){
                result = NSOrderedAscending;
            }else if(obj1.frame.origin.x == obj2.frame.origin.x){
                result = NSOrderedSame;
            }else{
                result = NSOrderedDescending;
            }
        }else {
            result = NSOrderedDescending;
        }
        return result;
    }];
    return [NSArray arrayWithArray:sortArray];
}

- (void)scrollToRowAtIndexPath:(VCGridIndexPath *)indexPath animated:(BOOL)animated
{
    CGRect frame = [self frameForIndexPath:indexPath];
    [self scrollRectToVisible:frame animated:animated];
}

- (void)selectRowAtIndexPath:(VCGridIndexPath *)indexPath animated:(BOOL)animated
{
    VCGridCell *cell = [self cellForRowAtIndexPath:indexPath];
    [cell setSelected:YES animated:animated];
}
- (void)deselectRowAtIndexPath:(VCGridIndexPath *)indexPath animated:(BOOL)animated
{
    VCGridCell *cell = [self cellForRowAtIndexPath:indexPath];
    [cell setSelected:NO animated:animated];
}

- (VCGridCell*)dequeueReusableCellWithIdentifier:(NSString *)identifier
{
    VCGridCell *reuseCell = nil;
    for(VCGridCell *cell in self.reuseCellSet){
        if([cell.reuseIdentifier isEqualToString:identifier]){
            reuseCell = cell;
        }
    }
    if(reuseCell){
        [reuseCell prepareForReuse];
        [self.reuseCellSet removeObject:reuseCell];
    }
    return reuseCell;
}



#pragma mark -
#pragma mark - Private Method

-(VCGridIndexPath*)indexPathForFrame:(CGRect)frame
{
    for(NSInteger row = 0 ; row < self.rowInfoArray.count; row++){
        GridRowInfo *rowInfo = [self.rowInfoArray objectAtIndex:row];
        if(rowInfo.posY == frame.origin.y){
            for(NSInteger column = 0 ; column < rowInfo.cellInfoArray.count; column++){
                GridCellInfo *cellInfo = [rowInfo.cellInfoArray objectAtIndex:column];
                if(cellInfo.posX == frame.origin.x){
                    return [VCGridIndexPath indexPathForRow:row column:column];
                }
            }
        }
    }
    return nil;
}


-(CGRect)frameForIndexPath:(VCGridIndexPath*)indexPath
{
    if(indexPath.row < self.rowInfoArray.count){
        GridRowInfo *rowInfo = [self.rowInfoArray objectAtIndex:indexPath.row];
        if(indexPath.column < rowInfo.cellInfoArray.count){
            GridCellInfo *cellInfo = [rowInfo.cellInfoArray objectAtIndex:indexPath.column];
            CGRect frame = CGRectMake(cellInfo.posX, rowInfo.posY, cellInfo.width,rowInfo.rowHeight);
            return frame;
        }
    }
    return CGRectZero;
}

-(VCGridCell*)cellForPoint:(CGPoint)point
{
    for(VCGridCell *cell in self.onuseCellSet){
        if(CGRectContainsPoint(cell.frame, point)){
            return cell;
        }
    }
    return nil;
}

@end

#pragma mark -
#pragma mark - DataInfo Method

//_______________________________________________________________________________________________________________
// row and column

@implementation VCGridIndexPath

+(VCGridIndexPath*)indexPathForRow:(NSInteger)row column:(NSInteger)column
{
    VCGridIndexPath *indexPath = [[VCGridIndexPath alloc] init];
    indexPath.row = row;
    indexPath.column = column;
    
    return indexPath;
}

@end

//_______________________________________________________________________________________________________________
// This items represents the row info and cell info. Not public.

@implementation GridRowInfo

-(id)init
{
    self = [super init];
    if(self){
        self.cellInfoArray = [NSMutableArray array];
    }
    return self;
}

@end


@implementation GridCellInfo

@end

