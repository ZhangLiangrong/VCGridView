//
//  VCGridCell.m
//  VCGridView
//
//  Created by Vic on 12-10-5.
//  Copyright (c) 2012 ___Vic Studio___. All rights reserved.
//

#import "VCGridCell.h"

#define kAnimationDuration (.3)

@implementation VCGridCell

-(instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super init];
    if (self) {
        // Initialization code
        _reuseIdentifier = reuseIdentifier;
    }
    return self;
}

-(void)setBackgroundView:(UIView *)backgroundView
{
    if(_backgroundView != backgroundView){
        [_backgroundView removeFromSuperview];
        _backgroundView = backgroundView;
        _backgroundView.frame = self.bounds;
        [self insertSubview:_backgroundView atIndex:0];
    }
}

-(void)prepareForReuse
{
    [self setSelected:NO animated:NO];
}

-(void)setSelected:(BOOL)selected
{
    [self setSelected:selected animated:NO];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    if(_selected != selected){
        [self setHighlighted:selected animated:animated];
        _selected = selected;
    }
}

-(void)setHighlighted:(BOOL)highlighted
{
    [self setHighlighted:highlighted animated:NO];
}
- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    if(_highlighted != highlighted){
        _highlighted = highlighted;
        NSTimeInterval duration = animated ? kAnimationDuration : 0.0f;
        self.selectedBackgroundView.frame = self.bounds;
        [self insertSubview:self.selectedBackgroundView aboveSubview:self.backgroundView];
        [UIView animateWithDuration:duration animations:^{
            if(highlighted){
                self.selectedBackgroundView.alpha = 1;
            }else{
                self.selectedBackgroundView.alpha = 0;
            }
        }];
    }
}


@end
