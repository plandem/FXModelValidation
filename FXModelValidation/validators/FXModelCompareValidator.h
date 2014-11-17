//
// Created by Andrey on 12/11/14.
// Copyright (c) 2014 Andrey Gayvoronsky. All rights reserved.
//

#import "FXModelValidator.h"

/**
* FXModelCompareValidator compares the specified attribute value with another value.
*
* The value being compared with can be another attribute value
* (specified via [[compareAttribute]]) or a constant (specified via
* [[compareValue]]. When both are specified, the latter takes
* precedence. If neither is specified, the attribute will be compared
* with another attribute whose name is by appending "_repeat" to the source
* attribute name.
*
* CompareValidator supports different comparison operators, specified
* via the [[operator]] property.
*/
@interface FXModelCompareValidator : FXModelValidator

/**
* The name of the attribute to be compared with. When both this property
* and [[compareValue]] are set, the latter takes precedence. If neither is set,
* it assumes the comparison is against another attribute whose name is formed by
* appending '_repeat' to the attribute being validated. For example, if 'password' is
* being validated, then the attribute to be compared would be 'password_repeat'.
* @see compareValue
*/
@property(nonatomic, copy) NSString *compareAttribute;

/**
* The constant value to be compared with. When both this property
* and [[compareAttribute]] are set, this property takes precedence.
* @see compareAttribute
*/
@property(nonatomic, copy) id compareValue;

/**
* The operator for comparison. The following operators are supported:
*
* - `==`: check if two values are equal
* - `!=`: check if two values are NOT equal
* - `>`: check if value being validated is greater than the value being compared with.
* - `>=`: check if value being validated is greater than or equal to the value being compared with.
* - `<`: check if value being validated is less than the value being compared with.
* - `<=`: check if value being validated is less than or equal to the value being compared with.
*/
@property(nonatomic, copy) NSString *operator;
@end