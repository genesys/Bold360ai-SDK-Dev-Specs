//
//  Copyright (c) 2014 LogMeIn Inc. All rights reserved.
//

#import "BCForm.h"
#import <BoldEngine/BCFormField.h>

/**
 BCForm private interface.
 @since Version 1.0
 */
@interface BCForm ()

/**
 An array of BCFormField objects that represent rows of a form.
 @since Version 1.0
 */
@property(nonatomic, copy)NSArray *formFields;

/**
 An array of BCFormField objects that represent rows of a form.
 @since Version 1.0
 */
@property(nonatomic, strong)NSDictionary *formFieldsDictionary;
@end

@implementation BCForm

@synthesize formFields = _formFields;
@synthesize formFieldsDictionary = _formFieldsDictionary;

+ (id)formWithFormFields:(NSArray *)fields {
    return [[[self class] alloc] initWithFormFields:fields];
}

- (id)initWithFormFields:(NSArray *)fields {
    if ((self = [super init])) {
        self.formFields = fields;
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        for (BCFormField *formField in self.formFields) {
            dict[formField.key] = formField;
        }
        self.formFieldsDictionary = [dict copy];
    }
    
    return self;
}

- (BCFormField *)formFieldByKey:(NSString *)key {
    if (!key) return nil;
    return self.formFieldsDictionary[key];
}


@end
