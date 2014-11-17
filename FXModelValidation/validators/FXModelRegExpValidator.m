//
// Created by Andrey on 13/11/14.
// Copyright (c) 2014 Andrey Gayvoronsky. All rights reserved.
//

#import "FXModelRegExpValidator.h"

@implementation FXModelRegExpValidator {
	NSRegularExpression *_regExp;
}

-(instancetype)init {
	if((self = [super init]))
		_not = NO;

	return self;
}

-(NSString *)message {
	return ([super message] ? [super message] : @"{attribute} is invalid.");
}

-(void)setPattern:(id)pattern {
	if([pattern isKindOfClass:[NSString class]]) {
		_regExp = [NSRegularExpression regularExpressionWithPattern:pattern
															options:NSRegularExpressionCaseInsensitive
															  error:nil];
	} else if([pattern isKindOfClass:[NSRegularExpression class]]) {
		_regExp = [(NSRegularExpression *) pattern copy];
	} else {
		@throw [NSException exceptionWithName:@"FXModelRegExpValidator" reason:@"Invalid type of 'pattern'. Only NSString and NSRegularExpression are supported." userInfo:nil];
	}
}

-(NSError *)validateValue:(id)value {
	if(_regExp == nil)
		@throw [NSException exceptionWithName:@"FXModelRegExpValidator" reason:@"The 'pattern' property must be set." userInfo:nil];

	BOOL matched = _not;

	if([value isKindOfClass:[NSString class]]) {
		NSTextCheckingResult *match = [_regExp firstMatchInString:value options:0 range:NSMakeRange(0, [value length])];
		matched = (match.numberOfRanges > 0);
	}

	if(_not == matched) {
		return [NSError errorWithDomain:FXFormValidatorErrorDomain
								   code:0
							   userInfo:@{
									   NSLocalizedDescriptionKey : self.message,
							   }];
	}

	return nil;
}
@end