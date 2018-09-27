//
//  BCOSSLongPollLink.m
//  VisitorSDK
//
//  Created by Viktor Fabian on 3/28/14.
//  Copyright (c) 2014 LogMeIn Inc. All rights reserved.
//

#import "BCOSSLongPollLink.h"
#import "BCConnectivityManager.h"
#import "BCTimer.h"
#import "BCLongPollCall.h"
#import "BCSendMessageCall.h"
#import "BCVisitorTypingCall.h"
#import "BCOSSConnectNotification.h"
#import "BCOSSUpdateBusyNotification.h"
#import "BCOSSAddMessageNotification.h"
#import "BCOSSUpdateTyperNotification.h"
#import "BCOSSUpdateChatNotification.h"
#import "BCOSSAutoMessageNotification.h"
#import "BCMessage.h"
#import "BCErrorCodes.h"

/** @file */

static const NSInteger __BCOSSLONGPOLL_RECONNECT_WAIT_TIME = 5;

typedef enum {
    BCOSSLongPollLinkStateIdle,
    BCOSSLongPollLinkStateRunning,
    BCOSSLongPollLinkStateClosed
    
}BCOSSLongPollLinkState;

@interface BCOSSLongPollLink () <BCLongPollCallDelegate,
                                    BCSendMessageCallDelegate,
                                    BCVisitorTypingCallDelegate,
                                    BCOSSConnectNotificationDelegate,
                                    BCOSSUpdateChatNotificationDelegate,
                                    BCOSSUpdateTyperNotificationDelegate,
                                    BCOSSAddMessageNotificationDelegate,
                                    BCOSSUpdateBusyNotificationDelegate,
                                    BCOSSAutoMessageNotificationDelegate>

@property(nonatomic, assign)BCOSSLongPollLinkState state;
@property(nonatomic, strong)NSMutableArray<BCCall *> *callQueue;
@property(nonatomic, strong)BCLongPollCall *longPollCall;
@property(nonatomic, strong)BCTimer *inactivityTimer;
@property(nonatomic, strong)BCTimer *waitingToReconnectTimer;
@property(nonatomic, strong)NSMutableArray *notificationObservers;
@property(nonatomic, assign)BOOL notificationArrived;
@property(nonatomic, assign)BOOL restartInactivityTimerOnResume;

@property(nonatomic, assign)BOOL longPollNeedsRestart;
@property(nonatomic, assign)BOOL queueNeedsRestart;

- (void)initiatePoll;
- (void)handlePollNotifications:(NSArray *)notifications;

- (void)closeAndNotifyError:(NSError *)error;
- (void)closeAndNotifyEndReason:(BCOSSLinkEndReason)reason endTime:(NSDate *)endDate;

- (void)restartInactivityTimer;
- (void)restartInactivityTimer:(NSTimeInterval)timeInSec;
- (void)stopInactivityTimer;
- (void)inactivityTimerTick;

- (void)restartWaitingToReconnectTimer;
- (void)stopWaitingToReconnectTimer;
- (void)waitingToReconnectTimerTick;


@end

@implementation BCOSSLongPollLink

@synthesize state = _state;
@synthesize longPollUrl = _longPollUrl;
@synthesize inactivityTimer = _inactivityTimer;
@synthesize callQueue = callQueue;
@synthesize notificationObservers = _notificationObservers;
@synthesize restartInactivityTimerOnResume = _restartInactivityTimerOnResume;
@synthesize longPollCall = _longPollCall;
@synthesize notificationArrived = _notificationArrived;
@synthesize longPollNeedsRestart = _longPollNeedsRestart;
@synthesize queueNeedsRestart = _queueNeedsRestart;

- (id)init {
    if ((self = [super init])) {
        self.callQueue = [NSMutableArray array];
        self.notificationObservers = [NSMutableArray array];
    }
    return self;
}

- (void)start {
    if (self.state != BCOSSLongPollLinkStateIdle) return;
    self.restartInactivityTimerOnResume = NO;
    self.notificationArrived = NO;
    [self initializeQueues];
    self.state = BCOSSLongPollLinkStateRunning;
    self.queueNeedsRestart = NO;
    self.longPollNeedsRestart = NO;

    [self restartInactivityTimer];
    [self initiatePoll];
}

- (void)close {
    if (self.state == BCOSSLongPollLinkStateClosed) return;
    self.queueNeedsRestart = NO;
    self.longPollNeedsRestart = NO;

    self.restartInactivityTimerOnResume = NO;
    self.state = BCOSSLongPollLinkStateClosed;
    
    [self stopInactivityTimer];
    [self stopWaitingToReconnectTimer];
    
    [self.longPollCall cancel];
    self.longPollCall = nil;
    
    if (self.callQueue.count > 0) {
        [self.callQueue[0] cancel];
    }
    [self.callQueue removeAllObjects];
}

- (void)closeAndNotifyError:(NSError *)error {
    self.queueNeedsRestart = NO;
    self.longPollNeedsRestart = NO;
    if (self.state != BCOSSLongPollLinkStateClosed) {
        [self close];
        [self.delegate ossLink:self didFailToConnectWithError:error];
    }
}

- (void)closeAndNotifyEndReason:(BCOSSLinkEndReason)reason endTime:(NSDate *)endDate {
    self.queueNeedsRestart = NO;
    self.longPollNeedsRestart = NO;
    if (self.state != BCOSSLongPollLinkStateClosed) {
        [self close];
        [self.delegate ossLink:self didEndWithReason:reason time:endDate error:nil];
    }
}

- (void)sendMessage:(BCMessage *)message {
    if (self.state != BCOSSLongPollLinkStateRunning) return;
    
    BCSendMessageCall *sendMessageCall = [self.connectivityManager sendMessageCall];
    sendMessageCall.chatKey = self.chatKey;
    sendMessageCall.chatMessageID = message.ID;
    sendMessageCall.name = message.sender.name;
    sendMessageCall.message = message.htmlText;
    sendMessageCall.delegate = self;
    [self.callQueue addObject:sendMessageCall];
    if (self.callQueue.count == 1) {
        [self.callQueue[0] start];
    }
}

- (void)sendTyping:(BOOL)typing {
    if (self.state != BCOSSLongPollLinkStateRunning) return;
    
    BCVisitorTypingCall *visitorTypingCall = [self.connectivityManager visitorTypingCall];
    visitorTypingCall.chatKey = self.chatKey;
    visitorTypingCall.isTyping = typing;
    visitorTypingCall.delegate = self;
    [self.callQueue addObject:visitorTypingCall];
    if (self.callQueue.count == 1) {
        [self.callQueue[0] start];
    }
}

- (void)suspend {
    self.queueNeedsRestart = NO;
    self.longPollNeedsRestart = NO;
    
    [self.longPollCall cancel];
    self.longPollCall = nil;
    
    if (self.callQueue.count > 0) {
        [self.callQueue[0] cancel];
    }
    
    if (self.inactivityTimer) {
        self.restartInactivityTimerOnResume = YES;
        [self stopInactivityTimer];
    }
    [self stopWaitingToReconnectTimer];
}

- (void)resume {
    if (self.state != BCOSSLongPollLinkStateRunning) return;
    
    [self initiatePoll];
    
    if (self.callQueue.count > 0) {
        [self.callQueue[0] start];
    }
    if (self.restartInactivityTimerOnResume) {
        self.restartInactivityTimerOnResume = NO;
        NSTimeInterval presentTime = [[NSDate date] timeIntervalSince1970];
        NSTimeInterval suspensionTime = presentTime - self.lastMessageTime;
        
        if (self.timeoutInSeconds && suspensionTime > self.timeoutInSeconds) {
            [self closeAndNotifyEndReason:BCOSSLinkEndReasonTimeout endTime:[NSDate date]];
        } else {
            [self restartInactivityTimer:self.timeoutInSeconds - suspensionTime];
        }
    }
}

- (void)initializeQueues {
    [self.callQueue removeAllObjects];
    
    self.restartInactivityTimerOnResume = NO;
    
    BCOSSConnectNotification *connectNotification = [[BCOSSConnectNotification alloc] init];
    connectNotification.delegate = self;
    [self.notificationObservers addObject:connectNotification];
    
    BCOSSUpdateBusyNotification *updateBusyNotification = [[BCOSSUpdateBusyNotification alloc] init];
    updateBusyNotification.delegate = self;
    [self.notificationObservers addObject:updateBusyNotification];
    
    BCOSSAddMessageNotification *addMessageNotification = [[BCOSSAddMessageNotification alloc] init];
    addMessageNotification.delegate = self;
    [self.notificationObservers addObject:addMessageNotification];
    
    BCOSSUpdateTyperNotification *updateTyperNotification = [[BCOSSUpdateTyperNotification alloc] init];
    updateTyperNotification.delegate = self;
    [self.notificationObservers addObject:updateTyperNotification];
    
    BCOSSUpdateChatNotification *updateChatNotification = [[BCOSSUpdateChatNotification alloc] init];
    updateChatNotification.delegate = self;
    [self.notificationObservers addObject:updateChatNotification];
    
    BCOSSAutoMessageNotification *autoMessageNotification = [[BCOSSAutoMessageNotification alloc] init];
    autoMessageNotification.delegate = self;
    [self.notificationObservers addObject:autoMessageNotification];
}

- (void)restartInactivityTimer {
    [self restartInactivityTimer:self.timeoutInSeconds];
}

- (void)restartInactivityTimer:(NSTimeInterval)timeInSec {
    [self stopInactivityTimer];
    if (self.timeoutInSeconds) {
        self.inactivityTimer = [BCTimer scheduledNonRetainingTimerWithTimeInterval:timeInSec target:self selector:@selector(inactivityTimerTick) userInfo:nil repeats:NO];
    }
}


- (void)stopInactivityTimer {
    [self.inactivityTimer invalidate];
    self.inactivityTimer = nil;
}

- (void)inactivityTimerTick {
    self.inactivityTimer = nil;
    [self closeAndNotifyEndReason:BCOSSLinkEndReasonTimeout endTime:[NSDate date]];
}

- (void)restartWaitingToReconnectTimer {
    [self stopWaitingToReconnectTimer];
    if (__BCOSSLONGPOLL_RECONNECT_WAIT_TIME) {
        self.waitingToReconnectTimer = [BCTimer scheduledNonRetainingTimerWithTimeInterval:__BCOSSLONGPOLL_RECONNECT_WAIT_TIME target:self selector:@selector(waitingToReconnectTimerTick) userInfo:nil repeats:NO];
    }
}
- (void)stopWaitingToReconnectTimer {
    [self.waitingToReconnectTimer invalidate];
    self.waitingToReconnectTimer = nil;
}
- (void)waitingToReconnectTimerTick {
    [self stopWaitingToReconnectTimer];
    
    if (self.longPollNeedsRestart && !self.longPollCall) {
        [self initiatePoll];
    }
    self.longPollNeedsRestart = NO;
    
    if (self.queueNeedsRestart) {
        [self.callQueue[0] start];
    }
    self.queueNeedsRestart = NO;
}


- (void)initiatePoll {
    self.longPollCall = [self.connectivityManager longPollCall];
    self.longPollCall.url = self.longPollUrl;
    self.longPollCall.lastMessageId = self.lastMessageId;
    self.longPollCall.delegate = self;
    [self.longPollCall start];
}

- (void)handlePollNotifications:(NSArray *)notifications {
    if (!self.notificationArrived) {
        self.notificationArrived = YES;
        [self.delegate ossLinkDidSucceedToConnect:self];
    }
    for (NSDictionary *notificationDictionary in notifications) {
        for (BCOSSNotification *notificationObserver in self.notificationObservers) {
            [notificationObserver processMessage:notificationDictionary];
            
            if (notificationDictionary[@"id"]) {
                if ([notificationDictionary[@"id"] isKindOfClass:[NSNull class]]) {
                    //self.lastMessageId = 0;
                } else {
                    self.lastMessageId = [notificationDictionary[@"id"] longLongValue];
                    [self.delegate ossLink:self didReceiveLastMessageId:self.lastMessageId];
                }
            }
        }
    }
}

#pragma mark -
#pragma mark BCLongPollCallDelegate
- (void)bcLongPollCall:(BCLongPollCall *)longPollCall didFinishWithResult:(NSArray *)result {
    [self handlePollNotifications:result];
    [self restartInactivityTimer];
    self.lastMessageTime = [[NSDate date] timeIntervalSince1970];
    [self initiatePoll];
}

- (void)bcLongPollCall:(BCLongPollCall *)longPollCall didFinishWithError:(NSError *)error {
    self.longPollCall = nil;
    self.longPollNeedsRestart = YES;
    if (!self.waitingToReconnectTimer) {
        [self restartWaitingToReconnectTimer];
    }
}

#pragma mark -
#pragma mark BCSendMessageCallDelegate
- (void)bcSendMessageCall:(BCSendMessageCall *)sendMessageCall didFinishWithResult:(BCSendMessageCallResult *)result {
    [self.callQueue removeObject:sendMessageCall];
    if (self.callQueue.count > 0) {
        [self.callQueue[0] start];
    }
    [self.delegate ossLink:self didSendMessageId:sendMessageCall.chatMessageID];
}

- (void)bcSendMessageCall:(BCSendMessageCall *)sendMessageCall didFinishWithError:(NSError *)error {
    self.queueNeedsRestart = 1;
    if (!self.waitingToReconnectTimer) {
        [self restartWaitingToReconnectTimer];
    }
}

#pragma mark -
#pragma mark BCVisitorTypingCallDelegate
- (void)bcVisitorTypingCall:(BCVisitorTypingCall *)visitorTypingCall didFinishWithResult:(BCVisitorTypingCallResult *)result {
    [self.callQueue removeObject:visitorTypingCall];
    if (self.callQueue.count > 0) {
        [self.callQueue[0] start];
    }
    [self.delegate ossLink:self didSendTyping:visitorTypingCall.isTyping];
}

- (void)bcVisitorTypingCall:(BCVisitorTypingCall *)visitorTypingCall didFinishWithError:(NSError *)error {
    self.queueNeedsRestart = 1;
    if (!self.waitingToReconnectTimer) {
        [self restartWaitingToReconnectTimer];
    }
}

#pragma mark -
#pragma mark BCOSSConnectNotificationDelegate
- (void)ossConnectNotificationDidConnect:(BCOSSConnectNotification *)notification {
    [self.delegate ossLinkDidSucceedToConnect:self];
}

- (void)ossConnectNotification:(BCOSSConnectNotification *)notification didRedirectToUrl:(NSString *)redirectUrl {
    self.longPollUrl = redirectUrl;
}

- (void)ossConnectNotificationDidReconnect:(BCOSSConnectNotification *)notification {
}

- (void)ossConnectNotificationDidReset:(BCOSSConnectNotification *)notification {
    [self.delegate ossLinkDidReset:self];
}

- (void)ossConnectNotificationDidClose:(BCOSSConnectNotification *)notification {
    [self closeAndNotifyEndReason:BCOSSLinkEndReasonClosed endTime:[NSDate date]];
}

#pragma mark -
#pragma mark BCOSSUpdateChatNotification
- (void)ossUpdateChatNotification:(BCOSSUpdateChatNotification *)notification chatId:(NSString *)chatId endedAt:(NSDate *)endTime reason:(NSString *)reason {
    if (endTime && reason) {
        BCOSSLinkEndReason endReason = BCOSSLinkEndReasonUnknown;
        if ([reason isEqualToString:@"operator"]) {
            endReason = BCOSSLinkEndReasonOperator;
        } else if ([reason isEqualToString:@"visitor"]) {
            endReason = BCOSSLinkEndReasonVisitor;
        } else if ([reason isEqualToString:@"disconnect"]) {
            endReason = BCOSSLinkEndReasonDisconnect;
        }
        [self closeAndNotifyEndReason:endReason endTime:endTime];
    }
}

#pragma mark -
#pragma mark BCOSSUpdateTyperNotificationDelegate
- (void)ossUpdateTyperNotification:(BCOSSUpdateTyperNotification *)updateTyperNotification didReceivePerson:(BCPerson *)person typing:(BOOL)typing {
    [self.delegate ossLink:self didReceivePerson:person typing:typing];
}


#pragma mark -
#pragma mark BCOSSAddMessageNotificationDelegate
- (void)ossAddMessageNotification:(BCOSSAddMessageNotification *)addMessageNotification didReceiveMessage:(BCMessage *)message {
    [self.delegate ossLink:self didReceiveMessage:message];
}

#pragma mark -
#pragma mark BCOSSUpdateBusyNotificationDelegate
- (void)ossUpdateBusyNotification:(BCOSSUpdateBusyNotification *)updateBusyNotification position:(NSInteger)position unavailableFormEnabled:(BOOL)unavailableFormEnable {
    [self.delegate ossLink:self didReceiveBusyWithPosition:position unavailableFormAvailable:unavailableFormEnable];
}

#pragma mark -
#pragma mark BCOSSAutoMessageNotificationDelegate
- (void)ossAutoMessageNotification:(BCOSSAutoMessageNotification *)autoMessageNotification text:(NSString *)text {
    BCMessage *message = [[BCMessage alloc] initWithID:nil sender:nil created:[NSDate date] updated:nil htmlText:text];
    [self.delegate ossLink:self didReceiveAutoMessage:message];
}

#pragma mark -
#pragma mark Memory management
- (void)dealloc {
    [self close];
}

@end
