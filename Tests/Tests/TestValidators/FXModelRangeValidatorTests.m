#import "CommonHelper.h"

SpecBegin(FXModelRangeValidator)
		__block FXModelRangeValidator *validator;
		__block NSError *error;

		describe(@"validateValue", ^{
			beforeEach(^{
				validator = [[FXModelRangeValidator alloc] init];
				validator.range = @[@1, @2, @5, @10, @"name"];
			});

			describe(@"range", ^{
				it(@"-empty is invalid", ^{
					validator.range = nil;
					error = [validator validateValue:@"100"];
					expect(error).notTo.beNil();
				});

				it(@"-non NSArray is invalid", ^{
					validator = [[FXModelRangeValidator alloc] initWithAttributes:nil params:@{
							@"range": @100,
					}];

					error = [validator validateValue:@"100"];
					expect(error).notTo.beNil();
				});
			});

			describe(@"not", ^{
				describe(@"disabled", ^{
					beforeEach(^{
						validator.not = NO;
					});

					it(@"-number in range is valid", ^{
						error = [validator validateValue:@1];
						expect(error).to.beNil();
					});

					it(@"-string in range is valid", ^{
						error = [validator validateValue:@"name"];
						expect(error).to.beNil();
					});

					it(@"-number not in range is invalid", ^{
						error = [validator validateValue:@-1];
						expect(error).notTo.beNil();
					});
				});

				describe(@"enabled", ^{
					beforeEach(^{
						validator.not = YES;
					});

					it(@"-number value in range is invalid", ^{
						error = [validator validateValue:@1];
						expect(error).toNot.beNil();
					});

					it(@"-string value in range is invalid", ^{
						error = [validator validateValue:@"name"];
						expect(error).toNot.beNil();
					});

					it(@"-value not in range is valid", ^{
						error = [validator validateValue:@-1];
						expect(error).to.beNil();
					});
				});
			});

			describe(@"allowArray", ^{
				describe(@"disabled", ^{
					beforeEach(^{
						validator.allowArray = NO;
					});

					it(@"-array with values is invalid", ^{
						error = [validator validateValue:@[@1, @"name"]];
						expect(error).notTo.beNil();
					});
				});

				describe(@"enabled", ^{
					beforeEach(^{
						validator.allowArray = YES;
					});

					it(@"-all values in range is valid", ^{
						error = [validator validateValue:@[@1, @"name"]];
						expect(error).to.beNil();
					});

					it(@"-non all values in range is invalid", ^{
						error = [validator validateValue:@[@1, @"name", @-1]];
						expect(error).notTo.beNil();
					});
				});
			});

			afterEach(^{
				validator = nil;
			});
		});
SpecEnd