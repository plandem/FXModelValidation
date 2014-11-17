#import "CommonHelper.h"

SpecBegin(FXModelBooleanValidator)
		__block FXModelBooleanValidator *validator;
		__block NSError *error;
		return;

		describe(@"validateValue", ^{
			beforeEach(^{
				validator = [[FXModelBooleanValidator alloc] initWithAttributes:nil params:@{

				}];
			});

			it(@"", ^{
			});

			afterEach(^{
				validator = nil;
				error = nil;
			});
		});
SpecEnd

