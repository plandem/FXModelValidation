#import "CommonHelper.h"

SpecBegin(FXModelNumberValidator)
		__block FXModelNumberValidator *validator;
		__block NSError *error;

		describe(@"validateValue", ^{
			beforeEach(^{
				validator = [[FXModelNumberValidator alloc] init];
			});

			describe(@"check type", ^{
				it(@"-NSNumber is valid type", ^{
					error = [validator validateValue:@(100)];
					expect(error).to.beNil();
				});

				it(@"-NSString is invalid type", ^{
					error = [validator validateValue:@"string"];
					expect(error).notTo.beNil();
				});
			});

			describe(@"check min value", ^{
				beforeEach(^{
					validator.min = @100;
				});

				it(@"-101 is greater than 100", ^{
					error = [validator validateValue:@(101)];
					expect(error).to.beNil();
				});

				it(@"-50 is less than 100", ^{
					error = [validator validateValue:@50];
					expect(error).notTo.beNil();
				});
			});

			describe(@"check max value", ^{
				beforeEach(^{
					validator.max = @100;
				});

				it(@"-50 is less than 100", ^{
					error = [validator validateValue:@(50)];
					expect(error).to.beNil();
				});

				it(@"-101 is greater than 100", ^{
					error = [validator validateValue:@101];
					expect(error).notTo.beNil();
				});
			});

			afterEach(^{
				validator = nil;
			});
		});
SpecEnd

