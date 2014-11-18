//
// Created by Andrey on 10/11/14.
// Copyright (c) 2014 Andrey Gayvoronsky. All rights reserved.
//
#import <Foundation/Foundation.h>

//known properties for all built-in validators/filters
#pragma clang diagnostic push
#pragma ide diagnostic ignored "OCUnusedGlobalDeclarationInspection"
FOUNDATION_EXPORT NSString *const FXModelValidatorAttributes;
FOUNDATION_EXPORT NSString *const FXModelValidatorType;
FOUNDATION_EXPORT NSString *const FXModelValidatorOn;
FOUNDATION_EXPORT NSString *const FXModelValidatorExcept;
FOUNDATION_EXPORT NSString *const FXModelValidatorWhen;
FOUNDATION_EXPORT NSString *const FXModelValidatorSkipOnError;
FOUNDATION_EXPORT NSString *const FXModelValidatorSkipOnEmpty;
FOUNDATION_EXPORT NSString *const FXModelValidatorMessage;
FOUNDATION_EXPORT NSString *const FXModelValidatorIsEmpty;
FOUNDATION_EXPORT NSString *const FXModelValidatorAction;
FOUNDATION_EXPORT NSString *const FXModelValidatorTrueValue;
FOUNDATION_EXPORT NSString *const FXModelValidatorFalseValue;
FOUNDATION_EXPORT NSString *const FXModelValidatorCompareAttribute;
FOUNDATION_EXPORT NSString *const FXModelValidatorCompareValue;
FOUNDATION_EXPORT NSString *const FXModelValidatorOperator;
FOUNDATION_EXPORT NSString *const FXModelValidatorValue;
FOUNDATION_EXPORT NSString *const FXModelValidatorCheckDNS;
FOUNDATION_EXPORT NSString *const FXModelValidatorEnableIDN;
FOUNDATION_EXPORT NSString *const FXModelValidatorFilter;
FOUNDATION_EXPORT NSString *const FXModelValidatorSkipOnArray;
FOUNDATION_EXPORT NSString *const FXModelValidatorTooBig;
FOUNDATION_EXPORT NSString *const FXModelValidatorTooSmall;
FOUNDATION_EXPORT NSString *const FXModelValidatorMin;
FOUNDATION_EXPORT NSString *const FXModelValidatorMax;
FOUNDATION_EXPORT NSString *const FXModelValidatorRange;
FOUNDATION_EXPORT NSString *const FXModelValidatorAllowArray;
FOUNDATION_EXPORT NSString *const FXModelValidatorNot;
FOUNDATION_EXPORT NSString *const FXModelValidatorPattern;
FOUNDATION_EXPORT NSString *const FXModelValidatorRequiredValue;
FOUNDATION_EXPORT NSString *const FXModelValidatorLength;
FOUNDATION_EXPORT NSString *const FXModelValidatorTooShort;
FOUNDATION_EXPORT NSString *const FXModelValidatorTooLong;
FOUNDATION_EXPORT NSString *const FXModelValidatorNotEqual;
FOUNDATION_EXPORT NSString *const FXModelValidatorValidSchemes;
FOUNDATION_EXPORT NSString *const FXModelValidatorDefaultScheme;
FOUNDATION_EXPORT NSString *const FXModelValidatorSet;
#pragma clang diagnostic pop

@protocol FXModel <NSObject>
@optional
@property(nonatomic, copy, getter=getScenario) NSString *scenario;
@property(nonatomic, copy, getter=getValidators) NSMutableArray *validators;
@property(nonatomic, weak, getter=getAttributes) NSDictionary *attributes;
@property(nonatomic, readonly, getter=getActiveValidators) NSArray *activeValidators;
@property(nonatomic, readonly, getter=getErrors) id errors;
@property(nonatomic, readonly, getter=hasErrors) BOOL hasErrors;

/**
* Returns a list of scenarios and the corresponding active attributes.
* An active attribute is one that is subject to validation in the current scenario.
* The returned array should be in the following format:
*
* ~~~
* @{
*     @"scenario1": @[@"attribute11", @"attribute12", ...],
*     @"scenario2": @[@"attribute21", @"attribute22", ...],
*     ...
* }
* ~~~
*
* By default, an active attribute is considered safe and can be massively assigned.
* If an attribute should NOT be massively assigned (thus considered unsafe),
* please prefix the attribute with an exclamation character (e.g. @"!rank").
*
* The default implementation of this method will return all scenarios found in the [[rules()]]
* declaration. A special scenario named [[SCENARIO_DEFAULT]] will contain all attributes
* found in the [[rules()]]. Each scenario will be associated with the attributes that
* are being validated by the validation rules that apply to the scenario.
*
* @return a list of scenarios and the corresponding active attributes.
*/
-(NSDictionary *)scenarioList;

/**
* Returns the list of attribute names.
* By default, this method returns all properties of the class.
* You may override this method to change the default behavior.
* @return array list of attribute names.
*/
-(NSArray *)attributeList;

/**
* Performs the data validation.
*
* This method executes the validation rules applicable to the current [[scenario]].
* The following criteria are used to determine whether a rule is currently applicable:
*
* - the rule must be associated with the attributes relevant to the current scenario;
* - the rules must be effective for the current scenario.
*
* This method will call [[beforeValidate()]] and [[afterValidate()]] before and
* after the actual validation, respectively. If [[beforeValidate()]] returns NO,
* the validation will be cancelled and [[afterValidate()]] will not be called.
*
* Errors found during the validation can be retrieved via [[getErrors()]].
*
* @param attributes list of attribute names that should be validated.
* If this parameter is nil, it means any attribute listed in the applicable
* validation rules should be validated.
* @param clearErrors whether to call [[clearErrors()]] before performing validation
* @return whether the validation is successful without any error.
* @throws exception if the current scenario is unknown.
*/
-(BOOL)validate:(NSArray *)attributes clearErrors:(BOOL)clearErrors;

/**
* Performs the data validation with clearErrors = YES
* @see validate:cleaErrors
*/
-(BOOL)validate:(NSArray *)attributes;

/**
* Performs the data validation with attributes = nil and clearErrors = YES
* @see validate:cleaErrors
*/
-(BOOL)validate;

/**
* Perform validation for attributes on changes.
* @param attributes list of attribute names that must be observed for changes and perform validation. Use nil if to validate all active attributes for current scenario of model.
* @param except list of attribute names that must not be observed for changes. Use nil to have no exceptions.
*/
-(void)validateUpdates:(NSArray *)attributes except:(NSArray *)except;

/**
* @see validateUpdates:except:
*/
-(void)validateUpdates:(NSArray *)attributes;

/**
* @see validateUpdates:except:
*/
-(void)validateUpdates;

/**
* Returns all the validators declared in [[rules()]].
*
* This method differs from [[getActiveValidators()]] in that the latter
* only returns the validators applicable to the current [[scenario]].
*
* Because this method returns an NSMutableArray object, you may
* manipulate it by inserting or removing validators,
* @return all the validators declared in the model.
*/
-(NSMutableArray *)getValidators;

/**
* Returns the validators applicable to the current [[scenario]].
* @param  attribute the name of the attribute whose applicable validators should be returned.
* If this is nil, the validators for ALL attributes in the model will be returned.
* @return the validators applicable to the current [[scenario]].
*/
-(NSArray *)getActiveValidators:(NSString *)attribute;

/**
* Returns the validators for ALL attributes in the model.
* @see getActiveValidators:
*/
-(NSArray *)getActiveValidators;

/**
* Returns a value indicating whether the attribute is required.
* This is determined by checking if the attribute is associated with a
* [FXModelRequiredValidator] validation rule in the current [[scenario]].
*
* Note that when the validator has a conditional validation applied using
* FXModelValidatorWhen this method will return
* "NO" regardless of the FXModelValidatorWhen condition because it may be called be
* before the model is loaded with data.
*
* @param attribute the name of attribute name
* @return whether the attribute is required
*/
-(BOOL)isAttributeRequired:(NSString *)attribute;

/**
* Returns a value indicating whether the attribute is safe for massive assignments.
* @param attribute the name of attribute
* @return whether the attribute is safe for massive assignments
* @see safeAttributes
*/
-(BOOL)isAttributeSafe:(NSString *)attribute;

/**
* Returns a value indicating whether the attribute is active in the current scenario.
* @param  attribute the name of attribute
* @return whether the attribute is active in the current scenario
* @see activeAttributes
*/
-(BOOL)isAttributeActive:(NSString *)attribute;

/**
* Returns a value indicating whether there is any validation error.
* @param attribute the name of attribute. Use nil to check all attributes.
* @return whether there is any error.
*/
-(BOOL)hasErrors:(NSString *)attribute;

/**
* @see hasErrors:
*/
-(BOOL)hasErrors;

/**
* Returns the errors for all attribute or a single attribute.
* @param attribute the name of attribute. Use nil to retrieve errors for all attributes.
* @property array An array of errors for all attributes. Empty array is returned if no error.
* The result is a two-dimensional array. See [[getErrors()]] for detailed description.
* @return errors for all attributes or the specified attribute. Empty dictionary or array is returned if no error.
* Note that when returning errors for all attributes, the result is a dictionary, like the following:
*
* ~~~
* @{
*     @"username": @[
*         @"Username is required.",
*         @"Username must contain only word characters.",
*     ],
*     @"email": @[
*         @"Email address is invalid.",
*     ]
* }
* ~~~
*/
-(id)getErrors:(NSString *)attribute;

/**
* @see getErrors:
*/
-(id)getErrors;

/**
* Adds a new error to the specified attribute.
* @param attribute the name of attribute
* @param message new error message
*/
-(void)addError:(NSString *)attribute message:(NSString *)message;

/**
* Removes errors for all attributes or a single attribute.
* @param attribute attribute name. Use nil to remove errors for all attribute.
*/
-(void)clearErrors:(NSString *)attribute;

/**
* @see clearErrors:
*/
-(void)clearErrors;

/**
* Returns attribute values.
* @param names list of attributes whose value needs to be returned.
* Defaults to nil, meaning all attributes listed in [[attributeList]] will be returned.
* If it is an array, only the attributes in the array will be returned.
* @param except list of attributes whose value should NOT be returned.
* @return attribute values (@{ name: value, ... }).
*/
-(NSDictionary *)getAttributes:(NSArray *)names except:(NSArray *)except;

/**
* @see getAttributes:except:
*/
-(NSDictionary *)getAttributes;

/**
* Sets the attribute values in a massive way.
* @param values attribute values (@{ name: value, ....}) to be assigned to the model.
* @param safeOnly whether the assignments should only be done to the safe attributes.
* A safe attribute is one that is associated with a validation rule in the current [[scenario]].
* @see safeAttributes
* @see attributeList
*/
-(void)setAttributes:(NSDictionary *)values safeOnly:(BOOL)safeOnly;

/**
* This method is invoked when an unsafe attribute is being massively assigned.
* The default implementation will log a warning message if DEBUG is on.
* It does nothing otherwise.
* @param name the unsafe attribute name
* @param value the attribute value
*/
-(void)onUnsafeAttribute:(NSString *)attribute value:(id)value;

/**
* Returns the scenario that this model is used in.
*
* Scenario affects how validation is performed and which attributes can
* be massively assigned.
*
* @return the scenario that this model is in. Defaults to [[SCENARIO_DEFAULT]].
*/
-(NSString *)getScenario;

/**
* Sets the scenario for the model.
* Note that this method does not check if the scenario exists or not.
* The method [[validate()]] will perform this check.
* @param value the scenario that this model is in.
*/
-(void)setScenario:(NSString *)scenario;

/**
* Returns the attribute names that are safe to be massively assigned in the current scenario.
* @return list of safe attribute names
*/
-(NSArray *)safeAttributes;

/**
* Returns the attribute names that are subject to validation in the current scenario.
* @return list of safe attribute names
*/
-(NSArray *)activeAttributes;
@end

@interface FXModelWrapper : NSObject
@end