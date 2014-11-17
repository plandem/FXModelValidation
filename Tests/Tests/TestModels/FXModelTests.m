#import "CommonHelper.h"
#import <objc/runtime.h>
@interface TestObject1 : NSObject
@end;

@interface TestObject2 : NSObject
@end;

@implementation TestObject1
@end;

@implementation TestObject2
@end;

SpecBegin(FXFormModel)
		__block Form *form;
		__block TestObject1 *object1;
		__block TestObject2 *object2;

		describe(@"instance", ^{
			beforeEach(^{
				form = [[Form alloc] init];
			});

			describe(@"validationInit", ^{
				describe(@"not called", ^{
					it(@"-should not have FXModel methods", ^{
						expect(form).notTo.respondTo(@selector(addError:message:));
						expect(form).notTo.respondTo(@selector(hasErrors));
						expect(form).notTo.respondTo(@selector(hasErrors:));
						expect(form).notTo.respondTo(@selector(clearErrors));
						expect(form).notTo.respondTo(@selector(clearErrors:));
						expect(form).notTo.respondTo(@selector(getErrors:));
						expect(form).notTo.respondTo(@selector(getErrors));
						expect(form).notTo.respondTo(@selector(validate:clearErrors:));
						expect(form).notTo.respondTo(@selector(validate:));
						expect(form).notTo.respondTo(@selector(validate));
					});
				});

				describe(@"called", ^{
					it(@"-should attach once and have all FXModel methods", ^{
						expect([form validationInit]).to.equal(YES);
						expect(form).respondTo(@selector(addError:message:));
						expect(form).respondTo(@selector(hasErrors));
						expect(form).respondTo(@selector(hasErrors:));
						expect(form).respondTo(@selector(clearErrors));
						expect(form).respondTo(@selector(clearErrors:));
						expect(form).respondTo(@selector(getErrors:));
						expect(form).respondTo(@selector(getErrors));
						expect(form).respondTo(@selector(validate:clearErrors:));
						expect(form).respondTo(@selector(validate:));
						expect(form).respondTo(@selector(validate));
						expect([form validationInit]).to.equal(NO);
						expect([form validationInitWithRules:@[]]).to.equal(NO);
						expect([[form class] validationInit]).to.equal(NO);
						expect([[form class] validationInitWithRules:@[]]).to.equal(NO);
						expect(^{ [form performSelector:@selector(rules)]; }).to.raiseAny();
					});
				});
			});

			describe(@"validationInitWithRules", ^{
				beforeEach(^{
					object1 = [[TestObject1 alloc] init];
				});

				describe(@"not called", ^{
					it(@"-it should not responds to selector rules", ^{
						expect(object1).notTo.respondTo(@selector(rules));
					});
				});
				describe(@"called", ^{
					it(@"-it should responds to selector rules and return array with 3 elements", ^{
						expect([object1 validationInitWithRules:@[@1, @2, @3]]).to.equal(YES);
						expect([object1 validationInitWithRules:@[@1]]).to.equal(NO);
						expect(object1).respondTo(@selector(rules));
						expect(^{ [object1 performSelector:@selector(rules)];}).notTo.raiseAny();
						expect([object1 performSelector:@selector(rules)]).to.equal(@[@1, @2, @3]);
					});
				});

				afterEach(^{
					object1 = nil;
				});
			});

			describe(@"validationInitWithRules and force to override rules", ^{
				it(@"-it should responds to selector rules and return array with 3 elements, after that return array with 5 elements", ^{
					expect([form validationInitWithRules:@[@1, @2, @3]]).to.equal(YES);
					expect([form performSelector:@selector(rules)]).to.equal(@[@1, @2, @3]);
					[form validationInitWithRules:@[@1, @2, @3, @4, @5] force:YES];
					expect([form performSelector:@selector(rules)]).to.equal(@[@1, @2, @3, @4, @5]);
				});
			});

			describe(@"validationInitWithRules and doesnot force to override rules", ^{
				it(@"-it should responds to selector rules and return array with 3 elements, after that return same array", ^{
					expect([form validationInitWithRules:@[@1, @2, @3]]).to.equal(YES);
					expect([form performSelector:@selector(rules)]).to.equal(@[@1, @2, @3]);
					[form validationInitWithRules:@[@1, @2, @3, @4, @5] force:NO];
					expect([form performSelector:@selector(rules)]).to.equal(@[@1, @2, @3]);
				});
			});

			afterEach(^{
				form = nil;
			});
		});

		describe(@"class", ^{
			beforeEach(^{
				object1 = [[TestObject1 alloc] init];
				object2 = [[TestObject2 alloc] init];
			});

			describe(@"validationInit", ^{
				describe(@"called", ^{
					it(@"-should attach once and have all FXModel methods", ^{
						expect([[object1 class] validationInit]).to.equal(YES);
						expect(object1).respondTo(@selector(addError:message:));
						expect(object1).respondTo(@selector(hasErrors));
						expect(object1).respondTo(@selector(hasErrors:));
						expect(object1).respondTo(@selector(clearErrors));
						expect(object1).respondTo(@selector(clearErrors:));
						expect(object1).respondTo(@selector(getErrors:));
						expect(object1).respondTo(@selector(getErrors));
						expect(object1).respondTo(@selector(validate:clearErrors:));
						expect(object1).respondTo(@selector(validate:));
						expect(object1).respondTo(@selector(validate));
						expect([[object1 class] validationInit]).to.equal(NO);
						expect([[object1 class] validationInitWithRules:@[]]).to.equal(NO);
						expect([object1 validationInit]).to.equal(NO);
						expect([object1 validationInitWithRules:@[]]).to.equal(NO);
					});
				});
			});

			describe(@"validationInitWithRules", ^{
				describe(@"called", ^{
					it(@"-should attach once and have all FXModel methods", ^{
						expect([[object2 class] validationInitWithRules:@[]]).to.equal(YES);
						expect(object2).respondTo(@selector(addError:message:));
						expect(object2).respondTo(@selector(hasErrors));
						expect(object2).respondTo(@selector(hasErrors:));
						expect(object2).respondTo(@selector(clearErrors));
						expect(object2).respondTo(@selector(clearErrors:));
						expect(object2).respondTo(@selector(getErrors:));
						expect(object2).respondTo(@selector(getErrors));
						expect(object2).respondTo(@selector(validate:clearErrors:));
						expect(object2).respondTo(@selector(validate:));
						expect(object2).respondTo(@selector(validate));
						expect([[object2 class] validationInit]).to.equal(NO);
						expect([[object2 class] validationInitWithRules:@[]]).to.equal(NO);
						expect([object2 validationInit]).to.equal(NO);
						expect([object2 validationInitWithRules:@[]]).to.equal(NO);
					});
				});
			});

			describe(@"validationInitWithRules and force to override rules", ^{
				it(@"-it should responds to selector rules and raise error, after that return array with 5 elements", ^{
					expect([[object1 class] validationInitWithRules:@[@1, @2, @3]]).to.equal(NO); //already attached to NSObject at previous test
					expect(object2).respondTo(@selector(rules));
					expect(^{ [object1 performSelector:@selector(rules)]; }).to.raiseAny();
					[[object1 class] validationInitWithRules:@[@1, @2, @3, @4, @5] force:YES];
					expect([object1 performSelector:@selector(rules)]).to.equal(@[@1, @2, @3, @4, @5]);
				});
			});
		});

		describe(@"errors methods", ^{
			beforeEach(^{
				form = [[Form alloc] init];
				[form validationInit];
			});

			it(@"-it shoud not have any errors", ^{
				expect([form getErrors]).to.equal(@{});
				expect([form getErrors:@"valueString"]).to.equal(@[]);
				expect([form hasErrors]).to.equal(NO);
				expect([form hasErrors:@"valueString"]).to.equal(NO);
			});

			it(@"-it shoud have some manually added errors", ^{
				[form addError:@"valueString" message:@"Manual error 1"];
				expect([[form getErrors] count]).to.equal(1);
				expect([form getErrors:@"valueString"]).to.equal(@[@"Manual error 1"]);
				expect([form hasErrors]).to.equal(YES);
				expect([form hasErrors:@"valueString"]).to.equal(YES);
				expect([form hasErrors:@"valueInteger"]).to.equal(NO);
				[form addError:@"valueString" message:@"Manual error 2"];
				expect([form getErrors:@"valueString"]).to.equal(@[@"Manual error 1", @"Manual error 2"]);
				[form addError:@"valueInteger" message:@"Manual error 3"];
				expect([form getErrors:@"valueInteger"]).to.equal(@[@"Manual error 3"]);
				expect([[form getErrors] count]).to.equal(2);
			});

			it(@"-it shoud have 3 errors and after clear for attribute have 2 errors and after clearing all have no error", ^{
				[form addError:@"valueString" message:@"Manual error 1"];
				[form addError:@"valueInteger" message:@"Manual error 2"];
				[form addError:@"valueFloat" message:@"Manual error 3"];
				expect([[form getErrors] count]).to.equal(3);
				[form clearErrors:@"valueInteger"];
				expect([[form getErrors] count]).to.equal(2);
				[form clearErrors];
				expect([[form getErrors] count]).to.equal(0);
				expect([form hasErrors]).to.equal(NO);
				expect([form getErrors]).to.equal(@{});
			});

			afterEach(^{
				form = nil;
			});
		});

		describe(@"scenario related", ^{
			beforeEach(^{
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

			it(@"-should have DEFAULT active scenario", ^{
				expect(form.scenario).to.equal(@"default");
			});

			it(@"-should have totally 3 scenarioList", ^{
				expect([[form scenarioList] count]).to.equal(3);
			});

			it(@"-should have totally only 1 item at default scenario", ^{
				expect([[form scenarioList][@"default"] count]).to.equal(1);
				expect([form scenarioList][@"default"]).contain(@"valueBoolean");
			});

			it(@"-should have totally only 3 item at create scenario", ^{
				expect([[form scenarioList][@"create"] count]).to.equal(3);
				expect([form scenarioList][@"create"]).contain(@"valueBoolean");
				expect([form scenarioList][@"create"]).contain(@"valueFloat");
				expect([form scenarioList][@"create"]).contain(@"valueInteger");
			});

			it(@"-should have totally only 2 item at update scenario", ^{
				expect([form.scenarioList[@"update"] count]).to.equal(2);
				expect(form.scenarioList[@"update"]).contain(@"valueBoolean");
				expect(form.scenarioList[@"update"]).contain(@"!valueString");
			});

			it(@"-should have 1 required attribute on default scenario, 1 safe attribute and 1 active", ^{
				expect([form isAttributeRequired:@"valueBoolean"]).to.equal(YES);
				expect([form isAttributeRequired:@"valueInteger"]).to.equal(NO);
				expect([form isAttributeRequired:@"valueFloat"]).to.equal(NO);
				expect([form isAttributeRequired:@"valueString"]).to.equal(NO);

				expect([form isAttributeActive:@"valueBoolean"]).to.equal(YES);
				expect([form isAttributeActive:@"valueInteger"]).to.equal(NO);
				expect([form isAttributeActive:@"valueFloat"]).to.equal(NO);
				expect([form isAttributeActive:@"valueString"]).to.equal(NO);

				expect([form isAttributeSafe:@"valueBoolean"]).to.equal(YES);
				expect([form isAttributeSafe:@"valueInteger"]).to.equal(NO);
				expect([form isAttributeSafe:@"valueFloat"]).to.equal(NO);
				expect([form isAttributeSafe:@"valueString"]).to.equal(NO);

				expect([[form safeAttributes] count]).to.equal(1);
				expect([form safeAttributes]).contain(@"valueBoolean");

				expect([[form activeAttributes] count]).to.equal(1);
				expect([form activeAttributes]).contain(@"valueBoolean");
			});

			it(@"-should have 3 required attribute on create scenario, 3 active and 3 safe", ^{
				form.scenario = @"create";
				expect([form isAttributeRequired:@"valueBoolean"]).to.equal(YES);
				expect([form isAttributeRequired:@"valueInteger"]).to.equal(YES);
				expect([form isAttributeRequired:@"valueFloat"]).to.equal(YES);
				expect([form isAttributeRequired:@"valueString"]).to.equal(NO);

				expect([form isAttributeActive:@"valueBoolean"]).to.equal(YES);
				expect([form isAttributeActive:@"valueInteger"]).to.equal(YES);
				expect([form isAttributeActive:@"valueFloat"]).to.equal(YES);
				expect([form isAttributeActive:@"valueString"]).to.equal(NO);

				expect([form isAttributeSafe:@"valueBoolean"]).to.equal(YES);
				expect([form isAttributeSafe:@"valueInteger"]).to.equal(YES);
				expect([form isAttributeSafe:@"valueFloat"]).to.equal(YES);
				expect([form isAttributeSafe:@"valueString"]).to.equal(NO);

				expect([[form safeAttributes] count]).to.equal(3);
				expect([form safeAttributes]).contain(@"valueBoolean");
				expect([form safeAttributes]).contain(@"valueInteger");
				expect([form safeAttributes]).contain(@"valueFloat");

				expect([[form activeAttributes] count]).to.equal(3);
				expect([form activeAttributes]).contain(@"valueBoolean");
				expect([form activeAttributes]).contain(@"valueInteger");
				expect([form activeAttributes]).contain(@"valueFloat");
			});

			it(@"-should have 1 required attribute on update scenario, 2 active and 1 safe", ^{
				form.scenario = @"update";
				expect([form isAttributeRequired:@"valueBoolean"]).to.equal(YES);
				expect([form isAttributeRequired:@"valueInteger"]).to.equal(NO);
				expect([form isAttributeRequired:@"valueFloat"]).to.equal(NO);
				expect([form isAttributeRequired:@"valueString"]).to.equal(NO);

				expect([form isAttributeActive:@"valueBoolean"]).to.equal(YES);
				expect([form isAttributeActive:@"valueInteger"]).to.equal(NO);
				expect([form isAttributeActive:@"valueFloat"]).to.equal(NO);
				expect([form isAttributeActive:@"valueString"]).to.equal(YES);

				expect([form isAttributeSafe:@"valueBoolean"]).to.equal(YES);
				expect([form isAttributeSafe:@"valueInteger"]).to.equal(NO);
				expect([form isAttributeSafe:@"valueFloat"]).to.equal(NO);
				expect([form isAttributeSafe:@"valueString"]).to.equal(NO);

				expect([[form safeAttributes] count]).to.equal(1);
				expect([form safeAttributes]).contain(@"valueBoolean");

				expect([[form activeAttributes] count]).to.equal(2);
				expect([form activeAttributes]).contain(@"valueBoolean");
				expect([form activeAttributes]).contain(@"valueString");
			});

			it(@"-should have 8 attributes totally via attributeList", ^{
				expect([[form attributeList] count]).to.equal(8);
				expect([form attributeList]).contain(@"valueBoolean");
				expect([form attributeList]).contain(@"valueInteger");
				expect([form attributeList]).contain(@"valueFloat");
				expect([form attributeList]).contain(@"valueString");
				expect([form attributeList]).contain(@"valueArray");
				expect([form attributeList]).contain(@"valueDictionary");
				expect([form attributeList]).contain(@"valueSet");
				expect([form attributeList]).contain(@"valueNumber");
			});

			it(@"-should have valueString updated after direct manipulation at default scenario", ^{
				expect(form.valueString).to.beNil();
				form.valueString = @"test string";
				expect(form.valueString ).to.equal(@"test string");
			});

			it(@"-should have only valueBoolean updated after mass attributes set at default scenario", ^{
				expect(form.valueString).to.beNil();
				expect(form.valueBoolean).to.equal(NO);

				form.attributes = @{
						@"valueString": @"new test string",
						@"valueBoolean": @(YES),
				};

				expect(form.valueString).to.beNil();
				expect(form.valueBoolean).to.equal(YES);
			});

			it(@"-should have no any updates at mass attributes set for unsafe valueString and valueFloat at update scenario", ^{
			    form.scenario = @"update";
				expect(form.valueString).to.beNil();
				expect(form.valueFloat).to.equal(0);
				form.attributes = @{
						@"valueString": @"new test string",
						@"valueFloat": @(1),
				};

				expect(form.valueString).to.beNil();
				expect(form.valueFloat).to.equal(0);
			});

			it(@"-should have valueBoolean and valueString updated after mass attributes set at default scenario and safeOnly off", ^{
				expect(form.valueString).to.beNil();
				expect(form.valueBoolean).to.equal(NO);

				[form setAttributes: @{
						@"valueString": @"new test string",
						@"valueBoolean": @(YES),
				} safeOnly: NO];

				expect(form.valueString).to.equal(@"new test string");
				expect(form.valueBoolean).to.equal(YES);
			});

			it(@"-should return all atributes()", ^{
				NSDictionary *result = [form getAttributes];
				expect(result).notTo.beNil();
				expect([result count]).to.equal(8);
				expect(result).to.equal(@{
						@"valueArray": [NSNull null],
						@"valueBoolean": @(NO),
						@"valueDictionary": [NSNull null],
						@"valueFloat": @(0),
						@"valueInteger": @(0),
						@"valueNumber": [NSNull null],
						@"valueSet": [NSNull null],
						@"valueString": [NSNull null],
				});
			});

			it(@"-should return valueBoolean and valueString atributes only", ^{
				NSDictionary *result = [form getAttributes:@[@"valueString", @"valueBoolean"] except:nil];
				expect(result).notTo.beNil();
				expect([result count]).to.equal(2);
				expect(result).to.equal(@{
						@"valueBoolean" : @(NO),
						@"valueString" : [NSNull null],
				});
			});

			it(@"-should return all attributes except valueBoolean and valueString", ^{
				NSDictionary *result = [form getAttributes:nil except:@[@"valueString", @"valueBoolean"]];
				expect(result).notTo.beNil();
				expect([result count]).to.equal(6);
				expect(result).to.equal(@{
						@"valueArray": [NSNull null],
						@"valueDictionary": [NSNull null],
						@"valueFloat": @(0),
						@"valueInteger": @(0),
						@"valueNumber": [NSNull null],
						@"valueSet": [NSNull null],
				});
			});

			it(@"-should return valueString attribute only", ^{
				NSDictionary *result = [form getAttributes:@[@"valueString", @"valueBoolean"] except:@[@"valueBoolean"]];
				expect(result).notTo.beNil();
				expect([result count]).to.equal(1);
				expect(result).to.equal(@{
						@"valueString" : [NSNull null],
				});
			});

			it(@"-should return all validators and totally 3", ^{
				NSArray *result = [form getValidators];
				FXModelValidator *validator;
				expect(result).notTo.beNil();
				expect([result count]).to.equal(3);
				expect(result[0]).to.beKindOf([FXModelRequiredValidator class]);
				expect(result[1]).to.beKindOf([FXModelRequiredValidator class]);
				expect(result[2]).to.beKindOf([FXModelTrimFilter class]);

				validator = result[0];
				expect(validator.on).to.equal(@[]);
				expect(validator.attributes).notTo.beNil();
				expect([validator.attributes count]).to.equal(1);
				expect(validator.attributes).to.equal(@[@"valueBoolean"]);

				validator = result[1];
				expect(validator.on).to.equal(@[@"create"]);
				expect(validator.attributes).notTo.beNil();
				expect([validator.attributes count]).to.equal(2);
				expect(validator.attributes).contain(@"valueInteger");
				expect(validator.attributes).contain(@"valueFloat");

				validator = result[2];
				expect(validator.on).to.equal(@[@"update"]);
				expect(validator.attributes).notTo.beNil();
				expect([validator.attributes count]).to.equal(1);
				expect(validator.attributes).contain(@"valueString");
			});

			it(@"-should return all active validators and totally 1", ^{
				NSArray *result = [form getActiveValidators];
				expect(result).notTo.beNil();
				expect([result count]).to.equal(1);
				expect(result[0]).to.beKindOf([FXModelRequiredValidator class]);
			});

			it(@"-should return 1 active validator for valueBoolean and 0 active validator for valueString", ^{
				NSArray *result = [form getActiveValidators:@"valueBoolean"];
				expect(result).notTo.beNil();
				expect([result count]).to.equal(1);
				expect(result[0]).to.beKindOf([FXModelRequiredValidator class]);

				result = [form getActiveValidators:@"valueString"];
				expect(result).notTo.beNil();
				expect([result count]).to.equal(0);
			});

			it(@"-validate sould be success", ^{
				expect([form validate]).to.equal(YES);
				expect([form getErrors]).to.equal(@{});
			});

			it(@"-validate should be success and valueString should be trimmed at scenario update", ^{
				form.valueString = @"    test string    ";
				form.scenario = @"update";
				expect([form validate]).to.equal(YES);
				expect([form getErrors]).to.equal(@{});
				expect(form.valueString).to.equal(@"test string");
				[form validate];
				[form addError:@"valueString" message:@"!!!!!"];
			});

			it(@"-validating on updates should clear errors for validating attributes", ^{
				expect([form hasErrors]).to.equal(NO);
				[form addError:@"valueBoolean" message:@"!!!!!"];
				expect([form hasErrors]).to.equal(YES);
				form.valueBoolean = NO;
				[form validateUpdates];
				form.valueBoolean = YES;
				expect([form hasErrors]).to.equal(NO);
			});

			it(@"-validating on updates with exception for valueString should not validate it", ^{
				form.scenario = @"update";
				[form validateUpdates:nil except:@[@"valueString"]];
				form.valueString = @"    test string    ";
				expect(form.valueString).to.equal(@"    test string    ");
				form.valueBoolean = YES;
				expect(form.valueString).to.equal(@"    test string    ");
			});

			it(@"-validating on updates without exception for valueString should change it via filter validator", ^{
				form.scenario = @"update";
				[form validateUpdates:nil except:@[@"valueString"]];
				form.valueString = @"    test string    ";
				expect(form.valueString).to.equal(@"    test string    ");
				form.valueBoolean = YES;
				expect(form.valueString).to.equal(@"    test string    ");

				[form validateUpdates]; //remove previous exceptions
				form.valueBoolean = NO;
				expect(form.valueString).to.equal(@"    test string    ");

				form.valueString = @"    test string    ";
				expect(form.valueString).to.equal(@"test string");

				[form validateUpdates:nil except:@[@"valueString"]];
				form.valueString = @"    test string    ";
				expect(form.valueString).to.equal(@"    test string    ");

				[form validateUpdates]; //remove previous exceptions
				form.scenario = @"create";
				form.valueString = @"    test string    ";
				expect(form.valueString).to.equal(@"    test string    ");

				[form validateUpdates:@[@"valueString"]];
				form.valueString = @"    test string    "; //differ scenario
				expect(form.valueString).to.equal(@"    test string    ");
				form.scenario = @"update";
				expect(form.valueString).to.equal(@"    test string    ");//attributes was set manually, so news scenario and refresh for observer is not working

				form.valueString = @"    test string    ";
				expect(form.valueString).to.equal(@"test string"); //but observer is still working for updates of values
			});

			afterEach(^{
				form = nil;
			});
		});
SpecEnd

