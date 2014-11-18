//
// Created by Andrey on 10/11/14.
// Copyright (c) 2014 Andrey Gayvoronsky. All rights reserved.
//

#import "FXModelValidation.h"
#import "FXModelObserver.h"
#import <objc/runtime.h>

/**
* The name of the default scenario.
*/
NSString *const SCENARIO_DEFAULT = @"default";

#pragma clang diagnostic push
#pragma ide diagnostic ignored "OCUnusedGlobalDeclarationInspection"
//meta properties
NSString *const FXModelValidatorType = @"-validator";

//all known properties for built-in validators/filters
NSString *const FXModelValidatorAttributes = @"attributes";
NSString *const FXModelValidatorSkipOnError = @"skipOnError";
NSString *const FXModelValidatorSkipOnEmpty = @"skipOnEmpty";
NSString *const FXModelValidatorMessage = @"message";
NSString *const FXModelValidatorIsEmpty = @"isEmpty";
NSString *const FXModelValidatorAction = @"action";
NSString *const FXModelValidatorTrueValue = @"trueValue";
NSString *const FXModelValidatorFalseValue = @"falseValue";
NSString *const FXModelValidatorCompareAttribute = @"compareAttribute";
NSString *const FXModelValidatorCompareValue = @"compareValue";
NSString *const FXModelValidatorOperator = @"operator";
NSString *const FXModelValidatorValue = @"value";
NSString *const FXModelValidatorCheckDNS = @"checkDNS";
NSString *const FXModelValidatorEnableIDN = @"enableIDN";
NSString *const FXModelValidatorFilter = @"filter";
NSString *const FXModelValidatorSkipOnArray = @"skipOnArray";
NSString *const FXModelValidatorTooBig = @"tooBig";
NSString *const FXModelValidatorTooSmall = @"tooSmall";
NSString *const FXModelValidatorMin = @"min";
NSString *const FXModelValidatorMax = @"max";
NSString *const FXModelValidatorRange = @"range";
NSString *const FXModelValidatorAllowArray = @"allowArray";
NSString *const FXModelValidatorNot = @"not";
NSString *const FXModelValidatorPattern = @"pattern";
NSString *const FXModelValidatorRequiredValue = @"requiredValue";
NSString *const FXModelValidatorLength = @"length";
NSString *const FXModelValidatorTooShort = @"tooShort";
NSString *const FXModelValidatorTooLong = @"tooLong";
NSString *const FXModelValidatorNotEqual = @"notEqual";
NSString *const FXModelValidatorValidSchemes = @"validSchemes";
NSString *const FXModelValidatorDefaultScheme = @"defaultScheme";
NSString *const FXModelValidatorSet = @"set";
NSString *const FXModelValidatorOn = @"on";
NSString *const FXModelValidatorExcept = @"except";
NSString *const FXModelValidatorWhen = @"when";
#pragma clang diagnostic pop

@interface FXModelWrapper () <FXModelValidation>
@end

@implementation FXModelWrapper
@dynamic scenario;
@dynamic validators;
@dynamic attributes;
@dynamic activeValidators;
@dynamic hasErrors;
@dynamic errors;

#pragma mark - FXModelValidation protocol default implementation
-(NSArray *)rules {
	@throw [NSException exceptionWithName:@"FXModel" reason:[NSString stringWithFormat:@"Expected -rules to be implemented by %@", NSStringFromClass([self class])] userInfo:nil];
}

-(BOOL)beforeValidate {
	return YES;
}

-(void)afterValidate {

}

#pragma mark - FXModel protocol default implementation
-(NSDictionary *)scenarioList {
	NSMutableDictionary *scenarios = [NSMutableDictionary dictionaryWithDictionary:@{SCENARIO_DEFAULT : [NSMutableDictionary dictionary]}];
	for(FXModelValidator *validator in [self getValidators]) {
		for(NSString *scenario in validator.on) {
			scenarios[scenario] = [NSMutableDictionary dictionary];
		}

		for(NSString *scenario in validator.except) {
			scenarios[scenario] = [NSMutableDictionary dictionary];
		}
	}

	NSArray *names = [scenarios allKeys];
	for(FXModelValidator *validator in [self getValidators]) {
		if([validator.on count] == 0 && [validator.except count] == 0) {
			for(NSString *name in names) {
				for(NSString *attribute in validator.attributes) {
					scenarios[name][attribute] = @(YES);
				}
			}
		} else if([validator.on count] == 0) {
			for(NSString *name in names) {
				if(!([validator.except containsObject:name])) {
					for(NSString *attribute in validator.attributes) {
						scenarios[name][attribute] = @(YES);
					}
				}
			}
		} else {
			for(NSString *name in validator.on) {
				for(NSString *attribute in validator.attributes) {
					scenarios[name][attribute] = @(YES);
				}
			}
		}
	}

	NSMutableDictionary *result = [NSMutableDictionary dictionary];
	[scenarios enumerateKeysAndObjectsUsingBlock:^(NSString *scenario, NSDictionary *attributes, BOOL *stop) {
		if([attributes count] || [scenario isEqual:SCENARIO_DEFAULT])
			result[scenario] = [attributes allKeys];
	}];

	return result;
}

-(NSArray *)attributeList {
	@synchronized (self) {
		NSArray *attributes = (NSArray *)objc_getAssociatedObject(self, @selector(attributes));

		if(attributes)
			return attributes;

		//get FXModel properties
		NSMutableSet *ignoreProperties = [NSMutableSet set];
		unsigned int propertyCount;
		objc_property_t *propertyList = class_copyPropertyList([FXModelWrapper class], &propertyCount);
		for (unsigned int i = 0; i < propertyCount; i++) {
			objc_property_t property = propertyList[i];
			const char *propertyName = property_getName(property);
			[ignoreProperties addObject:@(propertyName)];
		}
		free(propertyList);

		//get self properties
		Class className = (([NSStringFromClass([self class]) containsString:@"-#FXModel#-"]) ? [self superclass] : [self class]);
		propertyList = class_copyPropertyList(className, &propertyCount);
		NSMutableSet *selfProperties = [NSMutableSet set];
		for (unsigned int i = 0; i < propertyCount; i++) {
			objc_property_t property = propertyList[i];
			const char *propName = property_getName(property);
			[selfProperties addObject:@(propName)];
		}

		free(propertyList);

		[selfProperties minusSet:ignoreProperties];
		attributes = [selfProperties allObjects];
		objc_setAssociatedObject(self, @selector(attributes), attributes, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
		return attributes;
	}
}

-(BOOL)validate {
	return [self validate:nil clearErrors:YES];
}

-(BOOL)validate:(NSArray *)attributes{
	return [self validate:attributes clearErrors:YES];
}

-(BOOL)validate:(NSArray *)attributes clearErrors:(BOOL)clearErrors {
	if(clearErrors)
		[self clearErrors:nil];

	if([self beforeValidate]) {
		NSDictionary *scenarios = [self scenarioList];
		NSString *scenario = [self getScenario];

		if(scenarios[scenario] == nil)
			@throw [NSException exceptionWithName:@"FXModel" reason:[NSString stringWithFormat:@"Unknown scenario: %@", scenario] userInfo:nil];

		if(attributes == nil)
			attributes = [self activeAttributes];

		for(FXModelValidator *validator in [self getActiveValidators])
			[validator validate:self attributes:attributes];

		[self afterValidate];

		return (![self hasErrors]);
	}

	return NO;
}

-(NSMutableArray *)getValidators {
	@synchronized (self) {
		NSMutableArray *validators = (NSMutableArray *)objc_getAssociatedObject(self, @selector(getValidators));

		if(validators)
			return validators;

		[self setValidators:[self createValidators]];
		return (NSMutableArray *)objc_getAssociatedObject(self, @selector(getValidators));
	}
}

-(void)setValidators:(NSMutableArray *)validators {
	[self willChangeValueForKey:@"validators"];
	[self willChangeValueForKey:@"activeValidators"];
	objc_setAssociatedObject(self, @selector(getValidators), [validators copy], OBJC_ASSOCIATION_COPY_NONATOMIC);
	[self didChangeValueForKey:@"validators"];
	[self didChangeValueForKey:@"activeValidators"];
}

-(NSArray *)getActiveValidators {
	return [self getActiveValidators:nil];
}

-(NSArray *)getActiveValidators:(NSString *)attribute {
	NSMutableArray *validators = [NSMutableArray array];
	NSString *scenario = [self getScenario];
	for(FXModelValidator *validator in [self getValidators]) {
		if([validator isActive:scenario] && (attribute == nil || [validator.attributes containsObject:attribute])) {
			[validators addObject:validator];
		}
	}

	return validators;
}

/**
* Creates validator objects based on the validation rules specified in [[rules()]].
* Unlike [[getValidators()]], each time this method is called, a new list of validators will be returned.
* @return validators
* @throws exception if any validation rule configuration is invalid
*/
-(NSMutableArray *)createValidators {
	NSArray *rules = [self rules];
	NSMutableArray *validators = [[NSMutableArray alloc] initWithCapacity:[rules count]];
	FXModelValidator *validator;

	for(id rule in rules) {
		if ([rule isKindOfClass:[FXModelValidator class]]) {
			validator = rule;
		} else {
			NSMutableDictionary *params;
			id attributes;
			id type;

			if ([rule isKindOfClass:[NSArray class]] && ([rule count] > 1)) {
				type = rule[1];
				attributes = rule[0];
				params = nil;
			} else if ([rule isKindOfClass:[NSDictionary class]] && rule[FXModelValidatorAttributes] && rule[FXModelValidatorType]) {
				type = rule[FXModelValidatorType];
				attributes = rule[FXModelValidatorAttributes];
				params = [(NSDictionary *)rule mutableCopy];
				[params removeObjectForKey:FXModelValidatorAttributes];
				[params removeObjectForKey:FXModelValidatorType];
			} else {
				@throw [NSException exceptionWithName:@"FXModel" reason:@"Invalid validation rule: a rule must specify both attribute names and validator type." userInfo:nil];
			}

			if([attributes isKindOfClass:[NSString class]])
				attributes = [attributes componentsSeparatedByString:@","];

			if(!([attributes isKindOfClass:[NSArray class]]))
				@throw [NSException exceptionWithName:@"FXModel" reason:@"Only NSArray or comma-separated NSString are supported as list of attributes." userInfo:nil];

			validator = [FXModelValidator createValidator:type
													model:self
											   attributes:attributes
												   params:params
			];
		}

		if(!(validator))
			@throw [NSException exceptionWithName:@"FXModel" reason:[NSString stringWithFormat:@"Can't create a validator for rule: %@", rule] userInfo:nil];

		[validators addObject:validator];
	}

	return validators;
}

-(BOOL)isAttributeRequired:(NSString *)attribute {
	NSAssert(attribute, @"You must provide an attribute to chech");
	for(FXModelValidator *validator in [self getActiveValidators:attribute]) {
		if([validator isKindOfClass:[FXModelRequiredValidator class]] && validator.when == nil) {
			return YES;
		}
	}

	return NO;
}

-(BOOL)isAttributeSafe:(NSString *)attribute {
	return [[self safeAttributes] containsObject:attribute];
}

-(BOOL)isAttributeActive:(NSString *)attribute {
	return [[self activeAttributes] containsObject:attribute];
}

-(BOOL)hasErrors {
	return [self hasErrors:nil];
}

-(BOOL)hasErrors:(NSString *)attribute {
	return (attribute
			? ([self getValidationErrors][attribute] != nil)
			: ([[self getValidationErrors] count] > 0)
	);
}

-(id)getErrors{
	return [self getErrors:nil];
}

-(id)getErrors:(NSString *)attribute {
	NSDictionary *errorsAll = [self getValidationErrors];
	NSDictionary *errorAttribute;

	if(attribute == nil)
		return ([errorsAll count] ? [errorsAll copy] : @{});

	if((errorAttribute = errorsAll[attribute]) && [errorAttribute count])
		return [errorAttribute copy];

	return @[];
}

-(void)addError:(NSString *)attribute message:(NSString *)message {
	[self willChangeValueForKey:@"errors"];
	[self willChangeValueForKey:@"hasErrors"];

	NSMutableDictionary *errors = [self getValidationErrors];

	if(errors[attribute] == nil)
		errors[attribute] = [[NSMutableArray alloc] init];

	[errors[attribute] addObject:message];

	[self didChangeValueForKey:@"errors"];
	[self didChangeValueForKey:@"hasErrors"];
}

-(void)clearErrors {
	[self clearErrors:nil];
}

-(void)clearErrors:(NSString *)attribute {
	if(attribute == nil) {
		if([[self getValidationErrors] count]) {
			[self willChangeValueForKey:@"errors"];
			[self willChangeValueForKey:@"hasErrors"];
			[[self getValidationErrors] removeAllObjects];
			[self didChangeValueForKey:@"errors"];
			[self didChangeValueForKey:@"hasErrors"];
		}
	} else if([self getValidationErrors][attribute]) {
		[self willChangeValueForKey:@"errors"];
		[self willChangeValueForKey:@"hasErrors"];
		[[self getValidationErrors] removeObjectForKey:attribute];
		[self didChangeValueForKey:@"errors"];
		[self didChangeValueForKey:@"hasErrors"];
	}
}

-(NSDictionary *)getAttributes {
	return [self getAttributes:nil except:nil];
}

-(NSDictionary *)getAttributes:(NSArray *)names except:(NSArray *)except {
	NSMutableDictionary *values = [NSMutableDictionary dictionary];
	if(names == nil)
		names = [self attributeList];

	if(except == nil)
		except = @[];

	for(NSString *name in names) {
		id value = [self valueForKey:name];
		values[name] = (value ? value : [NSNull null]);
	}

	for(NSString *name in except)
		[values removeObjectForKey:name];

	return values;
}

-(void)setAttributes:(NSDictionary *)values {
	[self setAttributes:values safeOnly:YES];
}

-(void)setAttributes:(NSDictionary *)values safeOnly:(BOOL)safeOnly {
	if(values) {
		NSArray *attributes = (safeOnly ? [self safeAttributes] : [self attributeList]);

		[values enumerateKeysAndObjectsUsingBlock:^(NSString *name, id value, BOOL *stop) {
			if([attributes containsObject:name]) {
				[self setValue:value forKey:name];
			} else if(safeOnly) {
				[self onUnsafeAttribute:name value:value];
			}
		}];
	}
}

-(void)onUnsafeAttribute:(NSString *)attribute value:(id)value {
#if DEBUG
	NSLog(@"Failed to set unsafe attribute '%@' in %@", attribute, [self class]);
#endif
}

-(NSString *)getScenario {
	NSString *scenario = (NSString *)objc_getAssociatedObject(self, @selector(getScenario));

	if(scenario == nil)
		objc_setAssociatedObject(self, @selector(getScenario), [SCENARIO_DEFAULT copy], OBJC_ASSOCIATION_COPY_NONATOMIC);

	return (NSString *)objc_getAssociatedObject(self, @selector(getScenario));
}

-(void)setScenario:(NSString *)scenario {
	if([[self getScenario] isEqual:scenario])
		return;

	[self willChangeValueForKey:@"scenario"];
	[self willChangeValueForKey:@"activeValidators"];
	objc_setAssociatedObject(self, @selector(getScenario), [scenario copy], OBJC_ASSOCIATION_COPY_NONATOMIC);
	[self didChangeValueForKey:@"scenario"];
	[self didChangeValueForKey:@"activeValidators"];

	FXModelObserver *observer;
	if ((observer = [self getUpdatesObserver]))
		[observer refresh];
}

-(NSArray *)safeAttributes {
	NSString *scenario = [self getScenario];
	NSDictionary *scenarios = [self scenarioList];

	if(scenarios[scenario] == nil)
		return @[];

	NSMutableArray *attributes = [NSMutableArray array];
	for(NSString *attribute in scenarios[scenario]) {
		if([attribute characterAtIndex:0] != '!') {
			[attributes addObject:attribute];
		}
	}

	return attributes;
}

-(NSArray *)activeAttributes {
	NSString *scenario = [self getScenario];
	NSDictionary *scenarios = [self scenarioList];

	if(scenarios[scenario] == nil)
		return @[];

	NSMutableArray *attributes = [scenarios[scenario] mutableCopy];
	for(NSUInteger i = 0; i < [attributes count]; i++) {
		if([attributes[i] characterAtIndex:0] == '!') {
			attributes[i] = [(NSString *)attributes[i] substringFromIndex:1];
		}
	}

	return attributes;

}

-(void)validateUpdates:(NSArray *)attributes except:(NSArray *)except {
	@synchronized (self) {
		FXModelObserver *observer = [self getUpdatesObserver];

		if(observer == nil) {
			observer = [[FXModelObserver alloc] initWithModel:self];
			objc_setAssociatedObject(self, @selector(getUpdatesObserver), observer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
		}

		[observer observe:attributes except:except];
	}
}

-(void)validateUpdates:(NSArray *)attributes {
	[self validateUpdates:attributes except:nil];
}

-(void)validateUpdates {
	[self validateUpdates:nil except:nil];
}

#pragma mark - FXModel private methods
-(NSMutableDictionary *)getValidationErrors {
	NSMutableDictionary *errors = (NSMutableDictionary *)objc_getAssociatedObject(self, @selector(getValidationErrors));

	if(errors)
		return errors;

	errors = [[NSMutableDictionary alloc] init];
	objc_setAssociatedObject(self, @selector(getValidationErrors), errors , OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	return errors;
}

-(FXModelObserver *)getUpdatesObserver {
	return (FXModelObserver *)objc_getAssociatedObject(self, @selector(getUpdatesObserver));
}
@end