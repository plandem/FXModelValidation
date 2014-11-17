//
// Created by Andrey on 12/11/14.
// Copyright (c) 2014 Andrey Gayvoronsky. All rights reserved.
//

#import "FXModelValidator.h"

/**
* FXModelRangeValidator validates that the attribute value is among a list of values.
*
* The range can be specified via the [[range]] property.
* If the [[not]] property is set YES, the validator will ensure the attribute value
* is NOT among the specified range.
*/
@interface FXModelRangeValidator : FXModelValidator

/**
* List of valid values that the attribute value should be among
*/
@property(nonatomic, copy) NSArray *range;

/**
* Whether to invert the validation logic. Defaults to NO. If set to YES,
* the attribute value should NOT be among the list of values defined via [[range]].
*/
@property(nonatomic, assign) BOOL not;

/**
* Whether to allow array type attribute.
*/
@property(nonatomic, assign) BOOL allowArray;
@end