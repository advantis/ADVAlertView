//
//  Copyright © 2011 Yuri Kotov
//  Licensed under the MIT license: http://opensource.org/licenses/MIT
//  Latest version can be found at http://github.com/advantis/ADVAlertView
//


#import <UIKit/UIKit.h>

typedef void(^ADVAlertViewAction) (NSInteger buttonIndex);

@interface ADVAlertView : UIAlertView <UIAlertViewDelegate>

- (NSInteger) addButtonWithTitle:(NSString *)title action:(ADVAlertViewAction)action;

@end