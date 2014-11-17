//
// Created by Andrey on 13/11/14.
// Copyright (c) 2014 Andrey Gayvoronsky. All rights reserved.
//

#import "FXModelTrimFilter.h"

@implementation FXModelTrimFilter

-(instancetype)init {
	if((self = [super init]))  {
		self.skipOnArray = YES;

		__weak FXModelTrimFilter *weakSelf = self;
		self.filter = ^id(NSString *value, NSDictionary *params) {
			return [value stringByTrimmingCharactersInSet: weakSelf.set];
		};
	}

	return self;
}

-(NSCharacterSet *)set {
	if(_set == nil)
		_set = [NSCharacterSet whitespaceAndNewlineCharacterSet];

	return _set;
}
@end