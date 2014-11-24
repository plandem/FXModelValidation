[![Build Status](https://travis-ci.org/plandem/FXModelValidation.svg)](https://travis-ci.org/plandem/FXModelValidation)
[![Coverage Status](https://img.shields.io/coveralls/plandem/FXModelValidation.svg)](https://coveralls.io/r/plandem/FXModelValidation?branch=master)
[![Pod Version](http://img.shields.io/cocoapods/v/FXModelValidation.svg?style=flat)](http://cocoadocs.org/docsets/FXModelValidation/)
[![Pod Platform](http://img.shields.io/cocoapods/p/FXModelValidation.svg?style=flat)](http://cocoadocs.org/docsets/FXModelValidation/)

#Purpose
FXModelValidation is an Objective-C library that allows to validate data/model/forms easily. Suits for any NSObject. So it should work fine both with CoreData or with raw NSObject. Library transparently supports [FXForms](https://github.com/nicklockwood/FXForms) to exclude own properties.

To make it to work you must do only 3 small steps:
- define validation rules
- attach FXModel functionality
- validate 

##Supported iOS/OSX & SDK Versions
- Supported build target - iOS 8.1/OSX 10.10 (Xcode 6.1, Apple LLVM compiler 6.0)
- Earliest supported deployment target - iOS 5.0/OSX 10.7
- Earliest compatible deployment target - iOS 5.0/OSX 10.7
 
>Note: 'Supported' means that the library has been tested with this version. 'Compatible' means that the library should work on this iOS version (i.e. it doesn't rely on any unavailable SDK features) but is no longer being tested for compatibility and may require tweaking or bug fixes to run correctly.

##ARC Compatibility
FXModelValidation requires ARC.

##How to get started
- install via CocoaPods
```
pod 'FXModelValidation'
```
- read this guide, [Validating Input](https://github.com/plandem/FXModelValidation/blob/master/Validating%20Input.md), [Core Validators](https://github.com/plandem/FXModelValidation/blob/master/Core%20Validators.md) and check out the [API documentation](http://cocoadocs.org/docsets/FXModelValidation)
- if you find issues or want to suggest improvements, create an issue or a pull request

##Attaching FXModelValidation
To make FXModelValidation work with your classes, you must _attach_ it functionality. You can do it for class or for single instance only. 

```object-c
ContactForm* model = [ContactForm alloc] init];
[[ContactForm class] validationInit];

```
>Attach FXModelValidation to class

```object-c
ContactForm* model = [ContactForm alloc] init];
[model validationInit];

```
>Attach FXModelValidation to single instance of ContactForm _model_.


Probably, best way is to override init method of class:
```object-c
@implementation ContactForm
-(instancetype *)init {
	if((self = [super init])) {
		static dispatch_once_t onceToken;
		dispatch_once(&onceToken, ^{
			[[self class] validationInit]
		});
	}

	return self;
};
@end

```
>Now any instance of ContactForm will have attached FXModelValidation functionality.

To gain access to this functionality, you also must add *FXModelValidation protocol* at your _interface_ declaration, like
```object-c
@interface ContactForm : NSObject <FXModelValidation>
@end
```

That's all. Now you have access to FXModelValidation methods/properties at your class. 

_But let's start from beginning..._

## Models
Models are part of the [MVC](http://en.wikipedia.org/wiki/Model–view–controller) architecture. They are objects representing business data, rules and logic. In terms of this library, models are objects that implements **FXModelValidation** protocol.

##Attributes
Models represent business data in terms of attributes. Each attribute is like a publicly accessible property of a model. The method **attributeList** specifies what attributes a model class has.

You can access an attribute like accessing a normal object property:

```object-c
ContactForm* model = [ContactForm alloc] init];

// "name" is an attribute of ContactForm
model.name = @"example";
NSLog(@"%@", model.name);
```

You can also access attributes indirectly using _NSKeyValueCoding_:
```object-c
ContactForm* model = [ContactForm alloc] init];

// accessing attributes via NSKeyValueCoding 
[model setValue:@"example" forKey:@"name"];
NSLog(@"%@", [model valueForKey:@"name"]);
```

##Defining Attributes
By default, **attributeList** returns all public properties. For example, the _ContactForm_ model class below has four attributes: _name_, _email_, _subject_ and _body_.
```object-c
@interface ContactForm : NSObject <FXModelValidation>
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *subject;
@property (nonatomic, strong) NSString *body;
@end
```
You may override **attributeList** to define attributes in a different way. The method should return the names of the attributes in a model. Note that accessing to your defined attributes must be _NSKeyValueCoding_ compatible.

##Scenarios
A model may be used in different scenarios. For example, a _User_ model may be used to collect user login inputs, but it may also be used for the user registration purpose. In different scenarios, a model may use different business rules and logic. For example, the _email_ attribute may be required during user registration, but not so during user login.

A model uses the **scenario** property to keep track of the scenario it is being used in. By default, a model supports only a single scenario named _default_. The following code shows how to set the scenario of a model:

```object-c
// scenario is set as a property
User* model = [User alloc] init];
model.scenario = @"login";
```

```object-c
// scenario is set as a setter
User* model = [User alloc] init];
[model setScenario: @"login"];
```

By default, the scenarios supported by a model are determined by the **validation rules** declared in the model. However, you can customize this behavior by implementing the **scenarioList** method, like the following:
```object-c
@implementation User
-(NSDictionary *)scenarioList {
	return @{
			@"login": @[@"username", @"password"],
			@"register": @[@"username", @"email", @"password"],
	};
};
@end
```

The _scenarioList_ method returns a dictionary whose keys are the scenario names and values the corresponding active attributes. An active attribute can be **massively assigned** and is subject to **validation**. In the above example, the _username_ and _password_ attributes are active in the _login_ scenario; while in the _register_ scenario, _email_ is also active besides _username_ and _password_.

The default implementation of _scenarioList_ will return all scenarios found in the **validation rule** declaration method **rules**. When overriding _scenarioList_, if you want to introduce new scenarios in addition to the default ones, you may write code like the following:
```object-c
@implementation User
-(NSDictionary *)scenarioList {
	NSMutableDictionary *scenarios = [NSMutableDictionary dictionaryWithDictionary:[(id<FXModel>)super scenarioList]];
	scenarios[@"login"] = @[@"username", @"password"];
	scenarios[@"register"] = @[@"username", @"email", @"password"];
	return scenarios;
};
@end
```

The scenario feature is primarily used by **validation** and **massive attribute assignment**. You can, however, use it for other purposes.

##Validation Rules
When the data for a model is received from end users, it should be validated to make sure it satisfies certain rules (called _validation rules_, also known as _business rules_). For example, given a _ContactForm_ model, you may want to make sure all attributes are not empty and the _email_ attribute contains a valid email address. If the values for some attributes do not satisfy the corresponding business rules, appropriate error messages should be displayed to help the user to fix the errors.

You may call **validate** to validate the received data. The method will use the validation rules declared in **rules** to validate every relevant attribute. If no error is found, it will return YES. Otherwise, it will keep the errors in the **errors** property and return NO. For example,

```object-c
User* model = [User alloc] init];

// populate model attributes with user inputs
model.attributes = @{@"username": @"john"};

if ([model validate]) {
    // all inputs are valid
} else {
    // validation failed: errors is an array containing error messages
    errors = model.errors;
}
```

To declare validation rules associated with a model, override the **rules** method by returning the rules that the model attributes should satisfy. The following example shows the validation rules declared for the _ContactForm_ model:
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

A rule can be used to validate one or multiple attributes, and an attribute may be validated by one or multiple rules. Please refer to the [Validating Input](https://github.com/plandem/FXModelValidation/blob/master/Validating%20Input.md) section for more details on how to declare validation rules.

Sometimes, you may want a rule to be applied only in certain scenarios. To do so, you can specify the on property of a rule, like the following:

```object-c
-(NSArray *)rules {
	return @[
			// username, email and password are all required in "register" scenario
			@{
					FXModelValidatorAttributes : @[@"user", @"email", @"password"],
					FXModelValidatorType : @"required",
					FXModelValidatorOn: @[@"register"],
			},
			// username and password are required in "login" scenario
			@{
					FXModelValidatorAttributes : @[@"user", @"password"],
					FXModelValidatorType : @"required",
					FXModelValidatorOn: @[@"login"],
			},
	];
}
```

If you do not specify the on property, the rule would be applied in all scenarios. A rule is called an active rule if it can be applied in the current scenario.

An attribute will be validated if and only if it is an active attribute declared in **scenarioList** and is associated with one or multiple active rules declared in **rules**.

##Validation
You can validate your model in 2 ways:
```object-c
User* model = [User alloc] init];

// populate model attributes with user inputs
model.attributes = @{@"username": @"john"};

if ([model validate]) {
    // all inputs are valid
} else {
    // validation failed: errors is an array containing error messages
    errors = model.errors;
}
```
>I.e. call validate manually.

or
```object-c
User* model = [User alloc] init];
//set observer to track updates and validate updated attributes
[model validateUpdates];

// populate model attributes with user inputs
model.attributes = @{@"username": @"john"};

if(model.hasErrors) {
    // validation failed: errors is an array containing error messages
    errors = model.errors;    
}

model.password = @"password123";
if(!(model.hasErrors)) {
	//validation succeded now.
}

```
>I.e. validate any updated attributes automatically. You need call _validateUpdates_ only once, right after initial setup.

Auto-validation made via KVO to let you valide only changes in more easily way.


##Massive Assignment
Massive assignment is a convenient way of populating a model with user inputs using a single line of code. It populates the attributes of a model by assigning the input data directly to the **attributes** property. The following two pieces of code are equivalent, both trying to assign the form data submitted by end users to the attributes of the _ContactForm_ model. Clearly, the former, which uses massive assignment, is much cleaner and less error prone than the latter:

```object-c
User* model = [User alloc] init];

model.attributes = @{
	@"name": @"john", 
	@"email": @"john@doe.com", 
	@"subject": @"Hello", 
	@"body": @"Hi, man!"
};
```

```object-c
User* model = [User alloc] init]
NSDictionary *data = @{
	@"name": @"john", 
	@"email": @"john@doe.com", 
	@"subject": @"Hello", 
	@"body": @"Hi, man!"
};

if(data[@"name"])
	model.name = data[@"name"];

if(data[@"email"])	
	model.email = data[@"email"];

if(data[@"subject"])
	model.subject = data[@"subject"];

if(data[@"body"])
	model.body = data[@"body"];
```

##Safe Attributes
Massive assignment only applies to the so-called safe attributes which are the attributes listed in **scenarioLis** for the current scenario of a model. For example, if the _User_ model has the following scenario declaration, then when the current scenario is login, only the username and password can be massively assigned. Any other attributes will be kept untouched.

```object-c
-(NSDictionary *)scenarioList {
	return @{
			@"login": @[@"username", @"password"],
			@"register": @[@"username", @"email", @"password"],
	};
};
```

>Info: The reason that massive assignment only applies to safe attributes is because you want to control which attributes can be modified by end user data.

Because the default implementation of **scenarioList** will return all scenarios and attributes found in **rules**, if you do not override this method, it means an attribute is safe as long as it appears in one of the active validation rules.

For this reason, a special validator aliased safe is provided so that you can declare an attribute to be _safe_ without actually validating it. For example, the following rules declare that both _title_ and _description_ are safe attributes.

```object-c
-(NSArray *)rules {
	return @[
			@{
					FXModelValidatorAttributes : @[@"title", @"description"],
					FXModelValidatorType : @"safe",
			},
	];
}
```

##Unsafe Attributes
As described above, **scenarioList** method serves for two purposes: determining which attributes should be validated, and determining which attributes are safe. In some rare cases, you may want to validate an attribute but do not want to mark it safe. You can do so by prefixing an exclamation mark ! to the attribute name when declaring it in **scenarioList**, like the _secret_ attribute in the following:

```object-c
-(NSDictionary *)scenarioList {
	return @{
			@"login": @[@"username", @"password", @"!secret"],
	};
};
```

When the model is in the _login_ scenario, all three attributes will be validated. However, only the _username_ and _password_ attributes can be massively assigned. To assign an input value to the _secret_ attribute, you have to do it explicitly as follows,

```object-c
model.secret = @(42);
```

#Best Practices
Models are the central places to represent business data, rules and logic. They often need to be reused in different places. In a well-designed application, models are usually much fatter than controllers.

In summary, models
- may contain attributes to represent business data;
- may contain validation rules to ensure the data validity and integrity;
- may contain methods implementing business logic;
- avoid having too many scenarios in a single model.

You may usually consider the last recommendation above when you are developing large complex systems. In these systems, models could be very fat because they are used in many places and may thus contain many sets of rules and business logic. This often ends up in a nightmare in maintaining the model code because a single touch of the code could affect several different places. To make the model code more maintainable, you may take the following strategy:

- Define a set of base model classes that are shared by different parts of application. These model classes should contain minimal sets of rules and logic that are common among all their usages.

- Define a concrete model class by extending from the corresponding base model class. The concrete model classes should contain rules and logic that are specific for that application's part.

##API documentation
Full API documentation is autogenerated from sources and can be accessed from [CocoaDocs](http://cocoadocs.org/docsets/FXModelValidation)

##Copyrights
This library is heavily based on PHP framework [Yii](http://www.yiiframework.com). That's way of working with models is proved and tested by time and many developers.

This library must be considered as an independent project, with own codebase that was created from the ground.
