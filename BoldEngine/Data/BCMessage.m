//
//  Copyright (c) 2014 LogMeIn Inc. All rights reserved.
//

#import <BoldEngine/BCMessage.h>
#import <BoldEngine/BCPerson.h>
#import "NSString+RandomIdentifier.h"

/**
 BCMessage private interface.
 @since Version 1.0
 */
@interface BCMessage ()

/**
 The ID of the message.
 @since Version 1.0
 */
@property(nonatomic, copy) NSString *ID;

/**
 The creation time of the message.
 @since Version 1.0
 */
@property(nonatomic, copy) NSDate *created;

/**
 The creation time of the message.
 @since Version 1.0
 */
@property(nonatomic, copy) NSDate *updated;

/**
 The message itself. It is an html text.
 @since Version 1.0
 */
@property(nonatomic, copy) NSString *htmlText;
@end

@implementation BCMessage

@synthesize ID = _ID;
@synthesize sender = _sender;
@synthesize created = _created;
@synthesize updated = _updated;
@synthesize htmlText = _htmlText;

+ (id)messageWithID:(NSString *)ID sender:(BCPerson *)person created:(NSDate *)created updated:(NSDate *)updated htmlText:(NSString *)htmlText {
    return [[[self class] alloc] initWithID:ID sender:person created:created updated:updated htmlText:htmlText];
}

- (id)initWithID:(NSString *)ID sender:(BCPerson *)person created:(NSDate *)created updated:(NSDate *)updated htmlText:(NSString *)htmlText {
    if ((self = [super init])) {
        if (ID == nil || ID.length <= 0) {
            self.ID = [NSString bcRandomIdentifier];
        } else {
            self.ID = ID;
        }
        self.sender = person;
        self.created = created;
        self.updated = updated;
        self.htmlText = htmlText;
    }
    return self;
}



@end
