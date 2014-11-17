//
// Created by Andrey on 12/11/14.
// Copyright (c) 2014 Andrey Gayvoronsky. All rights reserved.
//

#import <CoreGraphics/CoreGraphics.h>
#import "FXModelNumberValidator.h"

typedef NS_OPTIONS(NSUInteger, FXFormNumberValidatorComporatorID) {
	FXFormStringValidatorComparatorType,
	FXFormNumberValidatorComparatorMin,
	FXFormNumberValidatorComparatorMax,
};

@implementation FXModelNumberValidator

-(NSString *)message {
	return ([super message] ? [super message] : @"{attribute} must be a number.");
}

-(NSString *)tooBig {
	return (_tooBig ? _tooBig : @"{attribute} must be no greater than {max}.");
}

-(NSString *)tooSmall {
	return (_tooSmall ? _tooSmall : @"{attribute} must be no less than {min}.");
}

-(void)validate:(id)model attribute:(NSString *)attribute {
	NSAssert(attribute, @"Name of attribute can't be nil.");

	NSError *error;
	id value = [model valueForKey:attribute];

	if((error = [self compareValue:value comporator:FXFormStringValidatorComparatorType]))
		[self addError:model attribute:attribute error:error];

	if((error = [self compareValue:value comporator:FXFormNumberValidatorComparatorMin]))
		[self addError:model attribute:attribute error:error];

	if((error = [self compareValue:value comporator:FXFormNumberValidatorComparatorMax]))
		[self addError:model attribute:attribute error:error];
}

-(NSError *)validateValue:(id)value {
	NSError *error;

	if((error = [self compareValue:value comporator:FXFormStringValidatorComparatorType]))
		return error;

	if((error = [self compareValue:value comporator:FXFormNumberValidatorComparatorMin]))
		return error;

	if((error = [self compareValue:value comporator:FXFormNumberValidatorComparatorMax]))
		return error;

	return nil;
}

-(NSError *)compareValue:(id)value comporator:(FXFormNumberValidatorComporatorID)comparatorID {
	switch(comparatorID) {
		case FXFormStringValidatorComparatorType:
			if (!([value isKindOfClass:[NSNumber class]])) {
				return [NSError errorWithDomain:FXFormValidatorErrorDomain
										   code:0
									   userInfo:@{
											   NSLocalizedDescriptionKey: self.message,
									   }];
			}
			break;
		case FXFormNumberValidatorComparatorMin:
			if (_min && ([value floatValue] < [_min floatValue])) {
				return [NSError errorWithDomain:FXFormValidatorErrorDomain
										   code:0
									   userInfo:@{
											   NSLocalizedDescriptionKey: self.tooSmall,
											   @"{min}": _min,
									   }];
			}
			break;
		case FXFormNumberValidatorComparatorMax:
			if(_max && ([value floatValue] > [_max floatValue])) {
				return [NSError errorWithDomain:FXFormValidatorErrorDomain
										   code:0
									   userInfo:@{
											   NSLocalizedDescriptionKey: self.tooBig,
											   @"{max}": _max,
									   }];
			}
			break;
	}

	return nil;
}
@end