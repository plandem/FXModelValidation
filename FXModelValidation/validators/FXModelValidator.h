//
// Created by Andrey on 10/11/14.
// Copyright (c) 2014 Andrey Gayvoronsky. All rights reserved.
//

#import <Foundation/Foundation.h>
FOUNDATION_EXPORT NSString *const FXFormValidatorErrorDomain;

@interface FXModelValidator : NSObject
/**
* Attributes to be validated by this validator.
*/
@property(nonatomic, copy) NSArray *attributes;

/**
* The user-defined error message. It may contain the following placeholders which
* will be replaced accordingly by the validator:
*
* - `{attribute}`: the name of the attribute being validated
* - `{value}`: the value of the attribute being validated
*
* Note that some validators may introduce other properties for error messages used when specific
* validation conditions are not met. Please refer to individual class API documentation for details
* about these properties. By convention, this property represents the primary error message
* used when the most important validation condition is not met.
*/
@property(nonatomic, copy) NSString *message;

/**
* List scenarios that the validator can be applied to.
*/
@property(nonatomic, copy) NSArray *on;

/**
* Scenarios that the validator should not be applied to.
*/
@property(nonatomic, copy) NSArray *except;

/**
* Whether this validation rule should be skipped if the attribute being validated
* already has some validation error according to some previous rules. Defaults to YES.
*/
@property(nonatomic, assign) BOOL skipOnError;

/**
* Whether this validation rule should be skipped if the attribute value is empty (@see isEmpty:).
*/
@property(nonatomic, assign) BOOL skipOnEmpty;

/**
* Block whose return value determines whether this validator should be applied.
* The signature of the callable should be `BOOL (^when)(id model, NSString *attribute)`, where `model` and `attribute`
* refer to the model and the attribute currently being validated.
*
* If this property is not set, this validator will be always applied.
*/
@property(nonatomic, copy) BOOL (^when)(id model, NSString *attribute);

/**
* Block that replaces the default implementation of [[isEmpty()]].
* If not set, [[isEmpty()]] will be used to check if a value is empty. The signature
* of the callable should be `BOOL (^isEmpty)(id value)` which returns a BOOL indicating
* whether the value is empty.
*/
@property(nonatomic, copy) BOOL (^isEmpty)(id value);

/**
* Creates a validator object.
* @param type the validator type.
* @param model the data model to be validated.
* @param attributes list of attributes to be validated.
* @param params initial values to be applied to the validator properties
* @return the validator or nil validator settings is invalid
*/
+(FXModelValidator *)createValidator:(id)type model:(id)model attributes:(NSArray *)attributes params:(NSDictionary *)params;

/**
* Initialize validator with attributes and params. Use it to manually create validator without model (@see: validateValue:)
*/
-(instancetype)initWithAttributes:(NSArray *)attributes params:(NSDictionary *)params;

/**
* Validates a single attribute.
* Child classes must implement this method to provide the actual validation logic.
* @param model the data model to be validated
* @param attribute the name of the attribute to be validated.
*/
-(void)validate:(id)model attribute:(NSString *)attribute;

/**
* Validates the specified model.
* @param model the data model being validated
* @param attributes the list of attributes to be validated.
* Note that if an attribute is not associated with the validator,
* it will be ignored.
* If this parameter is nil, every attribute listed in [[attributes]] will be validated.
*/
-(void)validate:(id)model attributes:(NSArray *)attributes;

/**
* @see validate:attributes:
*/
-(void)validate:(id)model;

/**
* Validates a value.
* A validator class can implement this method to support data validation out of the context of a data model.
* @param value the data value to be validated.
* @return the error message.
* nil should be returned if the data is valid.
* @throws exception if the validator does not supporting data validation without a model
*/
-(NSError *)validateValue:(id)value;

/**
* Returns a value indicating whether the validator is active for the given scenario and attribute.
*
* A validator is active if
*
* - the validator's `on` property is empty, or
* - the validator's `on` property contains the specified scenario
*
* @param scenario scenario name
* @return whether the validator applies to the specified scenario.
*/
-(BOOL)isActive:(NSString *)scenario;

/**
* Adds an error about the specified attribute to the model object.
* This is a helper method that performs message selection and internationalization.
* @param model the data model being validated
* @param attribute the attribute being validated
* @param error the error message
*/
-(void)addError:(id)model attribute:(NSString *)attribute error:(NSError *)error;

/**
* @var callable a PHP callable that replaces the default implementation of [[isEmpty()]].
* If not set, [[isEmpty()]] will be used to check if a value is empty. The signature
* of the callable should be `function ($value)` which returns a boolean indicating
* whether the value is empty.
*/
-(BOOL)isEmpty:(id)value;

@end
