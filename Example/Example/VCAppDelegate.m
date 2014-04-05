//
//  VCAppDelegate.m
//  Example
//
//  Created by Vic on 4/5/14.
//  Copyright (c) 2014 ___Vic Studio___. All rights reserved.
//

#import "VCAppDelegate.h"
#import "VCGridView.h"

@implementation VCAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    VCGridView *grid = [[VCGridView alloc] initWithFrame:self.window.bounds];
    grid.dataSource = self;
    grid.delegate = self;
    
    [self.window addSubview:grid];
    
    
    return YES;
}

#pragma mark - 
#pragma mark - Datasource method

-(NSInteger)numberOfRowInGridView:(VCGridView*)view
{
    return 10;
}

-(NSInteger)numberOfColumnInRow:(NSInteger)row inGridView:(VCGridView*)view
{
    return 4;
}

-(VCGridCell*)cellForIndexPath:(VCGridIndexPath*)indexPath inGridView:(VCGridView*)view
{
    static NSString *identifier = @"TEST";
    VCGridCell *cell = [view dequeueReusableCellWithIdentifier:identifier];
    if(cell == nil){
        cell = [[VCGridCell alloc] initWithReuseIdentifier:identifier];
    }
    UILabel *label = [[UILabel alloc] init];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = [NSString stringWithFormat:@"(%d,%d)",indexPath.row,indexPath.column];
    cell.backgroundView = label;
    
    return cell;
}

-(CGFloat)heightForRow:(NSInteger)row inGridView:(VCGridView*)view
{
    return 100.0f;
}

-(CGFloat)widthForColumn:(NSInteger)column inRow:(NSInteger)row inGridView:(VCGridView*)view
{
    return 80.0f;
}

#pragma mark - 
#pragma mark - Delegate method

-(void)didSelectCellForIndexPath:(VCGridIndexPath *)indexPath inGridView:(VCGridView *)view
{
    [view deselectRowAtIndexPath:indexPath animated:YES];
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
