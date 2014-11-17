//
// Created by Andrey on 12/11/14.
// Copyright (c) 2014 Andrey Gayvoronsky. All rights reserved.
//

#import "FXModelRequiredValidator.h"

@implementation FXModelRequiredValidator

-(instancetype)init {
	if((self = [super init]))
		self.skipOnEmpty = NO;

	return self;
}

-(NSString *)message {
	if([super message])
		return [super message];

	return ((_requiredValue)
			? @"{attribute} must be '{requiredValue}'"
			: @"{attribute} cannot be blank.");
}

-(NSError *)validateValue:(id)value {
	if(_requiredValue == nil) {
		if(!([self isEmpty:value]))
			return nil;
	} else if(value && [value isEqual:_requiredValue]) {
		return nil;
	}

	if (_requiredValue) {
		return [NSError errorWithDomain:FXFormValidatorErrorDomain
								   code:0
							   userInfo:@{
									   NSLocalizedDescriptionKey: self.message,
									   @"{requiredValue}": _requiredValue
							   }];
	} else {
		return [NSError errorWithDomain:FXFormValidatorErrorDomain
								   code:0
							   userInfo:@{
									   NSLocalizedDescriptionKey: self.message,
							   }];
	}
}

@end