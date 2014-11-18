#import "CommonHelper.h"

SpecBegin(FXModelFilterValidator)
		__block Form *form;

		describe(@"filter", ^{
			beforeEach(^{
				form = [[Form alloc] init];
			});

			it(@"-unknown filter should raise error", ^{
				[form validationInitWithRules:@[
						@{
								FXModelValidatorAttributes : @"valueString",
								FXModelValidatorType : @"filter",
								FXModelValidatorFilter : @"unknown",
						},
				] force:YES];

				form.scenario = @"update";
				form.valueString = @"test string";
				expect(^{ [form validate]; }).to.raiseAny();
			});

			it(@"-inline filter should trim valueString", ^{
				[form validationInitWithRules:@[
						@{
								FXModelValidatorAttributes : @"valueString",
								FXModelValidatorType : @"filter",
								FXModelValidatorFilter :^id(NSString *value, NSDictionary *params) {
									return [value stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
								},
						},
				] force:YES];

				form.scenario = @"update";
				form.valueString = @"   test string   ";
				expect(form.valueString).to.equal(@"   test string   ");
				form.validate;
				expect(form.valueString).to.equal(@"test string");
			});

			it(@"-inline method filter should update valueString", ^{
				[form validationInitWithRules:@[
						@{
								FXModelValidatorAttributes : @"valueString",
								FXModelValidatorType : @"filter",
								FXModelValidatorFilter : @"filter_valueString",
						},
				] force:YES];

				form.scenario = @"update";
				form.valueString = @"   test string   ";
				expect(form.valueString).to.equal(@"   test string   ");
				form.validate;
				expect(form.valueString).to.equal(@"method filtered string");
			});

			afterEach(^{
				form = nil;
			});
		});
SpecEnd