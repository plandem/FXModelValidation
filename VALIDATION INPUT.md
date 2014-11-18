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
