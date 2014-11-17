//
// Created by Andrey on 13/11/14.
// Copyright (c) 2014 Andrey Gayvoronsky. All rights reserved.
//

#import "FXModelValidator.h"

/**
* FXModelStringValidator validates that the attribute value is of certain length.
*
* Note, this validator should only be used with string-typed attributes.
*/
@interface FXModelStringValidator : FXModelValidator

/**
* Specifies the length limit of the value to be validated.
* This can be specified in one of the following forms:
*
* - an integer: the exact length that the value should be of;
* - an array of one element: the minimum length that the value should be of. For example, `@[@8]`.
*   This will overwrite [[min]].
* - an array of two elements: the minimum and maximum lengths that the value should be of.
*   For example, `@[@8, @128]`. This will overwrite both [[min]] and [[max]].
*/
@property(nonatomic, copy) id length;

/**
* Minimum length. If not set, it means no minimum length limit.
*/
@property(nonatomic, assign) NSInteger min;

/**
* Maximum length. If not set, it means no maximum length limit.
*/
@property(nonatomic, assign) NSInteger max;

/**
* User-defined error message used when the length of the value is smaller than [[min]].
*/
@property(nonatomic, copy) NSString *tooShort;

/**
* User-defined error message used when the length of the value is greater than [[max]].
*/
@property(nonatomic, copy) NSString *tooLong;

/**
* User-defined error message used when the length of the value is not equal to [[length]].
*/
@property(nonatomic, copy) NSString *notEqual;
@end