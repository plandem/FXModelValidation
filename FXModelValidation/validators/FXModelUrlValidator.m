//
// Created by Andrey on 13/11/14.
// Copyright (c) 2014 Andrey Gayvoronsky. All rights reserved.
//

#import "FXModelUrlValidator.h"


@implementation FXModelUrlValidator
-(instancetype)init {
	if((self = [super init])) {
		_enableIDN = YES;
		_pattern = @"^{schemes}:\\/\\/(([A-Z0-9][A-Z0-9_-]*)(\\.[A-Z0-9][A-Z0-9_-]*)+)";
		_validSchemes = @[@"http", @"https"];
	}

	return  self;
}

-(NSString *)message {
	return ([super message] ? [super message] : @"{attribute} is not a valid URL.");
}

-(void)validate:(id)model attribute:(NSString *)attribute {
	NSAssert(attribute, @"Name of attribute can't be nil.");

	id value = [model valueForKey:attribute];
	NSError *error = [self validateValue:value];

	if(error) {
		[self addError:model attribute:attribute error:error];
	} else if(_defaultScheme && [value rangeOfString:@"://"].location == NSNotFound) {
		[model setValue:[NSString stringWithFormat:@"%@://%@", _defaultScheme, value] forKey:attribute];
	}
}

-(NSError *)validateValue:(id)value {
	NSString *pattern = _pattern;

	if([value isKindOfClass:[NSString class]]) {
		if(_defaultScheme && [value rangeOfString:@"://"].location == NSNotFound)
			value = [NSString stringWithFormat:@"%@://%@", _defaultScheme, value];

		if([pattern rangeOfString:@"{schemes}"].location != NSNotFound)
			pattern = [pattern stringByReplacingOccurrencesOfString:@"{schemes}" withString:[NSString stringWithFormat:@"(%@)", [_validSchemes componentsJoinedByString:@"|"]]];

		if(_enableIDN)
			value = [FXModelUrlValidator encodeIDN:value];

		NSRegularExpression *regExp = [NSRegularExpression regularExpressionWithPattern:pattern
															options:NSRegularExpressionCaseInsensitive
															  error:nil];

		NSTextCheckingResult *match = [regExp firstMatchInString:value options:0 range:NSMakeRange(0, [value length])];

		if(match.numberOfRanges)
			return nil;
	}

	return [NSError errorWithDomain:FXFormValidatorErrorDomain
							   code:0
						   userInfo:@{
								   NSLocalizedDescriptionKey: self.message,
						   }];
}

+(NSString *)encodeIDN:(NSString *)value {
	SEL encoder;
	NSString *urlString = value;

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
	if((encoder = NSSelectorFromString(@"IDNEncodedURL:")) && [[NSURL class] respondsToSelector:encoder]) {
		value = [NSURL performSelector:encoder withObject:urlString];
	} else if((encoder = NSSelectorFromString(@"encodedURLString:")) && [NSString respondsToSelector:encoder]) {
		value = [urlString performSelector:encoder];
	}  else {
		#if DEBUG
			NSLog(@"IDN encoding is not supported.");
		#endif
	}
#pragma clang diagnostic pop

	return value;
}
@end