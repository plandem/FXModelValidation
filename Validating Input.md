#Validating Input
As a rule of thumb, you should never trust the data received from end users and should always validate it before putting it to good use.

Given a model populated with user inputs, you can validate the inputs by calling the **validate** method. The method will return a BOOL value indicating whether the validation succeeds or not. If not, you may get the error messages from the **errors** property. For example,
```object-c
ContactForm* model = [ContactForm alloc] init];

// populate model attributes with user inputs
model.attributes = @{
	@"name": @"john", 
	@"email": @"john@doe.com", 
	@"subject": @"Hello", 
	@"body": @"Hi, man!"
};

if ([model validate]) {
    // all inputs are valid
} else {
    // validation failed: errors is an array containing error messages
    errors = model.errors;
}
```

Behind the scene, the **validate** method does the following steps to perform validation:

1. Determine which attributes should be validated by getting the attribute list from **scenarioList** using the current scenario. These attributes are called active attributes.
2. Determine which validation rules should be used by getting the rule list from **rules** using the current scenario. These rules are called active rules.
3. Use each active rule to validate each active attribute associated with that rule. If the rule fails, keep an error message for the attribute in the model.

##Declaring Rules
To make **validate** really work, you should declare validation rules for the attributes you plan to validate. This should be done by implementing the **rules** method. The following example shows how the validation rules for the _ContactForm_ model are declared:

```object-c
-(NSArray *)rules {				
	return @[
		// the name, email, subject and body attributes are required
		@{
			FXModelValidatorAttributes : @[@"name", @"email", @"subject", @"body"],
			FXModelValidatorType : @"required",
		},
		// the email attribute should be a valid email address
		@{
			FXModelValidatorAttributes : @"email",
			FXModelValidatorType : @"email"
		}
	];
}
```

The **rules** method should return an array of rules, each of which is an array/dictionary of the following format:
```object-c
@[
	@{
		// required, specifies which attributes should be validated by this rule.
		// For a single attribute, you can use the attribute name directly
		// without having it in an array instead of an array. You also can use string with comma-separated attribute names (e.g.: @"attribute1,attribute2") 
		FXModelValidatorAttributes : @[@"attribute1", @"attribute2", ...],
    	
		// required, specifies the type of this rule.
		// It can be a class name, validator alias,  a validation method name or a validation block
		FXModelValidatorType : @"validator",
    	
		// optional, specifies in which scenario(s) this rule should be applied
		// if not given, it means the rule applies to all scenarios
		// You may also configure the "except" option if you want to apply the rule
		// to all scenarios except the listed ones
		FXModelValidatorOn => @[@"scenario1", "scenario2", ...],
       
		// optional, specifies additional configurations for the validator object
		'property1' => 'value1', 
		'property2' => 'value2', 
		...
	},
];
```
 
There is also a short version that you can use in case when only FXModelValidatorAttributes and FXModelValidatorType will be used:
```object-c
@[
	@[ @[@"attribute1", @"attribute2", ...], @"validator" ],
	...
];
```

For each rule you must specify at least which attributes the rule applies to and what is the type of the rule. You can specify the rule type in one of the following forms:
 
- the alias of a core validator, such as _required_, _in_, _email_, etc. Please refer to the [Core Validators](https://github.com/plandem/FXModelValidation/blob/master/Core%20Validators.md) for the complete list of core validators.
- the name of a validation method in the model class, or a block. Please refer to the [Inline Validators] subsection for more details.
- a fully qualified validator class or class name. Please refer to the [Standalone Validators] subsection for more details.

A rule can be used to validate one or multiple attributes, and an attribute may be validated by one or multiple rules. A rule may be applied in certain scenarios only by specifying the on option. If you do not specify an _on_ option, it means the rule will be applied to all scenarios.

When the **validate** method is called, it does the following steps to perform validation:

- Determine which attributes should be validated by checking the current scenario against the scenarios declared in scenarioList. These attributes are the active attributes.
- Determine which rules should be applied by checking the current scenario against the rules declared in **rules**. These rules are the active rules.
- Use each active rule to validate each active attribute which is associated with the rule. The validation rules are evaluated in the order they are listed.

According to the above validation steps, an attribute will be validated if and only if it is an active attribute declared in **scenarioList** and is associated with one or multiple active rules declared in **rules**.

##Customizing Error Messages
Most validators have default error messages that will be added to the model being validated when its attributes fail the validation. For example, the _required_ validator will add a message "Username cannot be blank." to a model when the _username_ attribute fails the rule using this validator.

You can customize the error message of a rule by specifying the _message_ property when declaring the rule, like the following,
```object-c
-(NSArray *)rules {				
	return @[
		@{
			FXModelValidatorAttributes : @"username",
			FXModelValidatorType : @"required",
			FXModelValidatorMessage : @"Please choose a username.", 
		},
	];
}
```

Some validators may support additional error messages to more precisely describe different causes of validation failures. For example, the number validator supports _tooBig_ and _tooSmall_ to describe the validation failure when the value being validated is too big and too small, respectively. You may configure these error messages like configuring other properties of validators in a validation rule.

##Validation Events
When **validate** is called, it will call two methods that you may override to customize the validation process:

- **beforeValidate:** the default implementation will return YES. You may either override this method to do some preprocessing work (e.g. normalizing data inputs) before the validation occurs. The method should return a boolean value indicating whether the validation should proceed or not.
- **afterValidate**: the default implementation will do nothing. You may either override this method to do some postprocessing work after the validation is completed.

##Conditional Validation
To validate attributes only when certain conditions apply, e.g. the validation of one attribute depends on the value of another attribute you can use the _when_ property to define such conditions. For example,
```object-c
@[
    @{
    	FXModelValidatorAttributes: @"state", 
    	FXModelValidatorType: @"required", 
    	FXModelValidatorWhen: ^BOOL(id model, NSString *attribute) {
	        return [model.country isEqual: @"USA"];
    	},
    },
];
```

The _when_ property takes a block with the following signature:
```object-c
/**
 * @param model the model being validated
 * @param attribute the attribute being validated
 * @return BOOL whether the rule should be applied
 */
^BOOL(id model, NSString *attribute) {

}
```

##Data Filtering
User inputs often need to be filtered or preprocessed. For example, you may want to trim the spaces around the _username_ input. You may use validation rules to achieve this goal.

The following examples shows how to trim the spaces in the inputs and turn empty inputs into nulls by using the _trim_ and _default_ core validators:
```object-c
@[
	@[ @"username,email", @"trim" ],
	@[ @"username,email", @"default" ],
];
```

You may also use the more general _filter_ validator to perform more complex data filtering.

As you can see, these validation rules do not really validate the inputs. Instead, they will process the values and save them back to the attributes being validated.

##Handling Empty Inputs
```object-c
@[
    @{
    	// set "username" and "email" as null if they are empty
    	FXModelValidatorAttributes: @"username,email", 
    	FXModelValidatorType: @"default", 
    },
    @{
    	// set "level" to be 1 if it is empty
    	FXModelValidatorAttributes: @"level", 
    	FXModelValidatorType: @"default",
    	FXModelValidatorValue: @1,
    },        
];
```

By default, an input is considered empty if its value is an empty string, an empty array or a null. You may customize the default empty detection logic by configuring the the _isEmpty_ property with a block. For example,
```object-c
@[
    @{
    	FXModelValidatorAttributes: @"agree", 
    	FXModelValidatorType: @"required", 
    	FXModelValidatorIsEmpty: ^BOOL(id value) {
	        return (value == nil);
    	},
    },
];
```
> Note: Most validators do not handle empty inputs if their _skipOnEmpty_ property takes the default value true. They will simply be skipped during validation if their associated attributes receive empty inputs. Among the core validators, only the default, filter, required, and trim validators will handle empty inputs.

##Ad Hoc Validation
Sometimes you need to do ad hoc validation for values that are not bound to any model.

If you only need to perform one type of validation (e.g. validating email addresses), you may call the **validateValue** method of the desired validator, like the following:
```object-c
NSString *email = @"test@example.com";
FXModelEmailValidator *validator = [[FXModelEmailValidator alloc] init];
 
NSError *error;
if ((error = [validator validateValue:email])) {
    NSLog(@"Email is valid.");
} else {
    NSLog(@"%@", error);
}
```
> Note: Not all validators support such kind of validation.

Alternatively, you may use the following more "classic" syntax to perform ad hoc data validation:
```object-c
Form *form = [[Form alloc] init];
[form validationInitWithRules:@[
						@{
								FXModelValidatorAttributes : @"username,password",
								FXModelValidatorType : @"required",
						},
						@{
								FXModelValidatorAttributes : @"username",
								FXModelValidatorType : @"email",
						},
				]];
```
> Note: Here we attach 'FXModel' functionality with __inline__ rules.

or 

```object-c
Form *form = [[Form alloc] init];
[form validationInitWithRules:@[
						@{
								FXModelValidatorAttributes : @"username,password",
								FXModelValidatorType : @"required",
						},
						@{
								FXModelValidatorAttributes : @"username",
								FXModelValidatorType : @"email",
						},
				] force: YES];
```
> Note: Here we attach 'FXModel' functionality with __inline__ rules and force to override default implementation.

After validation, you can check if the validation succeeds or not by calling the **hasErrors** method, and then get the validation errors from the errors property, like you do with a normal model.

#Creating Validators
Besides using the **core validators** included in the FXModelValidation, you may also create your own validators. You may create inline validators or standalone validators.

##Inline Validators
An inline validator is one defined in terms of a model method or block. The signature of the method/function is:
```object-c
/**
 * validatorName - is name of validator 
 * @param attribute the attribute currently being validated
 * @param params the additional name-value pairs given in the rule
 */
-(void)validatorName:(NSString *)attribute params:(NSDictionary *)params; 
```

If an attribute fails the validation, the method/function should call **addError** to save the error message in the model so that it can be retrieved back later to present to end users.

Below are some examples:

```object-c
@interface MyForm: NSObject <FXModelValidation>
@end

@implementation MyForm

-(NSArray *)rules {				
	return @[
		@{
		 	// an inline validator defined as the model method validateCountry:params
			FXModelValidatorAttributes : @"username",
			FXModelValidatorType : @"validateCountry",
		},
		@{
			// an inline validator defined as block
			FXModelValidatorAttributes : @"token",
			FXModelValidatorType : ^(id model, NSString *attribute, NSDictionary *params) {
				if(!([[model valueForKey:attribute] isEqual:@123]))
					[model addError:attribute message:@"The token must contain letters or digits."];
		},
	];
}

-(void)validateCountry:(NSString *)attribute params:(NSDictionary *)params {
	id value = [self valueForKey:attribute];

	if(!([value isEqual:@"USA"] || [value isEqual:@"Web"]))
		[self addError:attribute message: @"The country must be either 'USA' or 'Web'"];
}

@end;
```

> Note: By default, inline validators will not be applied if their associated attributes receive empty inputs or if they have already failed some validation rules. If you want to make sure a rule is always applied, you may configure the **skipOnEmpty** and/or **skipOnError** properties to be NO in the rule declarations. For example:
```object-c
@[
		@{
		 	// an inline validator defined as the model method validateCountry:params
			FXModelValidatorAttributes : @"username",
			FXModelValidatorType : @"validateCountry",
			FXModelValidatorSkipOnEmpty: @NO,
			FXModelValidatorSkipOnError: @NO,
		},
];
```

##Standalone Validators
A standalone validator is a class extending FXModelValidator or its child class. You may implement its validation logic by overriding **validate:attribute** method. If an attribute fails the validation, call **addError** to save the error message in the model, like you do with inline validators. For example,
```object-c
@interface CountryValidator: FXModelValidator
@end

@implementation CountryValidator
-(void)validate:(id)model attribute:(NSString *)attribute {
	id value = [self valueForKey:attribute];
	
	if(!([value isEqual:@"USA"] || [value isEqual:@"Web"]))
		[model addError:attribute message: @"The country must be either 'USA' or 'Web'"];
}
@end
```

If you want your validator to support validating a value without a model, you should also override **validateValue**.
