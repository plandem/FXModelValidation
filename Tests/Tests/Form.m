//
// Created by Andrey on 13/11/14.
// Copyright (c) 2014 Andrey Gayvoronsky. All rights reserved.
//

#import "Form.h"

@implementation Form
-(NSArray *)rules {
	@throw [NSException exceptionWithName:@"FXModel" reason:@"rules must be implemented" userInfo:nil];
}

-(NSDictionary *)scenarioList {
	return @{
			@"default": @[@"valueBoolean"],
			@"create": @[@"valueInteger", @"valueFloat", @"valueBoolean"],
			@"update": @[@"!valueString", @"valueBoolean"],
	};
};

@end