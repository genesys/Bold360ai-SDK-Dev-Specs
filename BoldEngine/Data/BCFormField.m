//
//  Copyright (c) 2014 LogMeIn Inc. All rights reserved.
//

#import "BCFormField.h"
#import "BCFormFieldOption.h"

/**
 BCFormField private inerface.
 @since Version 1.0
 */
@interface BCFormField ()

/**
 Type of the field.
 @since Version 1.0
 */
@property(nonatomic, assign) BCFormFieldType type;

/**
 Key of the field.
 @since Version 1.0
 */
@property(nonatomic, copy) NSString *key;

/**
 Shows if the text input needs to be shown multiline.
 @since Version 1.0
 */
@property(nonatomic, assign) BOOL isMultiline;

/**
 The title label text of the field.
 @since Version 1.0
 */
@property(nonatomic, copy) NSString *label;

/**
 The localized label text to display.
 @since Version 1.0
 */
@property(nonatomic, copy)NSString *labelBrandingKey;

/**
 Filling the field is required
 @since Version 1.0
 */
@property(nonatomic, assign) BOOL isRequired;

/**
 The item is needed to be shown.
 @since Version 1.0
 */
@property(nonatomic, assign)BOOL isVisible;

/**
 If the field is for selecting departments, it shows if the online status of a department is needed to be shown.
 @since Version 1.0
 */
@property(nonatomic, assign)BOOL isDepartmentStatusVisible;

/**
 If the field is a select ot a radio, the options are in this  array in \link BCFormFieldOption \endlink objects.
 @since Version 1.0
 */
@property(nonatomic, copy) NSArray *options;

@end

@implementation BCFormField

@synthesize type = _type;
@synthesize key = _key;
@synthesize isMultiline = _isMultiline;
@synthesize label = _label;
@synthesize labelBrandingKey = _labelBrandingKey;
@synthesize isRequired = _isRequired;
@synthesize isVisible = _isVisible;
@synthesize isDepartmentStatusVisible = _isDepartmentStatusVisible;
@synthesize options = _options;
@synthesize value = _value;

- (BCFormFieldOption *)defaultOption {
    BCFormFieldOption *defaultOption = nil;
    for (BCFormFieldOption *option in self.options) {
        if (option.isDefaultValue) {
            defaultOption = option;
            break;
        }
    }
    return defaultOption;
}

+ (id)formFieldWithType:(BCFormFieldType)type
                    key:(NSString *)key
            isMultiline:(BOOL)isMultiline
                  label:(NSString *)label
       labelBrandingKey:(NSString *)labelBrandingKey
             isRequired:(BOOL)isRequired
              isVisible:(BOOL)isVisible
isDepartmentStatusVisible:(BOOL)isDepartmentStatusVisible
           defaultValue:(NSString *)defaultValue
                options:(NSArray *)options {
    return [[[self class] alloc] initWithType:type
                                          key:key
                                  isMultiline:isMultiline
                                        label:label
                             labelBrandingKey:labelBrandingKey
                                   isRequired:isRequired
                                    isVisible:isVisible
                    isDepartmentStatusVisible:isDepartmentStatusVisible
                                 defaultValue:defaultValue
                                      options:options];
}

- (id)initWithType:(BCFormFieldType)type
               key:(NSString *)key
       isMultiline:(BOOL)isMultiline
             label:(NSString *)label
  labelBrandingKey:(NSString *)labelBrandingKey
        isRequired:(BOOL)isRequired
         isVisible:(BOOL)isVisible
isDepartmentStatusVisible:(BOOL)isDepartmentStatusVisible
      defaultValue:(NSString *)defaultValue
           options:(NSArray *)options {
    if ((self = [super init])) {
        self.type = type;
        self.key = key;
        self.isMultiline = isMultiline;
        self.label = label;
        self.labelBrandingKey = labelBrandingKey;
        self.isRequired = isRequired;
        self.isVisible = isVisible;
        self.isDepartmentStatusVisible = isDepartmentStatusVisible;
        self.value = defaultValue;
        self.options = options;
    }
    return self;
}

@end
