//
// Created by Andrey on 12/11/14.
// Copyright (c) 2014 Andrey Gayvoronsky. All rights reserved.
//

#import "FXModelValidator.h"

/**
* FXModelNumberValidator validates that the attribute value is a number.
*
* Optionally, you may configure the [[max]] and [[min]] properties to ensure the number
*/
@interface FXModelNumberValidator : FXModelValidator
/**
* User-defined error message used when the value is bigger than [[max]].
*/
@property(nonatomic, copy) NSString *tooBig;

/**
* User-defined error message used when the value is smaller than [[min]].
*/
@property(nonatomic, copy) NSString *tooSmall;

/**
* Upper limit of the number. Defaults to nil, meaning no upper limit.
*/
@property(nonatomic, copy) NSNumber *min;

/**
* Lower limit of the number. Defaults to nil, meaning no lower limit.
*/
@property(nonatomic, copy) NSNumber *max;
@end