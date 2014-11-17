//
// Created by Andrey on 12/11/14.
// Copyright (c) 2014 Andrey Gayvoronsky. All rights reserved.
//

#import <CoreGraphics/CoreGraphics.h>
#import "FXModelCompareValidator.h"

@implementation FXModelCompareValidator

-(instancetype)init {
	if((self = [super init]))
		_operator = @"==";

	return self;
}

/**
* @var string the user-defined error message. It may contain the following placeholders which
* will be replaced accordingly by the validator:
*
* - `{attribute}`: the label of the attribute being validated
* - `{value}`: the value of the attribute being validated
* - `{compareValue}`: the value or the attribute label to be compared with
* - `{compareAttribute}`: the label of the attribute to be compared with
*/
-(NSString *)message {
	if([super message])
		return [super message];

	if([_operator isEqual:@"=="])
		return @"{attribute} must be repeated exactly.";
	else if([_operator isEqual:@"!="])
		return @"{attribute} must not be equal to '{compareValue}'.";
	else if([_operator isEqual:@">"])
		return @"{attribute} must be greater than '{compareValue}'.";
	else if([_operator isEqual:@">="])
		return @"{attribute} must be greater than or equal to '{compareValue}'.";
	else if([_operator isEqual:@"<"])
		return @"{attribute} must be less than '{compareValue}'.";
	else if([_operator isEqual:@"<="])
		return @"{attribute} must be less than or equal to '{compareValue}'.";
	else
		@throw [NSException exceptionWithName:@"FXModelCompareValidator" reason:[NSString stringWithFormat: @"Unknown operator: %@", _operator] userInfo:nil];
}

-(void)validate:(id)model attribute:(NSString *)attribute {
	NSAssert(attribute, @"Name of attribute can't be nil.");

	NSError *error;
	id value = [model valueForKey:attribute];
  	id compareValue = _compareValue;
	id compareAttribute = value;

	if(!([value isKindOfClass:[NSNumber class]] || [value isKindOfClass:[NSString class]] || [value isKindOfClass:[NSDate class]])) {
		error = [NSError errorWithDomain:FXFormValidatorErrorDomain
									code:0
								userInfo:@{
										NSLocalizedDescriptionKey: @"{attribute} is invalid.",
								}];

		[self addError:model attribute:attribute error:error];
		return;
	}

	if(compareValue == nil) {
		compareAttribute = (_compareAttribute == nil ? [NSString stringWithFormat:@"%@_repeat", attribute] : _compareAttribute);
		compareValue = [model valueForKey:compareAttribute];
	}

	if (!([self compareValues:value compareValue:compareValue])) {
		error = [NSError errorWithDomain:FXFormValidatorErrorDomain
									code:0
								userInfo:@{
										NSLocalizedDescriptionKey: self.message,
										@"{compareAttribute}": [compareAttribute description],
										@"{compareValue}": [compareValue description],
								}];

		[self addError:model attribute:attribute error:error];
	}
}

-(NSError *)validateValue:(id)value {
	NSAssert(_compareValue, @"'compareValue' must be set.");

	if(([self compareValues:value compareValue:_compareValue]))
		return nil;

	return [NSError errorWithDomain:FXFormValidatorErrorDomain
							   code:0
						   userInfo:@{
								   NSLocalizedDescriptionKey: self.message,
								   @"{compareAttribute}": [_compareValue description],
								   @"{compareValue}": [_compareValue description],
						   }];
}

/**
* Compares two values with the specified operator.
* @param value the value being compared
* @param compareValue another value being compared
* @return whether the comparison using the specified operator is true.
*/
-(BOOL)compareValues:(id)value compareValue:(id)compareValue {
	if(([value isKindOfClass:[NSString class]] && [compareValue isKindOfClass:[NSString class]]) ||
		([value isKindOfClass:[NSDate class]] && [compareValue isKindOfClass:[NSDate class]]))
	{
		NSComparisonResult compare = [value compare:compareValue];

		if([_operator isEqual:@"=="])
			return (compare == NSOrderedSame);
		else if([_operator isEqual:@"!="])
			return (compare != NSOrderedSame);
		else if([_operator isEqual:@">"])
			return (compare == NSOrderedDescending);
		else if([_operator isEqual:@">="])
			return (compare == NSOrderedDescending || compare == NSOrderedSame);
		else if([_operator isEqual:@"<"])
			return (compare == NSOrderedAscending);
		else if([_operator isEqual:@"<="])
			return (compare == NSOrderedAscending || compare == NSOrderedSame);
	} else if([value isKindOfClass:[NSNumber class]] && [compareValue isKindOfClass:[NSNumber class]]) {
		CGFloat value1 = [value floatValue];
		CGFloat value2 = [compareValue floatValue];

		if([_operator isEqual:@"=="])
			return (value1 == value2);
		else if([_operator isEqual:@"!="])
			return (value1 != value2);
		else if([_operator isEqual:@">"])
			return (value1 > value2);
		else if([_operator isEqual:@">="])
			return (value1 >= value2);
		else if([_operator isEqual:@"<"])
			return (value1 < value2);
		else if([_operator isEqual:@"<="])
			return (value1 <= value2);
	}

	return NO;
}
@end