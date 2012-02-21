//
//  Copyright © 2012 Yuri Kotov
//

#import "AppDelegate.h"

// Controller
#import "ViewController.h"

@implementation AppDelegate

@synthesize window = _window;

#pragma mark - UIApplicationDelegate
- (BOOL) application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    _window.rootViewController = [ViewController new];
    [_window makeKeyAndVisible];
    return YES;
}

@end