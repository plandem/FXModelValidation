//
// Created by Andrey on 11/11/14.
// Copyright (c) 2014 Andrey Gayvoronsky. All rights reserved.
//

#import "FXModelInlineValidator.h"

NSString *const FXFormInlineValidatorMethodSignature = @"%@:params:";

@interface FXModelInlineValidator ()
@property(nonatomic, strong) NSDictionary *params;
@end

@implementation FXModelInlineValidator

-(instancetype)init {
	if((self = [super init]))
		_params = [NSMutableDictionary dictionary];

	return  self;
}

-(void)validate:(id)model attribute:(NSString *)attribute {
	NSAssert(attribute, @"Name of attribute can't be nil.");

	SEL method = nil;
	if([_action isKindOfClass:[NSString class]] && (method = NSSelectorFromString([NSString stringWithFormat:FXFormInlineValidatorMethodSignature, _action])) && [model respondsToSelector:method]) {
		//action is method of model?
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
		[model performSelector:method withObject:attribute withObject:_params];
#pragma clang diagnostic pop
	} else if([_action isKindOfClass:NSClassFromString(@"NSBlock")])  {
		//action is block?
		((FXFormInlineValidatorBlock)_action)(model, attribute, _params);
	} else {
		@throw [NSException exceptionWithName:@"FXModelInlineValidator" reason:@"The 'action' property is incorrect." userInfo:nil];
	}
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
	((NSMutableDictionary *)_params)[key] = value;
}

- (id)valueForUndefinedKey:(NSString *)key {
	return _params[key];
}
@end