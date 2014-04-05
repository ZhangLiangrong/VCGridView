//
//  VCGridCell.h
//  VCGridView
//
//  Created by Vic on 12-10-5.
//  Copyright (c) 2012 ___Vic Studio___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VCGridCell : UIView

@property(nonatomic,strong,readonly)NSString *reuseIdentifier;

-(instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier;

//The 'backgroundView' will be added as a subview behind all other views.
@property (nonatomic, retain) UIView                *backgroundView;

// Default is nil for cells The 'selectedBackgroundView' will be added as a subview directly above the backgroundView if not nil, or behind all other views. It is added as a subview only when the cell is selected.
@property (nonatomic, retain) UIView                *selectedBackgroundView;

- (void)prepareForReuse;                                                        // if the cell is reusable (has a reuse identifier), this is called just before the cell is returned from the table view method dequeueReusableCellWithIdentifier:.  If you override, you MUST call super.

@property (nonatomic, getter=isSelected) BOOL         selected;                   // set selected state (title, image, background). default is NO. animated is NO
@property (nonatomic, getter=isHighlighted) BOOL      highlighted;                // set highlighted state (title, image, background). default is NO. animated is NO

- (void)setSelected:(BOOL)selected animated:(BOOL)animated;                     // animate between regular and selected state
- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated;               // animate between regular and highlighted state

@end
