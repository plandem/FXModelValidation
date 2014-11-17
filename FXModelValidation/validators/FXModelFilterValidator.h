//
// Created by Andrey on 13/11/14.
// Copyright (c) 2014 Andrey Gayvoronsky. All rights reserved.
//

#import "FXModelValidator.h"

FOUNDATION_EXPORT NSString *const FXFormFilterValidatorMethodSignature; //signature for method callback.
typedef id(^FXFormFilterValidatorBlock)(id value, NSDictionary *params);  //type of block callback

/**
* FXModelFilterValidator converts the attribute value according to a filter.
*
* FXModelFilterValidator is actually not a validator but a data processor.
* It invokes the specified filter callback to process the attribute value
* and save the processed value back to the attribute.
*/
@interface FXModelFilterValidator : FXModelValidator
/**
* This can be a model's method (signature: '%@:params:') or block (signature: 'id(^FXFormFilterValidatorBlock)(id value, NSDictionary *params)').
*/
@property(nonatomic, copy) id filter;

/**
* Additional parameters that are passed to the filter
*/
@property(nonatomic, readonly) NSDictionary *params;

/**
* Whether the filter should be skipped if an array input is given.
* If 'NO' and an array input is given, the filter will not be applied.
*/
@property(nonatomic, assign) BOOL skipOnArray;
@end