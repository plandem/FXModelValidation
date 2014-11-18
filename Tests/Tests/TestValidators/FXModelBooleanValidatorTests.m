#import "CommonHelper.h"

SpecBegin(FXModelBooleanValidator)
		__block FXModelBooleanValidator *validator;
		__block NSError *error;

		describe(@"settings", ^{
			beforeEach(^{
				validator = [[FXModelBooleanValidator alloc] init];
			});

			it(@"-default trueValue should be YES", ^{
				expect(validator.trueValue).to.equal(@YES);
			});

			it(@"-default trueValue should be NO", ^{
				expect(validator.falseValue).to.equal(@NO);
			});

			it(@"-trueValue should be 100", ^{
				validator.trueValue = @100;
				expect(validator.trueValue).to.equal(@100);
			});

			it(@"-falseValue should be 0", ^{
				validator.falseValue = @0;
				expect(validator.falseValue).to.equal(@0);
			});

			afterEach(^{
				validator = nil;
				error = nil;
			});
		});

		describe(@"validateValue", ^{
			beforeEach(^{
				validator = [[FXModelBooleanValidator alloc] init];
			});

			it(@"-should have be invalid", ^{
				error = [validator validateValue:@"niceandsimple@example.com"];
				expect(error).notTo.beNil();
				error = [validator validateValue:@100];
				expect(error).notTo.beNil();
				validator.trueValue = @101;
				error = [validator validateValue:@100];
				expect(error).notTo.beNil();
			});

			it(@"-should be valid", ^{
				error = [validator validateValue:@YES];
				expect(error).to.beNil();
				error = [validator validateValue:@NO];
				expect(error).to.beNil();

				validator.trueValue = @101;
				error = [validator validateValue:@100];
				expect(error).to.beNil();

				validator.falseValue = @"niceandsimple@example.com";
				error = [validator validateValue:@100];
				expect(error).to.beNil();
			});

			afterEach(^{
				validator = nil;
				error = nil;
			});
		});
SpecEnd

