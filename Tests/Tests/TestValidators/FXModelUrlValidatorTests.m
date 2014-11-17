#import "CommonHelper.h"

SpecBegin(FXModelUrlValidator)
		__block FXModelUrlValidator *validator;
		__block NSError *error;

		describe(@"validateValue", ^{
			beforeEach(^{
				validator = [[FXModelUrlValidator alloc] init];
			});

			describe(@"check type", ^{
				it(@"-NSNumber is invalid type", ^{
					error = [validator validateValue:@(100)];
					expect(error).notTo.beNil();
				});
			});

			describe(@"defaultScheme", ^{
				describe(@"is not set", ^{
					beforeEach(^{
						validator.defaultScheme = nil;
						validator.enableIDN = NO;
					});

					it(@"-url with scheme is valid", ^{
						error = [validator validateValue:@"http://gmail.com"];
						expect(error).to.beNil();
					});

					it(@"-url without scheme is invalid", ^{
						error = [validator validateValue:@"gmail.com"];
						expect(error).notTo.beNil();
					});
				});

				describe(@"is set", ^{
					beforeEach(^{
						validator.defaultScheme = @"https";
						validator.enableIDN = NO;
					});

					it(@"-url with scheme is valid", ^{
						error = [validator validateValue:@"http://gmail.com"];
						expect(error).to.beNil();
					});

					it(@"-url without scheme is valid", ^{
						error = [validator validateValue:@"gmail.com"];
						expect(error).to.beNil();
					});
				});
			});

			describe(@"pattern", ^{
				describe(@"does not use validSchemes", ^{
					beforeEach(^{
						validator.defaultScheme = nil;
						validator.enableIDN = NO;
						validator.pattern = @"^ftp:\\/\\/(([A-Z0-9][A-Z0-9_-]*)(\\.[A-Z0-9][A-Z0-9_-]*)+)";
					});

					it(@"-url with differ scheme is invalid", ^{
						error = [validator validateValue:@"http://gmail.com"];
						expect(error).notTo.beNil();
					});

					it(@"-url with same scheme is valid", ^{
						error = [validator validateValue:@"ftp://gmail.com"];
						expect(error).to.beNil();
					});
				});

				describe(@"does use validSchemes", ^{
					beforeEach(^{
						validator.defaultScheme = nil;
						validator.enableIDN = NO;
						validator.validSchemes = @[@"ftp"];
					});

					it(@"-url with differ scheme is invalid", ^{
						error = [validator validateValue:@"http://gmail.com"];
						expect(error).notTo.beNil();
					});

					it(@"-url with same scheme is valid", ^{
						error = [validator validateValue:@"ftp://gmail.com"];
						expect(error).to.beNil();
					});
				});
			});

			describe(@"enableIDN", ^{
				describe(@"disabled", ^{
					beforeEach(^{
						validator.enableIDN = NO;
					});

					it(@"-UTF8 urls is invalid", ^{
						error = [validator validateValue:@"http://яндекс.рф"];
						expect(error).notTo.beNil();
					});

					it(@"-english url is valid", ^{
						error = [validator validateValue:@"http://gmail.com"];
						expect(error).to.beNil();
					});
				});

				describe(@"enabled", ^{
					beforeEach(^{
						validator.enableIDN = YES;
					});

					it(@"-UTF8 urls is valid", ^{
						error = [validator validateValue:@"http://яндекс.рф"];
						expect(error).to.beNil();
					});

					it(@"-english url is valid", ^{
						error = [validator validateValue:@"http://gmail.com"];
						expect(error).to.beNil();
					});
				});
			});

			afterEach(^{
				validator = nil;
			});
		});
SpecEnd

