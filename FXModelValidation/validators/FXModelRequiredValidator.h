//
// Created by Andrey on 12/11/14.
// Copyright (c) 2014 Andrey Gayvoronsky. All rights reserved.
//

#import "FXModelValidator.h"

/**
* FXModelRequiredValidator validates that the specified attribute is not empty or have required value.
*/
@interface FXModelRequiredValidator : FXModelValidator

/**
* The desired value that the attribute must have.
* If this is nil, the validator will validate that the specified attribute is not empty.
* If this is set as a value that is not nil, the validator will validate that
* the attribute has a value that is the same as this property value.
* Defaults to nil.
*/
@property(nonatomic, copy) id requiredValue;
@end