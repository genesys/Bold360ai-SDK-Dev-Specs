//
//  BCTimer.m
//  Copyright (c) 2014 LogMeIn Inc. All rights reserved.
//

#import "BCTimer.h"

/**
 A timer proxy that holds tha timer invocation data. It is retained by the inner timer.
 @since Version 1.0
 */
@interface BCTimerProxy : NSObject

/**
 The target to call back.
 @since Version 1.0
 */
@property(nonatomic, assign)id target;

/**
 The method of the callback.
 @since Version 1.0
 */
@property(nonatomic, assign)SEL selector;

/**
 The timer instance to give as a parameter in a callback if needed.
 @since Version 1.0
 */
@property(nonatomic, assign)id caller;

/**
 Invocation for invocation style callback.
 @since Version 1.0
 */
@property(nonatomic, strong)NSInvocation *invocation;

/**
 Selector called by the timer.
 @since Version 1.0
 */
- (void)fire;

@end

/**
 BCTimer private inerface.
 @since Version 1.0
 */
@interface BCTimer ()

/**
 Proxy for the inner timer to retain and call back on.
 @since Version 1.0
 */
@property(nonatomic, strong)BCTimerProxy *timerProxy;

/**
 The internal timer.
 @since Version 1.0
 */
@property(nonatomic, strong)NSTimer *timer;

@end

@implementation BCTimerProxy

@synthesize target = _target;
@synthesize selector = _selector;
@synthesize caller = _caller;
@synthesize invocation = _invocation;

- (void)fire {
    if (self.invocation) {
        [self.invocation invoke];
    } else {
        if (self.selector) {
            BOOL needsParam = ([NSStringFromSelector(self.selector) rangeOfString:@":"].location != NSNotFound);
            if (needsParam) {
                [self.target performSelector:self.selector withObject:self.caller];
            } else {
                [self.target performSelector:self.selector];
            }
        }
    }
}

@end


@implementation BCTimer

@synthesize timerProxy = _timerProxy;
@synthesize timer = _timer;

+ (BCTimer *)nonRetainingTimerWithTimeInterval:(NSTimeInterval)ti invocation:(NSInvocation *)invocation repeats:(BOOL)yesOrNo {
    BCTimerProxy *timerProxy = [[BCTimerProxy alloc] init];
    timerProxy.invocation = invocation;
    BCTimer *timer = (BCTimer *)[BCTimer timerWithTimeInterval:ti target:timerProxy selector:@selector(fire) userInfo:nil repeats:yesOrNo];
    timer.timerProxy = timerProxy;
    return timer;
}
+ (BCTimer *)scheduledNonRetainingTimerWithTimeInterval:(NSTimeInterval)ti invocation:(NSInvocation *)invocation repeats:(BOOL)yesOrNo {
    BCTimerProxy *timerProxy = [[BCTimerProxy alloc] init];
    timerProxy.invocation = invocation;
    BCTimer *timer = (BCTimer *)[BCTimer scheduledTimerWithTimeInterval:ti target:timerProxy selector:@selector(fire) userInfo:nil repeats:yesOrNo];
    timer.timerProxy = timerProxy;
    return timer;
}

+ (BCTimer *)nonRetainingTimerWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)aSelector userInfo:(id)userInfo repeats:(BOOL)yesOrNo {
    BCTimerProxy *timerProxy = [[BCTimerProxy alloc] init];
    timerProxy.target = aTarget;
    timerProxy.selector = aSelector;
    BCTimer *timer = (BCTimer *)[BCTimer timerWithTimeInterval:ti target:timerProxy selector:@selector(fire) userInfo:userInfo repeats:yesOrNo];
    timer.timerProxy = timerProxy;
    return timer;
}

+ (BCTimer *)scheduledNonRetainingTimerWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)aSelector userInfo:(id)userInfo repeats:(BOOL)yesOrNo {
    BCTimerProxy *timerProxy = [[BCTimerProxy alloc] init];
    timerProxy.target = aTarget;
    timerProxy.selector = aSelector;
    BCTimer *timer = (BCTimer *)[BCTimer scheduledTimerWithTimeInterval:ti target:timerProxy selector:@selector(fire) userInfo:userInfo repeats:yesOrNo];
    timer.timerProxy = timerProxy;
    
    return timer;
}

- (id)initNonRetainingWithFireDate:(NSDate *)date interval:(NSTimeInterval)ti target:(id)t selector:(SEL)s userInfo:(id)ui repeats:(BOOL)rep {
    BCTimerProxy *timerProxy = [[BCTimerProxy alloc] init];
    timerProxy.target = t;
    timerProxy.selector = s;
    self = [self initWithFireDate:date interval:ti target:timerProxy selector:@selector(fire) userInfo:ui repeats:rep];
    self.timerProxy = timerProxy;
    return self;
}

+ (BCTimer *)timerWithTimeInterval:(NSTimeInterval)ti invocation:(NSInvocation *)invocation repeats:(BOOL)yesOrNo {
    BCTimer *timer = [[BCTimer alloc] init];
    timer.timer = [NSTimer timerWithTimeInterval:ti invocation:invocation repeats:yesOrNo];
    return timer;
}

+ (BCTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)ti invocation:(NSInvocation *)invocation repeats:(BOOL)yesOrNo {
    BCTimer *timer = [[BCTimer alloc] init];
    timer.timer = [NSTimer scheduledTimerWithTimeInterval:ti invocation:invocation repeats:yesOrNo];
    return timer;
}

+ (BCTimer *)timerWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)aSelector userInfo:(id)userInfo repeats:(BOOL)yesOrNo {
    BCTimer *timer = [[BCTimer alloc] init];
    timer.timer = [NSTimer timerWithTimeInterval:ti target:aTarget selector:aSelector userInfo:userInfo repeats:yesOrNo];
    return timer;
}

+ (BCTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)aSelector userInfo:(id)userInfo repeats:(BOOL)yesOrNo {
    BCTimer *timer = [[BCTimer alloc] init];
    timer.timer = [NSTimer scheduledTimerWithTimeInterval:ti target:aTarget selector:aSelector userInfo:userInfo repeats:yesOrNo];
    return timer;
}

- (id)initWithFireDate:(NSDate *)date interval:(NSTimeInterval)ti target:(id)t selector:(SEL)s userInfo:(id)ui repeats:(BOOL)rep {
    if (self = [self init]) {
        self.timer = [[NSTimer alloc] initWithFireDate:date interval:ti target:t selector:s userInfo:ui repeats:rep];
    }
    
    return self;
}

- (void)fire {
    [self.timer fire];
}

- (NSDate *)fireDate {
    return [self.timer fireDate];
}

- (void)setFireDate:(NSDate *)date {
    [self.timer setFireDate:date];
}

- (NSTimeInterval)timeInterval {
    return self.timer.timeInterval;
}

- (NSTimeInterval)tolerance {
    return self.timer.tolerance;
}

- (void)setTolerance:(NSTimeInterval)tolerance {
    [self.timer setTolerance:tolerance];
}

- (void)invalidate {
    [self.timer invalidate];
}

- (BOOL)isValid {
    return [self.timer isValid];
}

- (id)userInfo {
    return [self.timer userInfo];
}

- (void)dealloc {
    [self.timer invalidate], self.timer = nil;
}


@end
