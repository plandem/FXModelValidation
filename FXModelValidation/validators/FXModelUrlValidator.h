//
// Created by Andrey on 13/11/14.
// Copyright (c) 2014 Andrey Gayvoronsky. All rights reserved.
//

#import "FXModelValidator.h"

/**
* FXModelUrlValidator validates that the attribute value is a valid http or https URL.
*
* Note that this validator only checks if the URL scheme and host part are correct.
* It does not check the rest part of a URL.
*/
@interface FXModelUrlValidator : FXModelValidator

/**
* The regular expression used to validate the attribute value.
* The pattern may contain a `{schemes}` token that will be replaced
* by a regular expression which represents the [[validSchemes]].
*/
@property(nonatomic, copy) NSString *pattern;

/**
* Whether validation process should take into account IDN (internationalized
* domain names). Defaults to NO meaning that validation of URLs containing IDN will always
* fail. Method encodeIDN(@see encodeIDN:) is using for IDN.
*/
@property(nonatomic, assign) BOOL enableIDN;

/**
* List of URI schemes which should be considered valid. By default, http and https
* are considered to be valid schemes.
*/
@property(nonatomic, copy) NSArray *validSchemes;

/**
* The default URI scheme. If the input doesn't contain the scheme part, the default
* scheme will be prepended to it (thus changing the input). Defaults to nil, meaning a URL must
* contain the scheme part.
*/
@property(nonatomic, copy) NSString *defaultScheme;

/**
* Try to convert value to IDN format. This method is using external libraries. If no libraries found it outputs warning in DEBUG mode.
*/
+(NSString *)encodeIDN:(NSString *)value;
@end