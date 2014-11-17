#import "CommonHelper.h"

SpecBegin(FXModelSafeValidator)
		__block FXModelSafeValidator *validator;
		__block NSError *error;
		return;

		describe(@"validateValue", ^{
			beforeEach(^{
				validator = [[FXModelSafeValidator alloc] initWithAttributes:nil params:@{

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

