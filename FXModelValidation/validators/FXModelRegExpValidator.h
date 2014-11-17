//
// Created by Andrey on 13/11/14.
// Copyright (c) 2014 Andrey Gayvoronsky. All rights reserved.
//

#import "FXModelValidator.h"

/**
* FXModelRegExpValidator validates that the attribute value matches the specified [[pattern]].
*
* If the [[not]] property is set YES, the validator will ensure the attribute value do NOT match the [[pattern]].
*/
@interface FXModelRegExpValidator : FXModelValidator

/**
* Regular expression to be matched with. It can be string or instance of NSRegularExpression
*/
@property(nonatomic, copy) id pattern;

/**
* Whether to invert the validation logic. Defaults to NO. If set to YES,
* the regular expression defined via [[pattern]] should NOT match the attribute value.
*/
@property(nonatomic, assign) BOOL not;
@end