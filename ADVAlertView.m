//
//  Copyright © 2011 Yuri Kotov
//  Licensed under the MIT license: http://opensource.org/licenses/MIT
//  Latest version can be found at http://github.com/advantis/ADVAlertView
//


#import "ADVAlertView.h"
#import <objc/runtime.h>

static inline BOOL ProtocolContainsSelector (Protocol *protocol, SEL selector)
{
    return NULL != protocol_getMethodDescription(protocol, selector, NO, YES).name;
}

@interface ADVAlertView ()
@property (nonatomic, strong) NSMutableArray *actions;
@property (nonatomic, weak) id<UIAlertViewDelegate> trueDelegate;
@end

@implementation ADVAlertView

#pragma mark - ADVAlertView
- (NSInteger) addButtonWithTitle:(NSString *)title action:(ADVAlertViewAction)action
{
	NSInteger index = [super addButtonWithTitle:title];
	self.actions[index] = action ?: (ADVAlertViewAction)^{};
	return index;
}

/**
* UIAlertView performs a series of "respondsToSelector" calls on delegate to
* determine which of the optional protocol methods it implements and cache
* this info. Therefore we need to force it to update this info for a new delegate.
*/
- (void) refreshSupportedOptionalMethods
{
	super.delegate = nil;
	super.delegate = self;
}

#pragma mark - UIAlertView
- (id<UIAlertViewDelegate>) delegate
{
    return self.trueDelegate;
}

- (void) setDelegate:(id<UIAlertViewDelegate>)delegate
{
	if (delegate != self.trueDelegate && delegate != self)
	{
		self.trueDelegate = delegate;
		[self refreshSupportedOptionalMethods];
	}
}

- (NSInteger) addButtonWithTitle:(NSString *)title
{
    return [self addButtonWithTitle:title action:nil];
}

#pragma mark - NSObject
- (id) init
{
    self = [super init];
    if (self)
    {
        _actions = [[NSMutableArray alloc] initWithCapacity:4];
        super.delegate = self;
    }
    return self;
}

- (BOOL) respondsToSelector:(SEL)selector
{
    BOOL responds = [super respondsToSelector:selector];
    if (!responds && ProtocolContainsSelector(@protocol(UIAlertViewDelegate), selector))
    {
        responds = [self.trueDelegate respondsToSelector:selector];
    }
    return responds;
}

- (id) forwardingTargetForSelector:(SEL)selector
{
    return ProtocolContainsSelector(@protocol(UIAlertViewDelegate), selector)
            ? self.trueDelegate
            : [super forwardingTargetForSelector:selector];
}

#pragma mark - UIAlertViewDelegate
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([self.trueDelegate respondsToSelector:_cmd])
    {
        [self.trueDelegate alertView:alertView clickedButtonAtIndex:buttonIndex];
    }

	if (buttonIndex < [self.actions count])
	{
		((ADVAlertViewAction)self.actions[buttonIndex])();
	}
}

@end