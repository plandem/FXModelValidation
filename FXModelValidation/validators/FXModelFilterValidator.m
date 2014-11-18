//
// Created by Andrey on 13/11/14.
// Copyright (c) 2014 Andrey Gayvoronsky. All rights reserved.
//

#import "FXModelFilterValidator.h"

NSString *const FXFormFilterValidatorMethodSignature = @"%@:params:";

@interface FXModelFilterValidator ()
@property(nonatomic, strong) NSDictionary *params;
@end

@implementation FXModelFilterValidator

-(instancetype)init {
	if((self = [super init])) {
		_params = [NSMutableDictionary dictionary];
		_skipOnArray = NO;
		self.skipOnEmpty = NO;
	}

	return  self;
}

-(void)validate:(id)model attribute:(NSString *)attribute {
	NSAssert(attribute, @"Name of attribute can't be nil.");
	NSAssert(_filter, @"The 'filter' property must be set.");

	id oldValue = [model valueForKey:attribute];
	id newValue;
	SEL method = nil;

	if (!(_skipOnArray) || !([oldValue isKindOfClass:[NSArray class]] || [oldValue isKindOfClass:[NSSet class]] || [oldValue isKindOfClass:[NSDictionary class]])) {
		if([_filter isKindOfClass:[NSString class]] && ((method = NSSelectorFromString([NSString stringWithFormat:FXFormFilterValidatorMethodSignature, _filter])) && [model respondsToSelector:method])) {
			//filter is method of model?
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
			newValue = [model performSelector:method withObject:oldValue withObject:_filter];
#pragma clang diagnostic pop
		} else if([_filter isKindOfClass:NSClassFromString(@"NSBlock")]) {
			//filter is block?
			newValue = ((FXFormFilterValidatorBlock)_filter)(oldValue, _params);
		} else {
			@throw [NSException exceptionWithName:@"FXModelFilterValidator" reason:@"The 'filter' property is incorrect." userInfo:nil];
		}

		//we must test for equality to prevent endless cycle with observing for updates
		if(!([newValue isEqual:oldValue]))
			[model setValue:newValue forKey:attribute];
	}
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
	((NSMutableDictionary *)_params)[key] = value;
}

- (id)valueForUndefinedKey:(NSString *)key {
	return _params[key];
}
@end