//
//  BCOSSWebSocketLink.m
//  VisitorSDK
//
//  Created by Viktor Fabian on 3/28/14.
//  Copyright (c) 2014 LogMeIn Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BCOSSWebSocketLink.h"
#import "SRWebSocket.h"
#import "NSString+RandomIdentifier.h"
#import <BoldEngine/BCMessage.h>
#import "BCOSSResponsePreProcessor.h"
#import "BCOSSConnectNotification.h"
#import "BCOSSConnectCall.h"
#import "BCOSSHeartBeatNotification.h"
#import "BCOSSHeartBeatCall.h"
#import "BCOSSUpdateBusyNotification.h"
#import "BCOSSAddMessageNotification.h"
#import "BCOSSUpdateTyperNotification.h"
#import "BCOSSUpdateChatNotification.h"
#import "BCOSSAutoMessageNotification.h"
#import "BCOSSVisitorTypingCall.h"
#import "BCOSSSendMessageCall.h"
#import "BCTimer.h"
#import "BCConnectivityManager.h"
#import "BCErrorCodes.h"

/** @file */

static const NSInteger __BCOSSWEBSOCKETLINK_RECONNECT_WAIT_TIME = 5;
static const NSInteger __BCOSSWEBSOCKETLINK_FIRST_CONNECT_TRY_COUNT = 5;

typedef enum {
    BCOSSWebSocketLinkStateIdle,
    BCOSSWebSocketLinkStateWebSocketConnecting,
    BCOSSWebSocketLinkStateWebSocketWaitingForServerConnect,
    BCOSSWebSocketLinkStateConnected,
    BCOSSWebSocketLinkStateSending,
    BCOSSWebSocketLinkStateClosed,
    BCOSSWebSocketLinkStateWaitingToReconnect,
    BCOSSWebSocketLinkStateError
    
}BCOSSWebSocketLinkState;

@interface BCOSSWebSocketLink () <BC_SRWebSocketDelegate,
                                    BCOSSConnectNotificationDelegate,
                                    BCOSSConnectCallDelegate,
                                    BCOSSSendMessageCallDelegate,
                                    BCOSSVisitorTypingCallDelegate,
                                    BCOSSHeartBeatNotificationDelegate,
                                    BCOSSUpdateChatNotificationDelegate,
                                    BCOSSUpdateTyperNotificationDelegate,
                                    BCOSSAddMessageNotificationDelegate,
                                    BCOSSUpdateBusyNotificationDelegate,
                                    BCOSSAutoMessageNotificationDelegate>
@property(nonatomic, strong)BC_SRWebSocket *webSocket;
@property(nonatomic, strong)NSMutableArray *normalMessageQueue;
@property(nonatomic, strong)NSMutableArray *priorityMessageQueue;
@property(nonatomic, strong)NSMutableArray *notificationObservers;
@property(nonatomic, strong)BCTimer *inactivityTimer;
@property(nonatomic, strong)BCTimer *waitingToReconnectTimer;
@property(nonatomic, assign)BOOL connectedOnce;//There was at least a successful connect
@property(nonatomic, assign)NSInteger reconnectCount; //number of tries of reconnects when there has not been a connect before - not a network loosing case
@property(nonatomic, assign)NSTimeInterval lastSuspendTime;

@property(nonatomic, assign)BCOSSWebSocketLinkState state;

- (void)initializeQueues;
- (NSURLRequest *)initialRequest;
- (void)startAsFirstOSSCall:(BCOSSCall *)ossCall;
- (void)startPriorityOSSCall:(BCOSSCall *)ossCall;
- (void)startOSSCall:(BCOSSCall *)ossCall;
- (void)testAndSendNextMessage;

- (void)webSocketOnMainThreadDidOpen:(BC_SRWebSocket *)webSocket;
- (void)webSocketOnMainThreadDidFailWithArray:(NSArray *)array;
- (void)webSocketOnMainThreadDidReceiveArray:(NSArray *)array;
- (void)webSocketOnMainThreadDidCloseWithArray:(NSArray *)array;

- (void)restartInactivityTimer;
- (void)restartInactivityTimer:(NSTimeInterval)timeInSec;
- (void)stopInactivityTimer;
- (void)inactivityTimerTick;

- (void)restartWaitingToReconnectTimer;
- (void)stopWaitingToReconnectTimer;
- (void)waitingToReconnectTimerTick;

- (void)reconnect;

@end

@implementation BCOSSWebSocketLink

@synthesize webSocketUrl = _webSocketUrl;
@synthesize operationQueue = _operationQueue;
@synthesize chatKey = _chatKey;

@synthesize normalMessageQueue = _normalMessageQueue;
@synthesize priorityMessageQueue = _priorityMessageQueue;
@synthesize notificationObservers = _notificationObservers;

@synthesize lastMessageId = _lastMessageId;
@synthesize state = _state;

@synthesize inactivityTimer = _inactivityTimer;
@synthesize waitingToReconnectTimer = _waitingToReconnectTimer;

@synthesize connectedOnce = _connectedOnce;
@synthesize reconnectCount = _reconnectCount;

@synthesize lastSuspendTime = _lastSuspendTime;

- (id)init {
    if ((self = [super init])) {
        self.normalMessageQueue = [NSMutableArray array];
        self.priorityMessageQueue = [NSMutableArray array];
        self.notificationObservers = [NSMutableArray array];
    }
    return self;
}

- (void)start {
    if (self.state != BCOSSWebSocketLinkStateIdle) return;

    [self initializeQueues];
    self.state = BCOSSWebSocketLinkStateWebSocketConnecting;
    self.webSocket = [[BC_SRWebSocket alloc] initWithURLRequest:[self initialRequest]];
    self.webSocket.delegate = self;
    if (self.operationQueue) {
        [self.webSocket setDelegateOperationQueue:self.operationQueue];
    }
    [self.webSocket open];
    [self restartInactivityTimer];
}

- (void)close {
    if (self.state == BCOSSWebSocketLinkStateClosed) return;
    self.state = BCOSSWebSocketLinkStateClosed;
    [self stopInactivityTimer];
    [self stopWaitingToReconnectTimer];
    self.webSocket.delegate = nil;
    [self.webSocket close];
    self.webSocket = nil;
}

- (void)sendMessage:(BCMessage *)message {
    BCOSSSendMessageCall *sendMessageCall = [[BCOSSSendMessageCall alloc] init];
    sendMessageCall.delegate = self;
    sendMessageCall.chatKey = self.chatKey;
    sendMessageCall.chatMessageID = message.ID;
    sendMessageCall.name = message.sender.name;
    sendMessageCall.message = message.htmlText;
    [self startOSSCall:sendMessageCall];
}

- (void)sendTyping:(BOOL)typing {
    BCOSSVisitorTypingCall *visitorTypingCall = [[BCOSSVisitorTypingCall alloc] init];
    visitorTypingCall.delegate = self;
    visitorTypingCall.chatKey = self.chatKey;
    visitorTypingCall.typing = typing;
    [self startOSSCall:visitorTypingCall];
}

- (void)suspend {
    self.lastMessageTime = [NSDate date].timeIntervalSince1970;
    [self stopInactivityTimer];
    if (self.state ==BCOSSWebSocketLinkStateWebSocketConnecting) {
        self.webSocket.delegate = nil;
        [self.webSocket close];
        self.webSocket = nil;
        
    } else if (self.state == BCOSSWebSocketLinkStateWaitingToReconnect) {
        [self stopWaitingToReconnectTimer];
    }
}

- (void)resume {
    NSTimeInterval presentTime = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval suspensionTime = presentTime - (self.lastMessageTime ? self.lastMessageTime : self.lastSuspendTime);
    
    switch (self.state) {
        case BCOSSWebSocketLinkStateWaitingToReconnect:
            if (self.timeoutInSeconds && suspensionTime > self.timeoutInSeconds) {
                [self close];
                [self.delegate ossLink:self didEndWithReason:BCOSSLinkEndReasonTimeout time:[NSDate date] error:nil];
            } else {
                [self restartInactivityTimer:self.timeoutInSeconds - suspensionTime];
                [self reconnect];
            }
            break;
            
        case BCOSSWebSocketLinkStateWebSocketConnecting:
            if (self.timeoutInSeconds && suspensionTime > self.timeoutInSeconds) {
                [self.delegate ossLink:self didEndWithReason:BCOSSLinkEndReasonTimeout time:[NSDate date] error:nil];
            } else {
                self.state = BCOSSWebSocketLinkStateIdle;
                [self start];
            }
            break;
            
        case BCOSSWebSocketLinkStateWebSocketWaitingForServerConnect:
        case BCOSSWebSocketLinkStateConnected:
        case BCOSSWebSocketLinkStateSending:
            if (self.timeoutInSeconds && suspensionTime > self.timeoutInSeconds) {
                [self close];
                [self.delegate ossLink:self didEndWithReason:BCOSSLinkEndReasonTimeout time:[NSDate date] error:nil];
            } else {
                [self restartInactivityTimer:self.timeoutInSeconds - suspensionTime];
            }
            break;
            
        case BCOSSWebSocketLinkStateIdle:
        case BCOSSWebSocketLinkStateClosed:
        case BCOSSWebSocketLinkStateError:
        default:
            //absolute nothing to do
            break;
    }
}

- (void)initializeQueues {
    [self.normalMessageQueue removeAllObjects];
    [self.priorityMessageQueue removeAllObjects];
    [self.notificationObservers removeAllObjects];
    
    BCOSSConnectNotification *connectNotification = [[BCOSSConnectNotification alloc] init];
    connectNotification.delegate = self;
    [self.notificationObservers addObject:connectNotification];
    
    BCOSSHeartBeatNotification *heartBeatNotification = [[BCOSSHeartBeatNotification alloc] init];
    heartBeatNotification.delegate = self;
    [self.notificationObservers addObject:heartBeatNotification];
    
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

- (void)startOSSCall:(BCOSSCall *)ossCall {
    [self.normalMessageQueue addObject:ossCall];
    [self testAndSendNextMessage];
}

- (void)startPriorityOSSCall:(BCOSSCall *)ossCall {
    [self.priorityMessageQueue addObject:ossCall];
    [self testAndSendNextMessage];
}

- (void)startAsFirstOSSCall:(BCOSSCall *)ossCall {
    [self.priorityMessageQueue insertObject:ossCall atIndex:0];
    [self testAndSendNextMessage];
}

- (void)testAndSendNextMessage {
    if (self.state == BCOSSWebSocketLinkStateConnected) {
        BCOSSCall *ossCallToSend = nil;
        if (self.priorityMessageQueue.count > 0) {
            ossCallToSend = self.priorityMessageQueue[0];
        } else if (self.normalMessageQueue.count > 0) {
            ossCallToSend = self.normalMessageQueue[0];
        }
        if (ossCallToSend) {
            self.state = BCOSSWebSocketLinkStateSending;
            [self.webSocket send:[ossCallToSend requestData]];
            if (![ossCallToSend waitsForResponse]) {
                [self.priorityMessageQueue removeObject:ossCallToSend];
                [self.normalMessageQueue removeObject:ossCallToSend];
                self.state = BCOSSWebSocketLinkStateConnected;
                [self testAndSendNextMessage];
                //TODO: may miss sending message
            }
        }
    }
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
    [self close];
    self.state = BCOSSWebSocketLinkStateError;
    if (self.connectedOnce) {
        [self.delegate ossLink:self didEndWithReason:BCOSSLinkEndReasonTimeout time:[NSDate date] error:nil];
    } else {
        [self.delegate ossLink:self didFailToConnectWithError:[NSError errorWithDomain:@"BCOSSWebSocket" code:BCGeneralNetworkError userInfo:@{@"reason" : @"failed to connect"}]];
    }
}

- (void)restartWaitingToReconnectTimer {
    [self stopWaitingToReconnectTimer];
    if (__BCOSSWEBSOCKETLINK_RECONNECT_WAIT_TIME) {
        self.waitingToReconnectTimer = [BCTimer scheduledNonRetainingTimerWithTimeInterval:__BCOSSWEBSOCKETLINK_RECONNECT_WAIT_TIME target:self selector:@selector(waitingToReconnectTimerTick) userInfo:nil repeats:NO];
    }
}
- (void)stopWaitingToReconnectTimer {
    [self.waitingToReconnectTimer invalidate];
    self.waitingToReconnectTimer = nil;
}
- (void)waitingToReconnectTimerTick {
    if (self.state == BCOSSWebSocketLinkStateWaitingToReconnect) {
        [self reconnect];
    }
}

- (NSURLRequest *)initialRequest {
    
    NSString *authParam = nil;
    if ([[NSData data] respondsToSelector:@selector(base64EncodedStringWithOptions:)]) {
        //iOS7
        authParam = [[[NSString stringWithFormat:@"%@:%@",self.connectivityManager.accountId, self.connectivityManager.accessKey] dataUsingEncoding:NSASCIIStringEncoding] base64EncodedStringWithOptions:0];
    } else {
        //before iOS7
        authParam = [[[NSString stringWithFormat:@"%@:%@",self.connectivityManager.accountId, self.connectivityManager.accessKey] dataUsingEncoding:NSASCIIStringEncoding] base64Encoding];
    }
    //cretating the url to call
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:self.webSocketUrl]];
    
    NSString* userAgent = [NSString stringWithFormat:@"BoldChatAPI/1.0 (%@; CPU %@ %@ like MAC OS X) %@/%@ (%.0fx%.0f)", [[UIDevice currentDevice] model], [[UIDevice currentDevice] systemName], [[[UIDevice currentDevice] systemVersion] stringByReplacingOccurrencesOfString:@"." withString:@"_"], [[NSBundle mainBundle] bundleIdentifier], [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"], [UIScreen mainScreen].bounds.size.width*[[UIScreen mainScreen] scale], [UIScreen mainScreen].bounds.size.height * [[UIScreen mainScreen] scale]];
    [request setValue:userAgent forHTTPHeaderField:@"User-Agent"];
    
    //authorization header
    NSString *authValue = [NSString stringWithFormat:@"Basic %@", authParam];
    [request setValue:authValue forHTTPHeaderField:@"Authorization"];
    
    return request;
}

#pragma mark -
#pragma mark inactivityTimerCallback

#pragma mark -
#pragma mark BC_SRWebSocketDelegate
- (void)webSocket:(BC_SRWebSocket *)webSocket didReceiveMessage:(id)message {
    NSError *parseError = nil;
    NSDictionary *resultDictionary = [self.responsePreProcessor preProcessResponse:message withError:&parseError];
    if (parseError) return;
    NSArray *returnArray = @[webSocket, resultDictionary ? resultDictionary : [NSNull null]];
    [self performSelectorOnMainThread:@selector(webSocketOnMainThreadDidReceiveArray:) withObject:returnArray waitUntilDone:NO];
}

- (void)webSocketDidOpen:(BC_SRWebSocket *)webSocket {
    [self performSelectorOnMainThread:@selector(webSocketOnMainThreadDidOpen:) withObject:webSocket waitUntilDone:NO];
}

- (void)webSocket:(BC_SRWebSocket *)webSocket didFailWithError:(NSError *)error {
    NSArray *returnArray = @[webSocket, error];
    [self performSelectorOnMainThread:@selector(webSocketOnMainThreadDidFailWithArray:) withObject:returnArray waitUntilDone:NO];
}

- (void)webSocket:(BC_SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    NSDictionary *dict = @{@"code" : @(code),
                           @"reason" : reason ? reason : [NSNull null],
                           @"wasClean" : @(wasClean)};
    NSArray *returnArray = @[webSocket, dict];
    [self performSelectorOnMainThread:@selector(webSocketOnMainThreadDidCloseWithArray:) withObject:returnArray waitUntilDone:NO];
}

#pragma mark -
#pragma mark BC_SRWebSocketDelegate on main thread
- (void)webSocketOnMainThreadDidOpen:(BC_SRWebSocket *)webSocket {
    if (self.webSocket != webSocket) return;
    self.state = BCOSSWebSocketLinkStateWebSocketWaitingForServerConnect;
    [self restartInactivityTimer];
    //start the connect call
    BCOSSConnectCall *connectCall = [[BCOSSConnectCall alloc] init];
    connectCall.lastMessageId = self.lastMessageId;
    connectCall.delegate = self;
    [self startAsFirstOSSCall:connectCall];
}

- (void)webSocketOnMainThreadDidFailWithArray:(NSArray *)array {
    BC_SRWebSocket *callerWebSocket = array[0];
    if (self.webSocket != callerWebSocket) return;
    if (self.connectedOnce) {
        if (self.state != BCOSSWebSocketLinkStateWaitingToReconnect &&
            self.state != BCOSSWebSocketLinkStateClosed &&
            self.state != BCOSSWebSocketLinkStateError) {
            
            self.state = BCOSSWebSocketLinkStateWaitingToReconnect;
            [self restartWaitingToReconnectTimer];
        }
    } else {
        if (self.reconnectCount < __BCOSSWEBSOCKETLINK_FIRST_CONNECT_TRY_COUNT) {
            self.reconnectCount++;
            [self reconnect];
        } else {
            [self close];
            self.state = self.state = BCOSSWebSocketLinkStateError;;
            [self.delegate ossLink:self didFailToConnectWithError:[NSError errorWithDomain:@"BCOSSWebSocket" code:BCGeneralNetworkError userInfo:@{@"reason" : @"failed to connect"}]];
        }
    }
}

- (void)webSocketOnMainThreadDidReceiveArray:(NSArray *)array {
    BC_SRWebSocket *callerWebSocket = array[0];
    if (self.webSocket != callerWebSocket) return;
    
    NSDictionary *resultDictionary = [array[1] isKindOfClass:[NSNull class]] ? nil : array[1];
//#if DEBUG
    NSLog(@"Message:\n%@",resultDictionary);
//#endif
    self.lastMessageTime = [[NSDate date] timeIntervalSince1970];
    if (!resultDictionary) return;
    
    if (resultDictionary[@"id"]) {
        if ([resultDictionary[@"id"] isKindOfClass:[NSNull class]]) {
            //self.lastMessageId = 0;
        } else {
            self.lastMessageId = [resultDictionary[@"id"] longLongValue];
            [self.delegate ossLink:self didReceiveLastMessageId:self.lastMessageId];
        }
    }
    
    BOOL found = NO;
    NSArray *notificationsCopy = [self.notificationObservers copy];
    for (BCOSSNotification *notification in notificationsCopy) {
        if ([notification processMessage:resultDictionary]) {
            found = YES;
        }
    }
    
    if (!found) {
        NSArray *priorityMessageQueueCopy = [self.priorityMessageQueue copy];
        for (BCOSSCall *call in priorityMessageQueueCopy) {
            if ([call processResponse:resultDictionary]) {
                found = YES;
                self.state = BCOSSWebSocketLinkStateConnected;
                [self.priorityMessageQueue removeObject:call];
            }
        }
    }
    
    if (!found) {
        NSArray *normalMessageQueueCopy = [self.normalMessageQueue copy];
        for (BCOSSCall *call in normalMessageQueueCopy) {
            if ([call processResponse:resultDictionary]) {
                self.state = BCOSSWebSocketLinkStateConnected;
                [self.normalMessageQueue removeObject:call];
            }
        }
    }
    
    [self testAndSendNextMessage];
}

- (void)webSocketOnMainThreadDidCloseWithArray:(NSArray *)array {
    BC_SRWebSocket *callerWebSocket = array[0];
    if (self.webSocket != callerWebSocket) return;
    
    if (self.connectedOnce) {
        if (self.state != BCOSSWebSocketLinkStateClosed) {
            [self reconnect];
        }
    } else {
        if (self.reconnectCount < __BCOSSWEBSOCKETLINK_FIRST_CONNECT_TRY_COUNT) {
            self.reconnectCount++;
            [self reconnect];
        } else {
            [self close];
            self.state = self.state = BCOSSWebSocketLinkStateError;
            [self.delegate ossLink:self didFailToConnectWithError:[NSError errorWithDomain:@"BCOSSWebSocket" code:BCGeneralNetworkError userInfo:@{@"reason" : @"failed to connect"}]];
        }
    }
}


#pragma mark -
#pragma mark BCOSSConnectNotificationDelegate
- (void)ossConnectNotificationDidConnect:(BCOSSConnectNotification *)notification {
    self.state = BCOSSWebSocketLinkStateConnected;
    if (!self.connectedOnce) {
        [self.delegate ossLinkDidSucceedToConnect:self];
    }
    self.connectedOnce = YES;
}

- (void)ossConnectNotification:(BCOSSConnectNotification *)notification didRedirectToUrl:(NSString *)redirectUrl {
    self.webSocketUrl = redirectUrl;
    self.webSocket.delegate = nil;
    [self.webSocket close];
    self.state = BCOSSWebSocketLinkStateWebSocketConnecting;
    self.webSocket = [[BC_SRWebSocket alloc] initWithURLRequest:[self initialRequest]];
    self.webSocket.delegate = self;
    if (self.operationQueue) {
        [self.webSocket setDelegateOperationQueue:self.operationQueue];
    }
    [self.webSocket open];
    
}

- (void)ossConnectNotificationDidReconnect:(BCOSSConnectNotification *)notification {
    [self restartInactivityTimer];
    [self reconnect];
}

- (void)reconnect {
    self.webSocket.delegate = nil;
    [self.webSocket close];
    self.state = BCOSSWebSocketLinkStateWebSocketConnecting;
    self.webSocket = [[BC_SRWebSocket alloc] initWithURLRequest:[self initialRequest]];
    self.webSocket.delegate = self;
    if (self.operationQueue) {
        [self.webSocket setDelegateOperationQueue:self.operationQueue];
    }
    [self.webSocket open];
}

- (void)ossConnectNotificationDidReset:(BCOSSConnectNotification *)notification {
    [self.delegate ossLinkDidReset:self];
}

- (void)ossConnectNotificationDidClose:(BCOSSConnectNotification *)notification {
    if (self.state != BCOSSWebSocketLinkStateClosed) {
        [self close];
        [self.delegate ossLink:self didEndWithReason:BCOSSLinkEndReasonClosed time:[NSDate date] error:nil];
    }
}

#pragma mark -
#pragma mark BCOSSConnectCallDelegate
- (void)ossConnectCallDidSucceed:(BCOSSConnectCall *)connectCall {
}

#pragma mark -
#pragma mark BCOSSHeartBeatNotification
- (void)ossHeartBeatNotification:(BCOSSHeartBeatNotification *)notification didReceiveWithId:(NSString *)ID {
    [self restartInactivityTimer];
    BCOSSHeartBeatCall *heartBeatCall = [[BCOSSHeartBeatCall alloc] init];
    heartBeatCall.ID = ID;
    [self startPriorityOSSCall:heartBeatCall];
}

#pragma mark -
#pragma mark BCOSSUpdateChatNotification
- (void)ossUpdateChatNotification:(BCOSSUpdateChatNotification *)notification chatId:(NSString *)chatId
                         answered:(NSString *)answered endedAt:(NSDate *)endTime reason:(NSString *)reason {
    if (endTime && reason) {
        BCOSSLinkEndReason endReason = BCOSSLinkEndReasonUnknown;
        if ([reason isEqualToString:@"operator"]) {
            endReason = BCOSSLinkEndReasonOperator;
        } else if ([reason isEqualToString:@"visitor"]) {
            endReason = BCOSSLinkEndReasonVisitor;
        } else if ([reason isEqualToString:@"disconnect"]) {
            endReason = BCOSSLinkEndReasonDisconnect;
        }
        if (self.state != BCOSSWebSocketLinkStateClosed) {
            [self close];
            [self.delegate ossLink:self didEndWithReason:endReason time:endTime error:nil];
        }
    } else if (answered) {
        if (self.state != BCOSSWebSocketLinkStateClosed) {
            [self.delegate ossLink:self didAcceptChat:answered];
        }
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
#pragma mark BCOSSSendMessageCallDelegate
- (void)ossSendMessageCallDidSucceed:(BCOSSSendMessageCall *)ossSendMessageCall {
    [self.delegate ossLink:self didSendMessageId:ossSendMessageCall.chatMessageID];
}

#pragma mark -
#pragma mark BCOSSVisitorTypingCallDelegate
- (void)ossVisitorTypingCallDidSucceed:(BCOSSVisitorTypingCall *)visitorTypingCall {
    [self.delegate ossLink:self didSendTyping:visitorTypingCall.typing];
}

#pragma mark -
#pragma mark Memory management
- (void)dealloc {
    [self stopInactivityTimer];
    [self stopWaitingToReconnectTimer];
    self.webSocket.delegate = nil;
    [self.webSocket close];
}

@end
