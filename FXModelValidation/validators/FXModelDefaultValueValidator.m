//
// Created by Andrey on 12/11/14.
// Copyright (c) 2014 Andrey Gayvoronsky. All rights reserved.
//

#import "FXModelDefaultValueValidator.h"
NSString *const FXFormDefaultValueValidatorMethodSignature = @"%@:";

@implementation FXModelDefaultValueValidator

-(instancetype)init {
	if((self = [super init]))
		self.skipOnEmpty = NO;

	return self;
}

-(void)validate:(id)model attribute:(NSString *)attribute {
	NSAssert(attribute, @"Name of attribute can't be nil.");

	id oldValue = [model valueForKey:attribute];

	if (!([self isEmpty:oldValue]))
		return;

   	id newValue = _value;
	SEL method = nil;

	if([_value isKindOfClass:[NSString class]] && (method = NSSelectorFromString([NSString stringWithFormat:FXFormDefaultValueValidatorMethodSignature, _value])) && [model respondsToSelector:method]) {
		//existing selector
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
		newValue = [model performSelector:method withObject:attribute];
#pragma clang diagnostic pop
	} else if([_value isKindOfClass:NSClassFromString(@"NSBlock")]) {
		//block
		newValue = ((FXFormDefaultValueValidatorBlock)_value)(model, attribute);
	}

	if(!([oldValue isEqual:newValue]))
		[model setValue:newValue forKey:attribute];
}
@end