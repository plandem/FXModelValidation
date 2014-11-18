//
// Created by Andrey on 10/11/14.
// Copyright (c) 2014 Andrey Gayvoronsky. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol FXModel;

/**
* Methods that model must implement to make validation working.
*/
@protocol FXModelValidation <FXModel>
@required
/**
* Returns the validation rules for attributes.
*
* Validation rules are used by [[validate()]] to check if attribute values are valid.
* Child classes may override this method to declare different validation rules.
*
* Each rule is an array with the following structure:
*
* ~~~
* @[
*     @[... validator settings ...],
*     @[... validator settings ...],
*     @[... validator settings ...],
* ]
*
* or
*
* @[
*     @{... validator settings ...},
*     @{... validator settings ...},
*     @{... validator settings ...},
* ]
* ~~~
*
* where
*  - attribute list: required, specifies the attributes array(or comma separated string) to be validated, for single attribute you can pass string;
*  - validator type: required, specifies the validator to be used. It can be:
*  	 1) a string with a built-in validator name
*  	 2) a string with a method name of the model class
*    3) a block]
*    4) an instance of an class that extending the FXModelValidator
*    5) a class that extending the FXModelValidator
*  - on: optional, specifies the [[scenario|scenarios]] array when the validation
*    rule can be applied. If this option is not set, the rule will apply to all scenarios.
*  - additional name-value pairs can be specified to initialize the corresponding validator properties.
*    Please refer to individual validator class API for possible properties.
*
* Note, in order to inherit rules defined in the parent class, a child class needs to
* merge the parent rules with child rules.
*
* @return array validation rules
* @see scenarioList
*/
-(NSArray *)rules;

@optional
/**
* This method is invoked before validation starts.
* You may override this method to do preliminary checks before validation.
* @return  whether the validation should be executed. Defaults to YES.
* If NO is returned, the validation will stop and the model is considered invalid.
*/
-(BOOL)beforeValidate;

/**
* This method is invoked after validation ends.
* You may override this method to do postprocessing after validation. Defaults: do nothing.
*/
-(void)afterValidate;
@end

@interface NSObject (FXModelValidation)

/**
* Attach FXModelValidation protocol implementation to class.
*/
+(BOOL)validationInit;

/**
* Attach FXModelValidation protocol implementation to instance
*/
-(BOOL)validationInit;

/**
* Attach FXModelValidation protocol implementation to class and try to add an implementation for rules method. The default class implementation of rules will be used if there is any.
*/
+(BOOL)validationInitWithRules:(NSArray *)rules;

/**
* Attach FXModelValidation protocol implementation to instance and try to add an implementation for rules method. The default class implementation of rules will be used if there is any.
*/
-(BOOL)validationInitWithRules:(NSArray *)rules;

/**
* Attach FXModelValidation protocol implementation to class and force to use an implementation for new implementation of rules method. The default class implementation of rules will be ignored.
*/
+(void)validationInitWithRules:(NSArray *)rules force:(BOOL)force;

/**
* Attach FXModelValidation protocol implementation to class and force to use an implementation for new implementation of rules method. The default class implementation of rules will be ignored.
*/
-(void)validationInitWithRules:(NSArray *)rules force:(BOOL)force;
@end