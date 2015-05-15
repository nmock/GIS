//
//  AppDelegate.m
//  GoogleImages
//
//  Created by Nathan Mock on 5/13/15.
//  Copyright (c) 2015 Nathan Mock. All rights reserved.
//

#import "AppDelegate.h"
#import "Utilities/UIColor+BFKit.h"
#import "GIImageSearchViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    GIImageSearchViewController *rootVC = [[GIImageSearchViewController alloc] init];
    UINavigationController *navigationVC = [[UINavigationController alloc] initWithRootViewController:rootVC];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = navigationVC;
    [self.window makeKeyAndVisible];
    
    [self applyTheme];
    
    return YES;
}

- (void)applyTheme {
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];

    [[UINavigationBar appearance] setBackgroundColor:[UIColor colorWithHexString:@"448AF5"]];
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithHexString:@"448AF5"]];
}

@end
