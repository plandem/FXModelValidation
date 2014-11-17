//
// Created by Andrey on 12/11/14.
// Copyright (c) 2014 Andrey Gayvoronsky. All rights reserved.
//

#import "FXModelBooleanValidator.h"

@implementation FXModelBooleanValidator

-(instancetype)init {
	if((self = [super init])) {
		_trueValue = @(YES);
		_falseValue = @(NO);
	}

	return self;
}

-(NSString *)message {
	return ([super message] ? [super message] : @"{attribute} must be either '{true}' or '{false}'.");
}

-(NSError *)validateValue:(id)value {
	if([value isEqual:_trueValue] || [value isEqual:_falseValue])
		return nil;

	return [NSError errorWithDomain:FXFormValidatorErrorDomain
							   code:0
						   userInfo:@{
								   NSLocalizedDescriptionKey: self.message,
								   @"{true}": [self.trueValue description],
								   @"{false}": [self.falseValue description],
						   }];
}
@end