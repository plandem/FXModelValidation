//
// Created by Andrey on 12/11/14.
// Copyright (c) 2014 Andrey Gayvoronsky. All rights reserved.
//

#import "FXModelValidator.h"

FOUNDATION_EXPORT NSString *const FXFormDefaultValueValidatorMethodSignature; //signature for method callback.
typedef id(^FXFormDefaultValueValidatorBlock)(id model, NSString *attribute); //type of block callback

/**
* FXModelDefaultValueValidator sets the attribute to be the specified default value.
*
* FXModelDefaultValueValidator is not really a validator. It is provided mainly to allow
* specifying attribute default values when they are empty.
*/
@interface FXModelDefaultValueValidator : FXModelValidator

/**
* The default value, model's method(signature:'%@:') or block(signature: 'id(^FXFormDefaultValueValidatorBlock)(id model, NSString *attribute)') that returns the default value which will
* be assigned to the attributes being validated if they are empty.
*/
@property(nonatomic, copy) id value;
@end