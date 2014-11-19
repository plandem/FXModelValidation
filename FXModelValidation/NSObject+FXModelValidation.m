//
// Created by Andrey on 10/11/14.
// Copyright (c) 2014 Andrey Gayvoronsky. All rights reserved.
//

#import "FXModel.h"
#import "NSObject+FXModelValidation.h"
#import <objc/runtime.h>

#ifndef FXMODELVALIDATION_FXFORMS
#define FXMODELVALIDATION_FXFORMS 1
#endif

//FXForm specific
static NSString *FXFormName_protocol = @"FXForm";
static NSString *FXFormName_excluded = @"excludedFields";
static NSString *FXFormName_replaced = @"-#FXModel#-excludedFields";
/////
static NSMutableArray *dynamicSubclasses;
static NSMutableArray *ignoreProperties;
@implementation NSObject (FXModelValidation)

//Attach methods from source to class
+(void)validationAttachClass:(Class)source {
	unsigned int methodCount;
	Method *methods = class_copyMethodList(source, &methodCount);

	for (int i = 0; i < methodCount; i++)
		class_addMethod([self class], method_getName(methods[i]), method_getImplementation(methods[i]), method_getTypeEncoding(methods[i]));

	free(methods);

#if FXMODELVALIDATION_FXFORMS
	//check for FXForms
	Protocol *_protocol = NSProtocolFromString(FXFormName_protocol);
	if([[self class] conformsToProtocol:_protocol]) {
		//get FXModel properties
		static dispatch_once_t onceToken;
		dispatch_once(&onceToken, ^{
			ignoreProperties = [NSMutableArray array];
			unsigned int propertyCount;
			objc_property_t *propertyList = class_copyPropertyList([FXModelWrapper class], &propertyCount);
			for (unsigned int i = 0; i < propertyCount; i++) {
				objc_property_t property = propertyList[i];
				const char *propertyName = property_getName(property);
				[ignoreProperties addObject:[NSString stringWithFormat:@"%s", propertyName]];
			}
			free(propertyList);
		});

		SEL excludedSEL = NSSelectorFromString(FXFormName_excluded);
		SEL replacedSEL = NSSelectorFromString(FXFormName_replaced);
		IMP originalIMP = [[self class] validationReplaceProtocolMethod:_protocol
															   selector:excludedSEL
															   required:NO
															   instance:YES
																  block:^NSArray*(id _self) {
                                                                      NSMutableArray *ignored = [ignoreProperties mutableCopy];
                                                                      
																	  if([_self respondsToSelector:replacedSEL]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
																		  NSArray *excluded = [_self performSelector:replacedSEL];
#pragma clang diagnostic pop
																		  if(excluded)
																			  [ignored addObjectsFromArray:excluded];
																	  }

																	  return ignored;
																  }
		];

		if(originalIMP) {
			Method originalMethod = class_getInstanceMethod([self class], excludedSEL);
			class_addMethod([self class], replacedSEL, originalIMP, method_getTypeEncoding(originalMethod));
		}
	}
#endif
}

+(IMP)validationReplaceProtocolMethod:(Protocol *)aProtocol selector:(SEL)aSelector required:(BOOL)aRequired instance:(BOOL)aInstance block:(id)aBlock {
	Method originalMethod = class_getInstanceMethod([self class], aSelector);
	IMP replaceIMP = imp_implementationWithBlock(aBlock);

	if(originalMethod) {
		return class_replaceMethod([self class], aSelector, replaceIMP, method_getTypeEncoding(originalMethod));
	} else {
		struct objc_method_description description = protocol_getMethodDescription(aProtocol, aSelector, aRequired, aInstance);
		class_addMethod([self class], aSelector, replaceIMP, description.types);
		return nil;
	}
}

//Replace implementation of rules
+(void)validationAttachRules:(NSArray *)rules {
	rules = [rules copy];

	[[self class] validationReplaceProtocolMethod:@protocol(FXModelValidation)
										 selector:NSSelectorFromString(@"rules")
										 required:YES
										 instance:YES
											block:^NSArray*(id self) {
												return rules;
											}];
}

//Check if attachment is possible
+(BOOL)isValidationAttachmentPossible {
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		dynamicSubclasses = [NSMutableArray array];
	});

	@synchronized (dynamicSubclasses) {
		NSValue *classPtr = [NSValue valueWithPointer:((__bridge const void*)[self class])];
		return (!([dynamicSubclasses containsObject:classPtr]));
	}
}

//Attach FXModel to class
+(BOOL)validationInit {
	@synchronized (dynamicSubclasses) {
		if(([[self class] isValidationAttachmentPossible])) {
			NSValue *classPtr = [NSValue valueWithPointer:((__bridge const void *) [self class])];
			[dynamicSubclasses addObject:classPtr];
			[self validationAttachClass:[FXModelWrapper class]];
			return YES;
		}

		return NO;
	}
}

//Attach FXModel to instance
-(BOOL)validationInit {
	@synchronized (dynamicSubclasses) {
		if (([[self class] isValidationAttachmentPossible])) {
			NSString *subclassName = [NSString stringWithFormat:@"%@-#FXModel#-%@", NSStringFromClass([self class]), [[NSUUID UUID] UUIDString]];
			Class subclass = objc_allocateClassPair([self class], [subclassName UTF8String], 0);
			[subclass validationAttachClass:[self class]];
			if ([subclass validationInit]) {
				objc_registerClassPair(subclass);
				object_setClass(self, subclass);
				return YES;
			}
		}

		return NO;
	}
}

//Attach FXModel to class and replace implementation of rules
+(BOOL)validationInitWithRules:(NSArray *)rules {
	if([[self class] validationInit]) {
		[[self class] validationAttachRules:rules];
		return YES;
	}

	return NO;
}

//Attach FXModel to class and force to override implementation for rules
+(void)validationInitWithRules:(NSArray *)rules force:(BOOL)force {
	BOOL success = [[self class] validationInit];
	if(force || success)
		[[self class] validationAttachRules:rules];
}

//Attach FXModel to instance and replace implementation of rules
-(BOOL)validationInitWithRules:(NSArray *)rules {
	if([self validationInit]) {
		[[self class] validationAttachRules:rules];
		return YES;
	}

	return NO;
}

//Attach FXModel to instance and force to override implementation for rules
-(void)validationInitWithRules:(NSArray *)rules force:(BOOL)force{
	BOOL success = [self validationInit];
	if(force || success)
		[[self class] validationAttachRules:rules];
}

@end