#import "CommonHelper.h"

SpecBegin(FXModelStringValidator)
		__block FXModelStringValidator *validator;
		__block NSError *error;

		describe(@"length", ^{
			beforeEach(^{
				validator = [[FXModelStringValidator alloc] init];
			});

			it(@"-min and max should not be set, but length must be NSNumber and be 100", ^{
				validator.min = 1;
				validator.length = @100;
				expect(validator.min).to.equal(-1);
				expect(validator.max).to.equal(-1);
				expect(validator.length).to.beKindOf([NSNumber class]);
				expect([validator.length integerValue]).to.equal(100);
			});

			it(@"-min should be 100, but length should not be set", ^{
				validator.min = 1;
				validator.length = @[@100];
				expect(validator.min).to.equal(100);
				expect(validator.length).to.beNil();
			});

			it(@"-min should be 100 and max shoud be 500, but length should not be set", ^{
				validator.min = 1;
				validator.max = 1;
				validator.length = @[@100, @500];
				expect(validator.min).to.equal(100);
				expect(validator.max).to.equal(500);
				expect(validator.length).to.beNil();
			});
		});

		describe(@"validateValue", ^{
			beforeEach(^{
				validator = [[FXModelStringValidator alloc] init];
			});

			describe(@"check type", ^{
				it(@"-NSNumber is invalid type", ^{
					error = [validator validateValue:@(100)];
					expect(error).notTo.beNil();
				});

				it(@"-NSString is valid type", ^{
					error = [validator validateValue:@"string"];
					expect(error).to.beNil();
				});
			});

			describe(@"check min length", ^{
				beforeEach(^{
					validator.min = 3;
				});

				it(@"-string of length 3 is valid", ^{
					error = [validator validateValue:@"123"];
					expect(error).to.beNil();
				});

				it(@"-string of length 2 is invalid", ^{
					error = [validator validateValue:@"12"];
					expect(error).notTo.beNil();
				});
			});

			describe(@"check max length", ^{
				beforeEach(^{
					validator.max = 3;
				});

				it(@"-string of length 2 is valid", ^{
					error = [validator validateValue:@"12"];
					expect(error).to.beNil();
				});

				it(@"-string of length 4 is invalid", ^{
					error = [validator validateValue:@"1234"];
					expect(error).notTo.beNil();
				});
			});

			describe(@"check equal length", ^{
				beforeEach(^{
					validator.length = @5;
				});

				it(@"-string of length 2 is invalid", ^{
					error = [validator validateValue:@"12"];
					expect(error).notTo.beNil();
				});

				it(@"-string of length 5 is invalid", ^{
					error = [validator validateValue:@"12345"];
					expect(error).to.beNil();
				});
			});

			afterEach(^{
				validator = nil;
			});
		});
SpecEnd

