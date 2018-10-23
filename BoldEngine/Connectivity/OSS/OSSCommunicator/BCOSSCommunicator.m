//
//  BCOSSCommunicator.m
//  VisitorSDK
//
//  Created by Viktor Fabian on 3/28/14.
//  Copyright (c) 2014 LogMeIn Inc. All rights reserved.
//

#import "BCOSSCommunicator.h"
#import "BCOSSWebSocketLink.h"
#import "BCOSSLongPollLink.h"
#import "BCOSSJSONResponsePreProcessor.h"
#import "BCConnectivityManager.h"
#import "BCTimer.h"

/** @file */

#define USE_POLL 0

const NSTimeInterval __BCOSSCommunicator_LongPoll_Start_Delay = 5;

typedef enum {
    BCOSSCommunicatorState_Idle,
    BCOSSCommunicatorState_WebSocketConnecting_LongPollNotUsed,
    BCOSSCommunicatorState_WebSocketConnecting_LongPollConnecting,
    BCOSSCommunicatorState_WebSocketConnecting_LongPollConnected,
    BCOSSCommunicatorState_WebSocketConnecting,
    BCOSSCommunicatorState_WebSocketConnected,
    BCOSSCommunicatorState_LongPollConnecting,
    BCOSSCommunicatorState_LongPollConnected,
    BCOSSCommunicatorState_Error
}BCOSSCommunicatorState;

@interface BCOSSCommunicator () <BCOSSLinkDelegate>
@property(nonatomic, strong)BCOSSWebSocketLink *webSocketLink;
@property(nonatomic, strong)BCOSSLongPollLink *longPollLink;
@property(nonatomic, assign)BCOSSCommunicatorState state;
@property(nonatomic, strong)NSMutableArray *messageQueue;
@property(nonatomic, assign)BOOL typing;
@property(nonatomic, strong)BCTimer *timer;

- (void)startWebSocketWithLastMessageId:(long long)lastMessageId;
- (void)startLongPollWithLastMessageId:(long long)lastMessageId;

- (void)restartTimer;
- (void)stopTimer;
- (void)timerTick;

- (void)sendPendingMessagesAndTypingToLink:(BCOSSLink *)link;

@end

@implementation BCOSSCommunicator

@synthesize webSocketURL = _webSocketURL;
@synthesize longPollURL = _longPollURL;
@synthesize chatKey = _chatKey;
@synthesize delegate = _delegate;
@synthesize connectivityManager = _connectivityManager;
@synthesize urlSession = _urlSession;
@synthesize clientId = _clientId;
@synthesize timeoutInSeconds = _timeoutInSeconds;
@synthesize webSocketLink = _webSocketLink;
@synthesize longPollLink = _longPollLink;
@synthesize lastMessageId = _lastMessageId;
@synthesize messageQueue = _messageQueue;
@synthesize typing = _typing;
@synthesize timer = _timer;
@synthesize lastChatMessageId = _lastChatMessageId;

- (id)init {
    if ((self = [super init])) {
        self.messageQueue = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)start {
    if (self.state != BCOSSCommunicatorState_Idle) return;
    [self.messageQueue removeAllObjects];
#if USE_POLL
    self.state = BCOSSCommunicatorState_LongPollConnecting;
    [self startLongPollWithLastMessageId:_lastMessageId];
#else
    self.state = BCOSSCommunicatorState_WebSocketConnecting_LongPollNotUsed;
    [self startWebSocketWithLastMessageId:_lastMessageId];
#endif
}

- (void)startWebSocketWithLastMessageId:(long long)lastMessageId {
    self.webSocketLink = [[BCOSSWebSocketLink alloc] init];
    self.webSocketLink.webSocketUrl = self.webSocketURL;
    self.webSocketLink.delegate = self;
    self.webSocketLink.operationQueue = self.connectivityManager.networkOperationQueue;
    self.webSocketLink.connectivityManager = self.connectivityManager;
    self.webSocketLink.chatKey = self.chatKey;
    self.webSocketLink.clientId = self.clientId;
    self.webSocketLink.lastMessageId = lastMessageId;
    self.webSocketLink.responsePreProcessor = [[BCOSSJSONResponsePreProcessor alloc] init];
    self.webSocketLink.timeoutInSeconds = self.timeoutInSeconds;
    [self.webSocketLink start];
}

- (void)startLongPollWithLastMessageId:(long long)lastMessageId {
    self.longPollLink = [[BCOSSLongPollLink alloc] init];
    self.longPollLink.longPollUrl = self.longPollURL;
    self.longPollLink.delegate = self;
    self.longPollLink.connectivityManager = self.connectivityManager;
    self.longPollLink.chatKey = self.chatKey;
    self.longPollLink.clientId = self.clientId;
    self.longPollLink.lastMessageId = lastMessageId;
    self.longPollLink.responsePreProcessor = [[BCOSSJSONResponsePreProcessor alloc] init];
    self.longPollLink.timeoutInSeconds = self.timeoutInSeconds;
    [self.longPollLink start];
}

- (void)close {
    [self stopTimer];
    [self.webSocketLink close];
    [self.longPollLink close];
    self.state = BCOSSCommunicatorState_Idle;
}

- (void)sendMessage:(BCMessage *)message {
    [self.messageQueue addObject:message];
    
    switch (self.state) {
        case BCOSSCommunicatorState_LongPollConnected:
        case BCOSSCommunicatorState_WebSocketConnecting_LongPollConnected:
            [self.longPollLink sendMessage:message];
            break;
        
        case BCOSSCommunicatorState_WebSocketConnected:
            [self.webSocketLink sendMessage:message];
            break;
        
        default:
            break;
    }
}

- (void)sendTyping:(BOOL)typing {
    self.typing = typing;
    switch (self.state) {
        case BCOSSCommunicatorState_LongPollConnected:
        case BCOSSCommunicatorState_WebSocketConnecting_LongPollConnected:
            [self.longPollLink sendTyping:typing];
            break;
            
        case BCOSSCommunicatorState_WebSocketConnected:
            [self.webSocketLink sendTyping:typing];
            break;
            
        default:
            break;
    }
}

- (void)suspend {
    [self.webSocketLink suspend];
    [self.longPollLink suspend];
}

- (void)resume {
    [self.webSocketLink resume];
    [self.longPollLink resume];
}

- (void)sendPendingMessagesAndTypingToLink:(BCOSSLink *)link {
    [link sendTyping:self.typing];
    for (BCMessage *message in self.messageQueue) {
        [link sendMessage:message];
    }
}

- (NSUInteger)countOfUnsentMessages {
    return self.messageQueue.count;
}

#pragma mark -
#pragma mark Timer
- (void)restartTimer {
    [self stopTimer];
    self.timer = [BCTimer scheduledNonRetainingTimerWithTimeInterval:__BCOSSCommunicator_LongPoll_Start_Delay target:self selector:@selector(timerTick) userInfo:nil repeats:NO];
}

- (void)stopTimer {
    [self.timer invalidate];
    self.timer = nil;
}

- (void)timerTick {
    if (self.state == BCOSSCommunicatorState_WebSocketConnecting_LongPollNotUsed) {
        self.state = BCOSSCommunicatorState_WebSocketConnecting_LongPollConnecting;
        [self startLongPollWithLastMessageId:_lastMessageId];
    }
    self.timer = nil;
}

#pragma mark -
#pragma mark BCOSSLinkDelegate
- (void)ossLinkDidSucceedToConnect:(BCOSSLink *)ossLink {
    BOOL needsNotifyDelegate = NO;
    
    switch (self.state) {
        case BCOSSCommunicatorState_WebSocketConnecting_LongPollNotUsed:
            assert(ossLink == self.webSocketLink);
            [self stopTimer];
            needsNotifyDelegate = YES;
            self.state = BCOSSCommunicatorState_WebSocketConnected;
            [self sendPendingMessagesAndTypingToLink:self.webSocketLink];
            break;
            
        case BCOSSCommunicatorState_WebSocketConnecting_LongPollConnecting:
            if (ossLink == self.webSocketLink) {
                needsNotifyDelegate = YES;
                self.state = BCOSSCommunicatorState_WebSocketConnected;
                [self.longPollLink close];
                self.longPollLink = nil;
                [self sendPendingMessagesAndTypingToLink:self.webSocketLink];
            } else if (ossLink == self.longPollLink) {
                needsNotifyDelegate = YES;
                self.state = BCOSSCommunicatorState_WebSocketConnecting_LongPollConnected;
                [self sendPendingMessagesAndTypingToLink:self.longPollLink];
            }
            break;

        case BCOSSCommunicatorState_WebSocketConnecting_LongPollConnected:
            if (ossLink == self.webSocketLink) {
                needsNotifyDelegate = NO;
                self.state = BCOSSCommunicatorState_WebSocketConnected;
                [self.longPollLink close];
                self.longPollLink = nil;
                [self sendPendingMessagesAndTypingToLink:self.webSocketLink];
            } else if (ossLink == self.longPollLink) {
                needsNotifyDelegate = NO;
            }
            break;
            
        case BCOSSCommunicatorState_WebSocketConnecting:
        case BCOSSCommunicatorState_WebSocketConnected:
            if (ossLink == self.webSocketLink) {
                needsNotifyDelegate = YES;
                self.state = BCOSSCommunicatorState_WebSocketConnected;
                [self sendPendingMessagesAndTypingToLink:self.webSocketLink];
            } else {
                assert(0);
            }
            break;
            
        case BCOSSCommunicatorState_LongPollConnecting:
            if (ossLink == self.longPollLink) {
                needsNotifyDelegate = YES;
                self.state = BCOSSCommunicatorState_LongPollConnected;
                [self sendPendingMessagesAndTypingToLink:self.longPollLink];
            } else {
                assert(0);
            }
            break;
            
        case BCOSSCommunicatorState_LongPollConnected:
            assert(0);
            break;
        
        case BCOSSCommunicatorState_Idle:
        case BCOSSCommunicatorState_Error:
        default:
            assert(0);
            break;
    }
    if (needsNotifyDelegate) {
        [self.delegate ossCommunicatorDidSucceedToConnect:self];
    }
}

- (void)ossLink:(BCOSSLink *)ossLink didFailToConnectWithError:(NSError *)error {
    BOOL needsNotifyDelegate = NO;
    
    switch (self.state) {
        
        case BCOSSCommunicatorState_WebSocketConnecting_LongPollNotUsed:
            assert(self.webSocketLink == ossLink);
            [self stopTimer];
            needsNotifyDelegate = NO;
            self.state = BCOSSCommunicatorState_LongPollConnecting;
            [self startLongPollWithLastMessageId:_lastMessageId];
            
            break;
        
        case BCOSSCommunicatorState_WebSocketConnecting_LongPollConnecting:
            if (ossLink == self.webSocketLink) {
                [self.webSocketLink close];
                self.webSocketLink = nil;
                needsNotifyDelegate = NO;
                self.state = BCOSSCommunicatorState_LongPollConnecting;
            } else if (ossLink == self.longPollLink) {
                [self.longPollLink close];
                self.longPollLink = nil;
                needsNotifyDelegate = NO;
                self.state = BCOSSCommunicatorState_WebSocketConnecting;
            }
            break;
            
        case BCOSSCommunicatorState_WebSocketConnecting_LongPollConnected:
            if (ossLink == self.webSocketLink) {
                [self.webSocketLink close];
                self.webSocketLink = nil;
                needsNotifyDelegate = NO;
                self.state = BCOSSCommunicatorState_LongPollConnected;
            } else if (ossLink == self.longPollLink) {
                [self.longPollLink close];
                self.longPollLink = nil;
                needsNotifyDelegate = NO;
                self.state = BCOSSCommunicatorState_WebSocketConnecting;
            }
            break;
            
        case BCOSSCommunicatorState_WebSocketConnecting:
        case BCOSSCommunicatorState_WebSocketConnected:
            if (ossLink == self.webSocketLink) {
                [self.webSocketLink close];
                self.webSocketLink = nil;
                needsNotifyDelegate = NO;
                self.state = BCOSSCommunicatorState_LongPollConnecting;
                [self startLongPollWithLastMessageId:_lastMessageId];
            } else if (ossLink == self.longPollLink) {
                assert(0);
            }
            break;
            
        case BCOSSCommunicatorState_LongPollConnecting:
        case BCOSSCommunicatorState_LongPollConnected:
            if (ossLink == self.webSocketLink) {
                assert(0);
            } else if (ossLink == self.longPollLink) {
                [self.longPollLink close];
                self.longPollLink = nil;
                needsNotifyDelegate = YES;
                self.state = BCOSSCommunicatorState_Error;
            }
            break;
            
        case BCOSSCommunicatorState_Idle:
        case BCOSSCommunicatorState_Error:
        default:
            assert(0);
            break;
    }
    
    if (needsNotifyDelegate) {
        [self.delegate ossCommunicator:self didFailToConnectWithError:error];
    }
}

- (void)ossLink:(BCOSSLink *)ossLink didReceivePerson:(BCPerson *)person typing:(BOOL)typing {
    [self.delegate ossCommunicator:self didReceivePerson:person typing:typing];
}

- (void)ossLink:(BCOSSLink *)ossLink didReceiveMessage:(BCMessage *)message {
    self.lastChatMessageId = [message.ID longLongValue];
    [self.delegate ossCommunicator:self didReceiveMessage:message];
}

- (void)ossLink:(BCOSSLink *)ossLink didReceiveAutoMessage:(BCMessage *)message {
    [self.delegate ossCommunicator:self didReceiveAutoMessage:message];
}

- (void)ossLink:(BCOSSLink *)ossLink didReceiveBusyWithPosition:(NSInteger)position unavailableFormAvailable:(BOOL)unavailableFormAvailable {
    [self.delegate ossCommunicator:self didReceiveBusyWithPosition:position unavailableFormAvailable:unavailableFormAvailable];
}

- (void)ossLink:(BCOSSLink *)ossLink didEndWithReason:(BCOSSLinkEndReason)reason time:(NSDate *)date error:(NSError *)error {
    BCOSSCommunicatorEndReason endReason = BCOSSCommunicatorEndReasonUnknown;
    switch (reason) {
        case BCOSSLinkEndReasonOperator:
            endReason = BCOSSCommunicatorEndReasonOperator;
            break;
            
        case BCOSSLinkEndReasonVisitor:
            endReason = BCOSSCommunicatorEndReasonVisitor;
            break;
            
        case BCOSSLinkEndReasonDisconnect:
            endReason = BCOSSCommunicatorEndReasonDisconnect;
            break;
        
        case BCOSSLinkEndReasonClosed:
            endReason = BCOSSCommunicatorEndReasonClosed;
            break;
            
        case BCOSSLinkEndReasonTimeout:
            endReason = BCOSSCommunicatorEndReasonTimeout;
            break;
        
        default:
            endReason = BCOSSCommunicatorEndReasonUnknown;
            break;
    }
    [self.delegate ossCommunicator:self didEndWithReason:endReason time:date error:error];
}

- (void)ossLink:(BCOSSLink *)ossLink didAcceptChat:(NSString *)acceptTime {
    if (acceptTime) {
        [self.delegate ossCommunicator:self didAcceptChat:acceptTime];
    }
}

- (void)ossLinkDidReset:(BCOSSLink *)ossLink {
    [self.delegate ossCommunicatorDidReset:self];
}

- (void)ossLink:(BCOSSLink *)ossLink didSendMessageId:(NSString *)messageId {
    NSArray *messageQueueCopy = [self.messageQueue copy];
    for (BCMessage *message in messageQueueCopy) {
        if ([message.ID isEqualToString:messageId]) {
            [self.messageQueue removeObject:message];
            [self.delegate ossCommunicator:self didSendMessage:message];
            break;
        }
    }
}

- (void)ossLink:(BCOSSLink *)ossLink didSendTyping:(BOOL)typing {
    [self.delegate ossCommunicator:self didSendTyping:typing];
}

- (void)ossLink:(BCOSSLink *)ossLink didReceiveLastMessageId:(long long)lastMessageId {
    _lastMessageId = lastMessageId;
    if (ossLink == self.webSocketLink) {
        //set for the other
        self.longPollLink.lastMessageId = lastMessageId;
    } else if (ossLink == self.longPollLink) {
        //set for the other
        self.webSocketLink.lastMessageId = lastMessageId;
    }
}

#pragma mark =
#pragma mark Memory management
- (void)dealloc {
    [self close];
}

@end
