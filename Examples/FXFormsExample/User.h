//
//  User.h
//  Examples
//
//  Created by Andrey on 19/11/14.
//
//

#import <Foundation/Foundation.h>
#import <FXForms/FXForms.h>
#import "FXModelValidation.h"

@interface User : NSObject <FXForm, FXModelValidation>
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *password;
- (NSArray *)excludedFields;
@end
