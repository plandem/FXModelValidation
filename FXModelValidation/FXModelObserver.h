//
// Created by Andrey on 15/11/14.
// Copyright (c) 2014 Andrey Gayvoronsky. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol FXModel;

@interface FXModelObserver : NSObject
-(instancetype)initWithModel:(id<FXModel>)model;
-(void)observe:(NSArray *)attributes except:(NSArray *)except;
-(void)refresh;
@end