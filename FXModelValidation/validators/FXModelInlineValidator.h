//
// Created by Andrey on 11/11/14.
// Copyright (c) 2014 Andrey Gayvoronsky. All rights reserved.
//

#import "FXModelValidator.h"

FOUNDATION_EXPORT NSString *const FXFormInlineValidatorMethodSignature; //signature for method callback.
typedef void(^FXFormInlineValidatorBlock)(id model, NSString *attribute, NSDictionary *params);  //type of block callback

/**
* FXModelInlineValidator represents a validator which is defined as a method in the model or block.
*/
@interface FXModelInlineValidator : FXModelValidator

/**
* The name of a model class method that will be
* called to perform the actual validation (signature: '%@:params:') or block (signature: 'void(^FXFormInlineValidatorBlock)(id model, NSString *attribute, NSDictionary *params)').
*/
@property(nonatomic, copy) id action;

/**
* Additional parameters that are passed to the validator
*/
@property(nonatomic, readonly) NSDictionary *params;
@end