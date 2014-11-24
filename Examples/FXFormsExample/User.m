//
//  User.m
//  Examples
//
//  Created by Andrey on 19/11/14.
//
//

#import "User.h"

@implementation User

-(instancetype) init {
    if((self = [super init])) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            [[self class] validationInit];
        });
    }
    
    return self;
}

-(NSArray *)rules {
    return @[
             // username, email and password are all required in "register" scenario
             @{
                 FXModelValidatorAttributes : @[@"username", @"email", @"password"],
                 FXModelValidatorType : @"required",
                 FXModelValidatorOn: @[@"register"],
                 },
             // username and password are required in "login" scenario
             @{
                 FXModelValidatorAttributes : @[@"username", @"password"],
                 FXModelValidatorType : @"required",
                 FXModelValidatorOn: @[@"login"],
                 },
             // email should be valid email address
             @{
                 FXModelValidatorAttributes : @"email",
                 FXModelValidatorType : @"email", 
                 FXModelValidatorOn: @[@"register"],
                 },

             ];
    
}

- (NSArray *)excludedFields
{
	//Just for demonstrating purpose - that we support already implemented 'excludedFields()' for FXForms.
	//Check result of that method after object initialization and you will see here other properties too.
    return @[
             @"someProperty",
             @"someOtherProperty",
             ];
}
@end
