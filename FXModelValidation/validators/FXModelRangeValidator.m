//
// Created by Andrey on 12/11/14.
// Copyright (c) 2014 Andrey Gayvoronsky. All rights reserved.
//

#import "FXModelRangeValidator.h"

@implementation FXModelRangeValidator

-(instancetype)init {
	if((self = [super init])) {
		_allowArray = NO;
		_not = NO;
	}

	return self;
}

-(NSString *)message {
	return ([super message] ? [super message] : @"{attribute} is invalid.");
}

-(NSError *)validateValue:(id)value {
	if(_range == nil || !([_range isKindOfClass:[NSArray class]])) {
		return [NSError errorWithDomain:FXFormValidatorErrorDomain
								   code:0
							   userInfo:@{
									   NSLocalizedDescriptionKey : @"The 'range' property must be set.",
							   }];
	}

	if (!(_allowArray) && [value isKindOfClass:[NSArray class]]) {
		return [NSError errorWithDomain:FXFormValidatorErrorDomain
								   code:0
							   userInfo:@{
									   NSLocalizedDescriptionKey :self.message,
							   }];
	}

	BOOL in = YES;
	if([value isKindOfClass:[NSArray class]]) {
		if(!(_allowArray)) {
			return [NSError errorWithDomain:FXFormValidatorErrorDomain
									   code:0
								   userInfo:@{
										   NSLocalizedDescriptionKey : self.message,
								   }];
		}

		for(id _value in value) {
			if(!([_range containsObject:_value])) {
				in = NO;
				break;
			}
		}
	} else {
	  in = [_range containsObject:value];
	}

	if(_not == in) {
		return [NSError errorWithDomain:FXFormValidatorErrorDomain
								   code:0
							   userInfo:@{
									   NSLocalizedDescriptionKey : self.message,
							   }];
	}

	return nil;
}
@end