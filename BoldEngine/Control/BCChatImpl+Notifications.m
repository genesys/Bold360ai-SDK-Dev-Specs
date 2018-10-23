//
//  Copyright (c) 2014 LogMeIn Inc. All rights reserved.
//

#import "BCChatImpl.h"
#import "BCChatImpl+Notifications.h"


@implementation BCChatImpl (Notifications)

- (void)propagateDidUpdateTyper:(BCPerson *)person typing:(BOOL)typing {
    for (id<BCChatTyperDelegate>delegate in self.chatTyperDelegates) {
        [delegate bcChat:self didUpdateTyper:person typing:typing];
    }
}

- (void)propagateDidSendVisitorTyping:(BOOL)typing {
    for (id<BCChatTyperDelegate>delegate in self.chatTyperDelegates) {
        if([delegate respondsToSelector:@selector(bcChat:didSendVisitorTyping:)]) {
            [delegate bcChat:self didSendVisitorTyping:typing];
        }
    }
}

- (void)propagateDidAddMessage:(BCMessage *)message {
    for (id<BCChatMessageDelegate>delegate in self.chatMessageDelegates) {
        [delegate bcChat:self didAddMessage:message];
    }
}

- (void)propagateDidAddAutoMessage:(BCMessage *)message {
    for (id<BCChatMessageDelegate>delegate in self.chatMessageDelegates) {
        [delegate bcChat:self didAddAutoMessage:message];
    }
}

- (void)propagateDidSendVisitorMessage:(BCMessage *)message {
    for (id<BCChatMessageDelegate>delegate in self.chatMessageDelegates) {
        if ([delegate respondsToSelector:@selector(bcChat:didSendVisitorMessage:)]) {
            [delegate bcChat:self didSendVisitorMessage:message];
        }
    }
}

- (void)propagateDidUpdateQueuePosition:(NSInteger)position unavailableFormAvailable:(BOOL)unavailableFormAvailable {
    for (id<BCChatQueueDelegate>delegate in self.chatQueueDelegates) {
        [delegate bcChat:self didUpdateQueuePosition:position unavailableFormAvailable:unavailableFormAvailable];
    }
}

- (void)propagateDidConnect {
    for (id<BCChatStateDelegate>delegate in self.chatStateDelegates) {
        [delegate bcChatDidConnect:self];
    }
}

- (void)propagateDidAccept {
    for (id<BCChatStateDelegate>delegate in self.chatStateDelegates) {
        [delegate bcChatDidAccept:self];
    }
}

- (void)propagateDidFinishWithReason:(BCChatEndReason)reason time:(NSDate *)date postChatForm:(BCForm *)postChatForm{
    for (id<BCChatStateDelegate>delegate in self.chatStateDelegates) {
        [delegate bcChat:self didFinishWithReason:reason time:date postChatForm:postChatForm];
    }
}

- (void)propagateDidFinishWithUnavailableReason:(BCUnavailableReason)reason unavailableForm:(BCForm *)unavailableForm unavailableMessage:(NSString *)message {
    for (id<BCChatStateDelegate>delegate in self.chatStateDelegates) {
        [delegate bcChat:self didFinishWithUnavailableReason:reason unavailableForm:unavailableForm unavailableMessage:message];
    }
}

- (void)propagateDidFinishWithError:(NSError *)error {
    for (id<BCChatStateDelegate>delegate in self.chatStateDelegates) {
        [delegate bcChat:self didFinishWithError:error];
    }
}

@end
