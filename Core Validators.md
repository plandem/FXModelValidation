#Core Validators
FXModelValidation provides a set of commonly used core validators. Instead of using lengthy validator class names, you may use aliases to specify the use of these core validators. For example, you can use the alias _required_ to refer to the _FXModelRequiredValidator_ class:
```object-c
-(NSArray *)rules {				
	return @[
		@{
			FXModelValidatorAttributes : @"email,password",
			FXModelValidatorType : @"required",
		},
	];
}
```

In the following, we will describe the main usage and properties of every core validator.

##boolean
```object-c
-(NSArray *)rules {				
	return @[
		@{
			// checks if "selected" is either 0 or 1
			FXModelValidatorAttributes : @"selected",
			FXModelValidatorType : @"boolean",
		},
		@{
			// checks if "deleted" is either "sure" or "not sure"
			FXModelValidatorAttributes : @"selected",
			FXModelValidatorType : @"boolean",
			FXModelValidatorTrueValue: @"sure",
			FXModelValidatorFalseValue: @"not sure",
		},
	];
}
```
This validator checks if the input value is a boolean.

- **trueValue**: the value representing true. Defaults to **@YES**.
- **falseValue**: the value representing false. Defaults to **@NO**.

##compare
```object-c
-(NSArray *)rules {				
	return @[
		@{
			// validates if the value of "password" attribute equals to that of "password_repeat"
			FXModelValidatorAttributes : @"password",
			FXModelValidatorType : @"compare",
		},
		@{
			// validates if age is greater than or equal to 30
			FXModelValidatorAttributes : @"age",
			FXModelValidatorType : @"compare",
			FXModelValidatorCompareValue: @30,
			FXModelValidatorOperator: @">=",
		},
	];
}
```

This validator compares the specified input value with another one and make sure if their relationship is as specified by the _operator_ property.
- **compareAttribute**: the name of the attribute whose value should be compared with. When the validator is being used to validate an attribute, the default value of this property would be the name of the attribute suffixed with *_repeat*. For example, if the attribute being validated is _password_, then this property will default to _password_repeat_.
- **compareValue**: a constant value that the input value should be compared with. When both of this property and _compareAttribute_ are specified, this property will take precedence.
- **operator**: the comparison operator. Defaults to **==**, meaning checking if the input value is equal to that of **compareAttribute** or **compareValue**. The following operators are supported:
	- **==**: check if two values are equal.
	- **!=**: check if two values are NOT equal. 
	- **>**: check if value being validated is greater than the value being compared with.
	- **>=**: check if value being validated is greater than or equal to the value being compared with.
	- **<**: check if value being validated is less than the value being compared with.
	- **<=**: check if value being validated is less than or equal to the value being compared with.


##default
```object-c
-(NSArray *)rules {				
	return @[
		@{
			// set "age" to be null if it is empty
			FXModelValidatorAttributes : @"age",
			FXModelValidatorType : @"default",
			FXModelValidatorValue : [NSNull null]
		},
		@{
			 // set "country" to be "USA" if it is empty
			FXModelValidatorAttributes : @"country",
			FXModelValidatorType : @"default",
			FXModelValidatorValue : @"USA"
		},
		@{
			 // assign "from" and "to" with a today, if they are empty
			FXModelValidatorAttributes : @"from,to",
			FXModelValidatorType : @"default",
			FXModelValidatorValue : ^id(id model, NSString *attribute) {
				return [NSDate date];			
			}
		},				
	];
}
```
This validator does not validate data. Instead, it assigns a default value to the attributes being validated if the attributes are empty.

- **value**: the default value or a block that returns the default value which will be assigned to the attributes being validated if they are empty. The signature of the block should be as follows,
```object-c
^id(id model, NSString *attribute) {
	// ... compute value ...
	return value;
}
```
> Info: How to determine if a value is empty or not is a separate topic covered in the [Empty Values](https://github.com/plandem/FXModelValidation/blob/master/Validating%20Input.md) section

##email
```object-c
-(NSArray *)rules {				
	return @[
		@{
			// checks if "email" is a valid email address
			FXModelValidatorAttributes : @"email",
			FXModelValidatorType : @"email",
		},
	];
}
```

This validator checks if the input value is a valid email address.

- **checkDNS**, whether to check whether the email's domain exists. Be aware that this check may fail due to temporary DNS problems, even if the email address is actually valid. Defaults to @NO.
- **enableIDN**, whether the validation process should take into account IDN (internationalized domain names). Defaults to @NO. Note that in order to use IDN validation you have to install **NSURL+IDN** or IDN checking will not be working.

##filter
```object-c
@interface MyForm: NSObject <FXModelValidation>
@end

@implementation MyForm
-(NSArray *)rules {				
	return @[
		@{
			// trim "username" and "email" inputs
			FXModelValidatorAttributes : @"username,email",
			FXModelValidatorType : @"trim",
		},	
		@{
			// use inline filter method to filter  "username" and "email"
			FXModelValidatorAttributes : @"username,email",
			FXModelValidatorType : @"filter",
			FXModelValidatorFilter: @"filterValue",
			FXModelValidatorSkipOnArray: @YES,
		},
		@{
			// use inline filter with block to filter "username" and "email"
			FXModelValidatorAttributes : @"username,email",
			FXModelValidatorType : @"filter",
			FXModelValidatorFilter: ^id(id value, NSDictionary* params) {
				// process value
				return newValue;
			},
			FXModelValidatorSkipOnArray: @YES,
		},				
	];
}

-(id)filterValue:(id)value params:(NSDictionary *)params {
	// process value
	return newValue;
}

@end;
```
This validator does not validate data. Instead, it applies a filter on the input value and assigns it back to the attribute being validated.

- **filter**: a block or method that defines a filter. This property must be set.
- **skipOnArray**: whether to skip the filter if the input value is an array. Defaults to @NO. Note that if the filter cannot handle array input, you should set this property to be @YES. Otherwise some error might occur.

> Tip: If you want to trim input values, you may directly use **trim** validator.

##in
```object-c
-(NSArray *)rules {				
	return @[
		@{
			// checks if "level" is 1, 2 or 3
			FXModelValidatorAttributes : @"level",
			FXModelValidatorType : @"in",
			FXModelValidatorRange: @[@1, @2, @3],
		},
	];
}
```

This validator checks if the input value can be found among the given list of values.

- **range**: a list of given values within which the input value should be looked for.
- **not**: whether the validation result should be inverted. Defaults to @NO. When this property is set @YES, the validator checks if the input value is NOT among the given list of values.
- **allowArray**: whether to allow the input value to be an array. When this is @YES and the input value is an array, every element in the array must be found in the given list of values, or the validation would fail.

##match
```object-c
-(NSArray *)rules {				
	return @[
		@{
			// checks if "username" starts with a letter and contains only word characters
			FXModelValidatorAttributes : @"username",
			FXModelValidatorType : @"match",
			FXModelValidatorPattern: @"^[a-z]\w*$",
		},
	];
}
```
This validator checks if the input value matches the specified regular expression.

- **pattern**: the regular expression that the input value should match. This property must be set, or an exception will be thrown. It can be string or NSRegularExpression.
- **not**: whether to invert the validation result. Defaults to @NO, meaning the validation succeeds only if the input value matches the pattern. If this is set @YES, the validation is considered successful only if the input value does NOT match the pattern.

##number
```object-c
-(NSArray *)rules {				
	return @[
		@{
			// checks if "salary" is a number
			FXModelValidatorAttributes : @"salary",
			FXModelValidatorType : @"number",
		},
	];
}
```

This validator checks if the input value is a number.

- **max**: the upper limit (inclusive) of the value. If not set, it means the validator does not check the upper limit.
- **min**: the lower limit (inclusive) of the value. If not set, it means the validator does not check the lower limit.


##required
```object-c
-(NSArray *)rules {				
	return @[
		@{
			// checks if both "username" and "password" are not empty
			FXModelValidatorAttributes : @"username,password",
			FXModelValidatorType : @"required",
		},
	];
}
```

This validator checks if the input value is provided and not empty.

- **requiredValue**: the desired value that the input should be. If not set, it means the input should not be empty.

> Info: How to determine if a value is empty or not is a separate topic covered in the [Empty Values](https://github.com/plandem/FXModelValidation/blob/master/Validating%20Input.md) section.

##safe
```object-c
-(NSArray *)rules {				
	return @[
		@{
			// marks "description" to be a safe attribute
			FXModelValidatorAttributes : @"description",
			FXModelValidatorType : @"safe",
		},
	];
}
```

This validator does not perform data validation. Instead, it is used to mark an attribute to be a safe attribute.

##string
```object-c
-(NSArray *)rules {				
	return @[
		@{
			// checks if "username" is a string whose length is between 4 and 24
			FXModelValidatorAttributes : @"username",
			FXModelValidatorType : @"string",
		},
	];
}
```

This validator checks if the input value is a valid string with certain length.

- **length**: specifies the length limit of the input string being validated. This can be specified in one of the following forms:
	- an integer: the exact length that the string should be of;
	- an array of one element: the minimum length of the input string (e.g. @[@8]). This will overwrite min.
	- an array of two elements: the minimum and maximum lengths of the input string (e.g. @[@8, @128]). This will overwrite both min and max.
- **min**: the minimum length of the input string. If not set, it means no minimum length limit.
- **max**: the maximum length of the input string. If not set, it means no maximum length limit.

##trim
```object-c
-(NSArray *)rules {				
	return @[
		@{
			 // trims the white spaces surrounding "username" and "email"
			FXModelValidatorAttributes : @"username,email",
			FXModelValidatorType : @"trim",
		},
	];
}
```

This validator does not perform data validation. Instead, it will trim the surrounding white spaces around the input value. Note that if the input value is an array, it will be ignored by this validator.

##url
```object-c
-(NSArray *)rules {				
	return @[
		@{
			// checks if "website" is a valid URL. Prepend "http://" to the "website" attribute if it does not have a URI scheme
			FXModelValidatorAttributes : @"website",
			FXModelValidatorType : @"url",
		},
	];
}
```

This validator checks if the input value is a valid URL.

- **validSchemes**: an array specifying the URI schemes that should be considered valid. Defaults to @[@"http", @"https"], meaning both http and https URLs are considered to be valid.
- **defaultScheme**: the default URI scheme to be prepended to the input if it does not have the scheme part. Defaults to **nil**, meaning do not modify the input value.
- **enableIDN**, whether the validation process should take into account IDN (internationalized domain names). Defaults to @NO. Note that in order to use IDN validation you have to install **NSURL+IDN** or IDN checking will not be working.
