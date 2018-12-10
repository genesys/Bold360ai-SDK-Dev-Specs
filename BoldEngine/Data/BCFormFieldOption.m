//
//  Copyright (c) 2014 LogMeIn Inc. All rights reserved.
//

#import <BoldEngine/BCFormFieldOption.h>

/**
 BCFormFieldOption private inerface..
 @since Version 1.0
 */
@interface BCFormFieldOption ()

/**
 Display name of the option.
 @since Version 1.0
 */
@property(nonatomic, copy)NSString *name;

/**
 Value of the option to be sent if selected.
 @since Version 1.0
 */
@property(nonatomic, copy)NSString *value;

/**
 The branding key if exists for the option.
 @since Version 1.0
 */
@property(nonatomic, copy, copy)NSString *nameBrandingKey;

/**
 If the value is the default.
 @since Version 1.0
 */
@property(nonatomic, assign)BOOL isDefaultValue;

/**
 Determines if available and availableLabel values are set.
 @since Version 1.0
 */
@property(nonatomic, assign)BOOL isAvailiblitySet;

/**
 Determines if the option is available. Only used for departments.
 @since Version 1.0
 */
@property(nonatomic, assign)BOOL isAvailable;

@end

@implementation BCFormFieldOption

@synthesize name = _name;
@synthesize value = _value;
@synthesize nameBrandingKey = _nameBrandingKey;
@synthesize isDefaultValue = _isDefaultValue;
@synthesize isAvailiblitySet = _isAvailiblitySet;
@synthesize isAvailable = _isAvailable;
@synthesize availableLabel = _availableLabel;

+ (id)formOptionWithName:(NSString *)name value:(NSString *)value nameBrandingKey:(NSString *)nameBrandingKey isDefaultValue:(BOOL)isDefaultValue{
    return [[[self class] alloc] initWithName:name value:value nameBrandingKey:nameBrandingKey isDefaultValue:isDefaultValue];
}

+ (id)formOptionWithName:(NSString *)name value:(NSString *)value nameBrandingKey:(NSString *)nameBrandingKey isDefaultValue:(BOOL)isDefaultValue isAvailable:(BOOL)isAvailable availableLabel:(NSString *)availableLabel {
    return [[[self class] alloc] initWithName:name value:value nameBrandingKey:nameBrandingKey isDefaultValue:isDefaultValue isAvailable:isAvailable availableLabel:availableLabel];
}

- (id)initWithName:(NSString *)name value:(NSString *)value nameBrandingKey:(NSString *)nameBrandingKey isDefaultValue:(BOOL)isDefaultValue {
    if ((self = [super init])) {
        self.name = name;
        self.value = value;
        self.isDefaultValue = isDefaultValue;
        self.nameBrandingKey = nameBrandingKey;
    }
    return self;
}

- (id)initWithName:(NSString *)name value:(NSString *)value nameBrandingKey:(NSString *)nameBrandingKey isDefaultValue:(BOOL)isDefaultValue isAvailable:(BOOL)isAvailable availableLabel:(NSString *)availableLabel {
    if ((self = [super init])) {
        self.name = name;
        self.value = value;
        self.isDefaultValue = isDefaultValue;
        self.isAvailable = isAvailable;
        self.availableLabel = availableLabel;
        self.nameBrandingKey = nameBrandingKey;
        self.isAvailiblitySet = YES;
    }
    return self;
}

@end
