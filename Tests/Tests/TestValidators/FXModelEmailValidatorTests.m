#import "CommonHelper.h"

SpecBegin(FXModelEmailValidator)
		__block FXModelEmailValidator *validator;
		__block NSError *error;

		describe(@"validateValue", ^{
			beforeEach(^{
				validator = [[FXModelEmailValidator alloc] init];
			});

			describe(@"check email format", ^{
				beforeEach(^{
					validator.checkDNS = NO;
					validator.enableIDN = NO;
				});

				it(@"-emails should be valid", ^{
					error = [validator validateValue:@"niceandsimple@example.com"];
					expect(error).to.beNil();
					error = [validator validateValue:@"very.common@example.com"];
					expect(error).to.beNil();
					error = [validator validateValue:@"a.little.lengthy.but.fine@dept.example.com"];
					expect(error).to.beNil();
					error = [validator validateValue:@"disposable.style.email.with+symbol@example.com"];
					expect(error).to.beNil();
					error = [validator validateValue:@"other.email-with-dash@example.com"];
					expect(error).to.beNil();
					error = [validator validateValue:@"user@localserver"];
					expect(error).to.beNil();
				});

				it(@"-emails should be invalid", ^{
					error = [validator validateValue:@"Abc.example.com"];
					expect(error).notTo.beNil();
					error = [validator validateValue:@"A@b@c@example.com"];
					expect(error).notTo.beNil();
					error = [validator validateValue:@"a\"b(c)d,e:f;g<h>i[j\\k]l@example.com"];
					expect(error).notTo.beNil();
					error = [validator validateValue:@"just\"not\"right@example.com"];
					expect(error).notTo.beNil();
					error = [validator validateValue:@"this is\"not\\allowed@example.com"];
					expect(error).notTo.beNil();
					error = [validator validateValue:@"this\\ still\"not\\allowed@example.com"];
					expect(error).notTo.beNil();
					error = [validator validateValue:@"john..doe@example.com"];
					expect(error).notTo.beNil();
					error = [validator validateValue:@"john.doe@example..com"];
					expect(error).notTo.beNil();

					//email with name is not supported
					error = [validator validateValue:@"John Doe <niceandsimple@example.com>"];
					expect(error).notTo.beNil();
				});
			});

			describe(@"enableIDN", ^{
				describe(@"disabled", ^{
					beforeEach(^{
						validator.checkDNS = NO;
						validator.enableIDN = NO;
					});

					it(@"-english domain should be considered as valid", ^{
						error = [validator validateValue:@"abc@unknown.domain.example"];
						expect(error).to.beNil();
					});

					it(@"-UTF8 domain should be considered as invalid", ^{
						error = [validator validateValue:@"имя@домен.субдомен"];
						expect(error).notTo.beNil();
					});
				});

				describe(@"enabled", ^{
					beforeEach(^{
						validator.checkDNS = NO;
						validator.enableIDN = YES;
					});

					it(@"-english domain should be considered as valid", ^{
						error = [validator validateValue:@"abc@unknown.domain.example"];
						expect(error).to.beNil();
					});

					it(@"-UTF8 domain should be considered as valid", ^{
						error = [validator validateValue:@"имя@домен.субдомен"];
						expect(error).to.beNil();
					});
				});
			});

			describe(@"checkDNS", ^{
				describe(@"disabled", ^{
					beforeEach(^{
						validator.checkDNS = NO;
						validator.enableIDN = NO;
					});

					it(@"-fake domain should be considered as valid", ^{
						error = [validator validateValue:@"abc@unknown.domain.example"];
						expect(error).to.beNil();
					});

					it(@"-real domain should be considered as valid", ^{
						error = [validator validateValue:@"abc@gmail.com"];
						expect(error).to.beNil();
					});
				});

				describe(@"enabled", ^{
					beforeEach(^{
						validator.checkDNS = YES;
						validator.enableIDN = NO;
					});

					it(@"-fake domain should be considered as invalid", ^{
						error = [validator validateValue:@"abc@unknown.domain.example"];
						expect(error).notTo.beNil();
					});

					it(@"-real domain should be considered as valid", ^{
						error = [validator validateValue:@"abc@gmail.com"];
						expect(error).to.beNil();
					});
				});
			});

			describe(@"enableIDN and checkDNS", ^{
				describe(@"disabled", ^{
					beforeEach(^{
						validator.checkDNS = NO;
						validator.enableIDN = NO;
					});

					it(@"-fake UTF8 domain should be considered as invalid", ^{
						error = [validator validateValue:@"имя@домен.субдомен"];
						expect(error).notTo.beNil();
					});

					it(@"-real UTF8 domain should be considered as invalid", ^{
						error = [validator validateValue:@"почта@яндекс.рф"];
						expect(error).notTo.beNil();
					});
				});

				describe(@"enabled", ^{
					beforeEach(^{
						validator.checkDNS = YES;
						validator.enableIDN = YES;
					});

					it(@"-fake UTF8 domain should be considered as invalid", ^{
						error = [validator validateValue:@"имя@домен.субдомен"];
						expect(error).notTo.beNil();
					});

					it(@"-real UTF8 domain should be considered as valid", ^{
						error = [validator validateValue:@"почта@яндекс.рф"];
						expect(error).to.beNil();
					});
				});
			});

			afterEach(^{
				validator = nil;
			});
		});
SpecEnd

