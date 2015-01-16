//
// Created by Andrey on 10/11/14.
// Copyright (c) 2014 Andrey Gayvoronsky. All rights reserved.
//

#import "FXModelValidation.h"
#import <objc/runtime.h>

NSString *const FXFormValidatorErrorDomain = @"FXFormValidation";
NSString *const FXFormInlineValidatorAction = @"action";
static NSDictionary *FXFormBuiltInValidators;

@implementation FXModelValidator
-(instancetype)init {
	if((self = [super init])) {
		_skipOnEmpty = YES;
		_skipOnError = YES;
		_when = nil;
		_on = @[];
		_except = @[];
	}

	return self;
}

-(instancetype)initWithAttributes:(NSArray *)attributes params:(NSDictionary *)params {
	if((self = [self init])) {
		_attributes = [attributes copy];

		[params enumerateKeysAndObjectsUsingBlock:^(NSString *key, id value, __unused BOOL *stop) {
			[self setValue:value forKey:key];
		}];
	}

	return self;
}

-(void)validate:(id)model{
	[self validate:model attributes:nil];
}

-(void)validate:(id)model attributes:(NSArray *)attributes {
	if(attributes) {
		NSMutableSet *intersection = [NSMutableSet setWithArray:_attributes];
		[intersection intersectSet:[NSSet setWithArray:attributes]];
		attributes = [intersection allObjects];
	} else
		attributes = _attributes;


	for(NSString *name in attributes) {
		BOOL skip = ([self skipOnError] && [model hasErrors:name]) || ([self skipOnEmpty] && [self isEmpty:[model valueForKey:name]]);
		if (!(skip)) {
			if(_when == nil || _when(model, name)) {
				[self validate:model attribute:name];
			}
		}
	}
}

-(void)validate:(id)model attribute:(NSString *)attribute {
	NSAssert(attribute, @"Name of attribute can't be nil.");

	NSError *error = [self validateValue:[model valueForKey:attribute]];
	if (error)
		[self addError:model attribute:attribute error:error];
}

-(NSError *)validateValue:(id)value {
	@throw [NSException exceptionWithName:@"FXModelValidator" reason:[NSString stringWithFormat:@"Expected -validateValue: to be implemented by %@", NSStringFromClass([self class])] userInfo:nil];
}

-(BOOL)isActive:(NSString *)scenario {
	return (!([_except containsObject:scenario]) && (!([_on count]) || [_on containsObject:scenario]));
}

-(void)addError:(id)model attribute:(NSString *)attribute error:(NSError *)error{
	__block NSString *message;

	//TODO: think about optimization of localisation errors mechanism
	if(error && (message = error.localizedDescription)) {
		NSMutableDictionary *params = [error.userInfo mutableCopy];
		params[@"{attribute}"] = attribute;

		[params enumerateKeysAndObjectsUsingBlock:^(NSString *key, id value, __unused BOOL *stop) {
			message = [message stringByReplacingOccurrencesOfString:key withString:[NSString stringWithFormat:@"%@", value]];
		}];

		[model addError:attribute message:message];
	}
}

-(BOOL)isEmpty:(id)value {
	if(_isEmpty)
		return _isEmpty(value);

	return  (
		value == nil || [value isKindOfClass:[NSNull class]] ||
		(([value isKindOfClass:[NSArray class]] || [value isKindOfClass:[NSDictionary class]] || [value isKindOfClass:[NSSet class]] || [value isKindOfClass:[NSOrderedSet class]]) && [value count] < 1) ||
		([value isKindOfClass:[NSString class]] && [value length] < 1)
	);
}

+(FXModelValidator *)createValidator:(id)type model:(id)model attributes:(NSArray *)attributes params:(NSDictionary *)params {
	FXModelValidator *validator;

	if([type isKindOfClass:NSClassFromString(@"NSBlock")]) {
		//type is block
		validator = [FXModelValidator createInlineValidator:type attributes:attributes params:params];
	} else if([type isKindOfClass:[NSString class]]) {
		if([model respondsToSelector:NSSelectorFromString([NSString stringWithFormat:FXFormInlineValidatorMethodSignature, type])]) {
			//type is method of class
			validator = [FXModelValidator createInlineValidator:type attributes:attributes params:params];
		} else {
			static dispatch_once_t onceToken;
			dispatch_once(&onceToken, ^{
				FXFormBuiltInValidators = @{
						@"boolean": 	[FXModelBooleanValidator class],
						@"compare": 	[FXModelCompareValidator class],
						@"default": 	[FXModelDefaultValueValidator class],
						@"email":		[FXModelEmailValidator class],
						@"filter":		[FXModelFilterValidator class],
						@"number":		[FXModelNumberValidator class],
						@"in":			[FXModelRangeValidator class],
						@"match":		[FXModelRegExpValidator class],
						@"required":	[FXModelRequiredValidator class],
						@"safe":		[FXModelSafeValidator class],
						@"string":		[FXModelStringValidator class],
						@"url":			[FXModelUrlValidator class],
						@"trim":		[FXModelTrimFilter class],
				};
			});

			//type is valid name of external built-in validator?
			if((type = FXFormBuiltInValidators[type]))
				validator = [FXModelValidator createExternalValidator:(([type isKindOfClass:[NSString class]]) ? NSClassFromString(type) : (Class) type) attributes:attributes params:params];
		}
	} else if([type isKindOfClass:[FXModelValidator class]]) {
		//type is instance of FXModelValidator
		validator = [FXModelValidator createExternalValidator:[type class] attributes:attributes params:params];
	} else if(class_isMetaClass(object_getClass(type))) {
		//type is a meta class
		validator = [FXModelValidator createExternalValidator:(Class) type attributes:attributes params:params];
	}

	return validator;
}

+(FXModelValidator *)createExternalValidator:(Class)className attributes:(NSArray *)attributes params:(NSDictionary *)params {
	if(className) {
		id validator = [className alloc];

		if (validator && [validator isKindOfClass:[FXModelValidator class]])
			return [validator initWithAttributes:attributes params:params];
	}

	return nil;
}

+(FXModelValidator *)createInlineValidator:(id)type attributes:(NSArray *)attributes params:(NSDictionary *)params {
	if(!([params isKindOfClass:[NSMutableDictionary class]]))
		params = ((params) ? [params mutableCopy] : [[NSMutableDictionary alloc] init]);

	((NSMutableDictionary *)params)[FXFormInlineValidatorAction] = [type copy];
	return [[FXModelInlineValidator alloc] initWithAttributes:attributes params:params];
}
@end