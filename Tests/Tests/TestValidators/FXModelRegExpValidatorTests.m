#import "CommonHelper.h"

SpecBegin(FXModelRegExpValidator)
		__block FXModelRegExpValidator *validator;
		__block NSError *error;

		describe(@"pattern", ^{
			it(@"-empty pattern is invalid", ^{
				validator = [[FXModelRegExpValidator alloc] init];
				expect(^{ [validator validateValue:@"spam@spam.it"]; }).to.raiseAny();
			});

			it(@"-NSString pattern is valid", ^{
				validator = [[FXModelRegExpValidator alloc] init];
				expect(^{ validator.pattern = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"; }).notTo.raiseAny();
			});

			it(@"-NSRegularExpression pattern is valid", ^{
				validator = [[FXModelRegExpValidator alloc] init];
				expect(^{ validator.pattern = [[NSRegularExpression alloc] init]; }).notTo.raiseAny();
			});
		});

		describe(@"validateValue", ^{
			beforeEach(^{
				validator = [[FXModelRegExpValidator alloc] init];
				validator.pattern = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}";
			});

			describe(@"not", ^{
				describe(@"disabled", ^{
					beforeEach(^{
						validator.not = NO;
					});

					it(@"-pattern matched is valid", ^{
						error = [validator validateValue:@"spam@spam.it"];
						expect(error).to.beNil();
					});

					it(@"-pattern not matched is invalid", ^{
						error = [validator validateValue:@"wtf is it?"];
						expect(error).toNot.beNil();
					});
				});

				describe(@"enabled", ^{
					beforeEach(^{
						validator.not = YES;
					});

					it(@"-pattern matched is invalid", ^{
						error = [validator validateValue:@"spam@spam.it"];
						expect(error).notTo.beNil();
					});

					it(@"-pattern not matched is valid", ^{
						error = [validator validateValue:@"wtf is it?"];
						expect(error).to.beNil();
					});
				});
			});

			afterEach(^{
				validator = nil;
			});
		});
SpecEnd