#import "CommonHelper.h"

SpecBegin(FXModelValidator)
		__block FXModelValidator *validator;
		__block NSError *error;

		NSDictionary *emptyValues = @{
				@"null":[NSNull null],
				@"string":[NSMutableArray array],
				@"array":@[],
				@"dictionary":@{},
				@"set":[NSSet set],
				@"orderedSet":[NSOrderedSet orderedSet]
		};

		[emptyValues[@"string"] addObject:[[NSClassFromString(@"NSString") alloc] init]];
		__block NSDictionary *values =  @{
				@"string":@"value",
				@"array":@[@"value"],
				@"dictionary":@{@"key":@"value"},
				@"set": [NSSet setWithArray:@[@"value"]],
				@"orderedSet": [NSOrderedSet orderedSetWithArray:@[@"value"]],
		};

		describe(@"isEmpty", ^{
			beforeEach(^{
				validator = [[FXModelValidator alloc] init];
			});

			describe(@"check for nil", ^{
				it(@"-value is nil", ^{
					expect([validator isEmpty:nil]).to.equal(YES);
				});

				it(@"-value is NSNull", ^{
					expect([validator isEmpty:emptyValues[@"null"]]).to.equal(YES);
				});
			});

			describe(@"check for empty string", ^{
				it(@"-value is empty string", ^{
					expect([validator isEmpty:^id { return (id)emptyValues[@"string"][0]; }()]).to.equal(YES);
				});

				it(@"-value is not empty string", ^{
					expect([validator isEmpty:values[@"string"]]).to.equal(NO);
				});
			});

			describe(@"check for empty array", ^{
				it(@"-value is empty array", ^{
					expect([validator isEmpty:emptyValues[@"array"]]).to.equal(YES);
				});

				it(@"-value is not empty array", ^{
					expect([validator isEmpty:values[@"array"]]).to.equal(NO);
				});
			});

			describe(@"check for empty dictionary", ^{
				it(@"-value is empty dictionary", ^{
					expect([validator isEmpty:emptyValues[@"dictionary"]]).to.equal(YES);
				});

				it(@"-value is not empty dictionary", ^{
					expect([validator isEmpty:values[@"dictionary"]]).to.equal(NO);
				});
			});

			describe(@"check for empty set", ^{
				it(@"-value is empty set", ^{
					expect([validator isEmpty:emptyValues[@"set"]]).to.equal(YES);
				});

				it(@"-value is not empty set", ^{
					expect([validator isEmpty:values[@"set"]]).to.equal(NO);
				});
			});

			describe(@"check for empty ordered set", ^{
				it(@"-value is empty ordered set", ^{
					expect([validator isEmpty:emptyValues[@"orderedSet"]]).to.equal(YES);
				});

				it(@"-value is not empty ordered set", ^{
					expect([validator isEmpty:values[@"orderedSet"]]).to.equal(NO);
				});
			});

			afterEach(^{
				validator = nil;
			});
		});
SpecEnd

