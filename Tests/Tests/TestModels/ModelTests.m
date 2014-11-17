#import "CommonHelper.h"

SpecBegin(Form)
		__block Form *form;
		return;
		describe(@"validationInit", ^{
			beforeEach(^{
				form = [[Form alloc] init];
			});

			it(@"zzz", ^{
				[form validationInitWithRules:@[
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

//				NSLog(@"scenario=%@", form.scenario);
				NSLog(@"scenarioList=%@", form.scenarioList);
			});

			afterEach(^{
				form = nil;
			});
		});

SpecEnd

