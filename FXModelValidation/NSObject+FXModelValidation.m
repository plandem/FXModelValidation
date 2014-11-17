//
// Created by Andrey on 10/11/14.
// Copyright (c) 2014 Andrey Gayvoronsky. All rights reserved.
//

#import "FXModel.h"
#import <objc/runtime.h>
static NSMutableArray *dynamicSubclasses;
@implementation NSObject (FXModelValidation)

//Attach methods from source to class
+(void)validationAttachClass:(Class)source {
	unsigned int methodCount;
	Method *methods = class_copyMethodList(source, &methodCount);

	for (int i = 0; i < methodCount; i++)
		class_addMethod([self class], method_getName(methods[i]), method_getImplementation(methods[i]), method_getTypeEncoding(methods[i]));

	free(methods);
}

//Replace implementation of rules
+(void)validationAttachRules:(NSArray *)rules {
	rules = [rules copy];
	SEL rulesSelector = NSSelectorFromString(@"rules");
	Method originalMethod = class_getClassMethod([self class], rulesSelector);
	IMP rulesImp = imp_implementationWithBlock(^NSArray*(id self) {
		return rules;
	});

	class_replaceMethod([self class], rulesSelector, rulesImp, method_getTypeEncoding(originalMethod));
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