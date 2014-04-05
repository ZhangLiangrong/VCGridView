//
//  VCAppDelegate.h
//  Example
//
//  Created by Vic on 4/5/14.
//  Copyright (c) 2014 ___Vic Studio___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VCGridView.h"

@interface VCAppDelegate : UIResponder <UIApplicationDelegate,VCGridViewDataSource,VCGridViewDelegate>

@property (strong, nonatomic) UIWindow *window;

@end
