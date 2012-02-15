//
//  Copyright © 2011 Yuri Kotov
//  Licensed under the MIT license: http://opensource.org/licenses/MIT
//  Latest version can be found at http://github.com/advantis/ADVAlertView
//


#import "ADVAlertView.h"
#import <objc/runtime.h>

#if __has_feature(objc_arc_weak)
    #define __desirable_weak    __weak
#else
    #define __desirable_weak    __unsafe_unretained
#endif

static inline BOOL ProtocolContainsSelector (Protocol *protocol, SEL selector)
{
    return sel_isEqual(selector, protocol_getMethodDescription(protocol, selector, NO, YES).name);
}

@implementation ADVAlertView
{
    NSMutableArray *_actions;
    __desirable_weak id _realDelegate;
}

#pragma mark - ADVAlertView
- (NSInteger) addButtonWithTitle:(NSString *)title action:(ADVAlertViewAction)action
{
    NSInteger index = [super addButtonWithTitle:title];
    if (action)
    {
        id object = [action copy];
        [_actions insertObject:object atIndex:index];
        #if !__has_feature(objc_arc)
        [object release];
        #endif
    }
    else
    {
        [_actions insertObject:[NSNull null] atIndex:index];
    }
    return index;
}

#pragma mark - UIAlertView
- (id) delegate
{
    return _realDelegate;
}

- (void) setDelegate:(id)delegate
{
    if (delegate != _realDelegate && delegate != self)
    {
        _realDelegate = delegate;

        // UIAlertView performs a series of "respondsToSelector" calls on delegate to
        // determine which of the optional protocol methods it implements and cache
        // this info. Therefore we need to force it to update this info for a new delegate.
        super.delegate = nil;
        super.delegate = self;
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
        responds = [_realDelegate respondsToSelector:selector];
    }
    return responds;
}

- (id) forwardingTargetForSelector:(SEL)selector
{
    return ProtocolContainsSelector(@protocol(UIAlertViewDelegate), selector)
            ? _realDelegate
            : [super forwardingTargetForSelector:selector];
}

#if !__has_feature(objc_arc)
- (void)dealloc
{
    [_actions release];
    [super dealloc];
}
#endif

#pragma mark - UIAlertViewDelegate
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([_realDelegate respondsToSelector:_cmd])
    {
        [_realDelegate alertView:alertView clickedButtonAtIndex:buttonIndex];
    }

    ADVAlertViewAction action = [_actions objectAtIndex:buttonIndex];
    if ([NSNull null] != (id) action)
    {
        action(buttonIndex);
    }
}

@end