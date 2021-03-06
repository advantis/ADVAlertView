//
//  Copyright © 2012 Yuri Kotov
//

#import "ViewController.h"

// View
#import "ADVAlertView.h"

@implementation ViewController

#pragma mark - ViewController
- (IBAction) alert
{
    ADVAlertView *alertView = [ADVAlertView new];
    alertView.title = @"Title";
    alertView.message = @"Message";
    [alertView addButtonWithTitle:@"Action" action:^{
       NSLog(@"%@", NSStringFromSelector(_cmd));
    }];
    [alertView addButtonWithTitle:@"Cancel"];
    [alertView show];
}

@end