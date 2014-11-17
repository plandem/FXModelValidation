//
// Created by Andrey on 12/11/14.
// Copyright (c) 2014 Andrey Gayvoronsky. All rights reserved.
//

#import "FXModelValidator.h"

/**
* FXModelEmailValidator validates that the attribute value is a valid email address.
*/
@interface FXModelEmailValidator : FXModelValidator
/**
* Whether to check whether the email's domain exists.
* Be aware that this check can fail due to temporary DNS problems even if the email address is
* valid and an email would be deliverable. Defaults to NO.
*/
@property(nonatomic, assign) BOOL checkDNS;

/**
* Whether validation process should take into account IDN (internationalized domain
* names). Defaults to NO meaning that validation of emails containing IDN will always fail.
* FXModelUrlValidator (@see FXModelUrlValidator:encodeIDN) is used for IDN.
*/
@property(nonatomic, assign) BOOL enableIDN;
@end