#import "CommonHelper.h"

SpecBegin(FXModelDefaultValueValidator)
		__block FXModelDefaultValueValidator *validator;
		__block Form *form;

		describe(@"validateValue", ^{
			beforeEach(^{
				validator = [[FXModelDefaultValueValidator alloc] init];
				form = [[Form alloc] init];
				[form validationInitWithRules:@[
						@{
								FXModelValidatorAttributes : @"valueBoolean",
								FXModelValidatorType : @"required",
						},
						@{
								FXModelValidatorAttributes : @"valueInteger,valueFloat",
								FXModelValidatorType : @"required",
								FXModelValidatorOn : @[@"create"],
						},
						@{
								FXModelValidatorAttributes : @"valueString",
								FXModelValidatorType : @"trim",
								FXModelValidatorOn : @[@"update"],
						},
				] force:YES];
			});

			it(@"-valueString should not be set to default", ^{
				form.valueString = @"current value";
				validator.value = @"new value";
				[validator validate:form attribute:@"valueString"];
				expect(form.valueString).to.equal(@"current value");
			});

			it(@"-valueString should be set to default via assignment", ^{
				validator.value = @"new value";
				[validator validate:form attribute:@"valueString"];
				expect(form.valueString).to.equal(@"new value");
			});

			it(@"-valueString should be set to default via block", ^{
				expect(form.valueString).to.beNil();

				validator.value = ^id(id model, NSString *attribute) {
					return @"block value";
				};

				[validator validate:form attribute:@"valueString"];
				expect(form.valueString).to.equal(@"block value");
			});

			it(@"-valueString should be set to default via method", ^{
				expect(form.valueString).to.beNil();
				validator.value = @"default_valueString";
				[validator validate:form attribute:@"valueString"];
				expect(form.valueString).to.equal(@"method value");
			});

			afterEach(^{
				validator = nil;
				form = nil;
			});
		});
SpecEnd