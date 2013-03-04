//
//  DEAppDelegate.m
//  DETweeter
//
//  Copyright (c) 2011 Double Encore, Inc. All rights reserved.
//

#import "DEAppDelegate.h"
#import "DEViewController.h"
#import "UIDevice+DETweetComposeViewController.h"

@implementation DEAppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;



#pragma mark - Class Methods


#pragma mark - Setup & Teardown

- (void)dealloc
{
    _window = nil;
    _viewController = nil;
    
}


#pragma mark - UIApplicationDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        // Override point for customization after application launch.
    if ([UIDevice de_isPhone]) {
        self.viewController = [[DEViewController alloc] initWithNibName:@"DEViewController_iPhone" bundle:nil];
    }
    else {
        self.viewController = [[DEViewController alloc] initWithNibName:@"DEViewController_iPad" bundle:nil];
    }
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    return YES;
}


@end
