//
// Created by Andrey on 15/11/14.
// Copyright (c) 2014 Andrey Gayvoronsky. All rights reserved.
//

#import "FXModelValidation.h"
#import "FXModelObserver.h"

@interface FXModelObserver()
@property(nonatomic, strong) id model;
@property(nonatomic, strong) NSMutableSet *attributes;
@property(nonatomic, strong) NSSet *except;
@property(nonatomic, assign) BOOL manual;
@end

@implementation FXModelObserver
-(instancetype)initWithModel:(id<FXModel>)model {
	if((self = [self init])) {
		_model = model;
		_except = [NSSet set];
		_attributes = [NSMutableSet set];
	}

	return self;
}

-(void)observe:(NSArray *)attributes except:(NSArray *)except {
	@synchronized (self) {
		//stop to observe?
		if (attributes && [attributes count] == 0) {
			[self removeObserver];
			return;
		}

		_manual = (attributes != nil);
		_except = (except ? [NSSet setWithArray:except] : [NSSet set]);
		self.attributes = [NSMutableSet setWithArray:(_manual ? attributes : [_model activeAttributes])];
	}
}

-(void)setAttributes:(NSMutableSet *)attributes {
	NSMutableSet *delete = [NSMutableSet setWithSet:_attributes];
	[delete minusSet:attributes];
	[delete unionSet:_except];

	//remove outdated
	for(NSString *name in delete) {
		if([_attributes containsObject:name])
			[_model removeObserver:self forKeyPath:name];
	}

	//add new
	[attributes minusSet:_except];
	for(NSString *name in attributes) {
		if(!([_attributes containsObject:name]))
			[_model addObserver:self forKeyPath:name options:NSKeyValueObservingOptionNew context:nil];
	}

	_attributes = attributes;
}

-(void)refresh {
	if(!(_manual))
		self.attributes = [NSMutableSet setWithArray:[_model activeAttributes]];
}

-(void)dealloc {
	[self removeObserver];
}

-(void)removeObserver {
	for(NSString *name in _attributes)
		[_model removeObserver:self forKeyPath:name];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	[(id<FXModel>)_model clearErrors:keyPath];
	[(id<FXModel>)_model validate:@[keyPath]];
}
@end