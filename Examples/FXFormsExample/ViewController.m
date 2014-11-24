//
//  ViewController.m
//  FXFormsExample
//
//  Created by Andrey on 19/11/14.
//
//

#import "ViewController.h"
#import "User.h"
@interface ViewController ()<FXFormControllerDelegate>
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) FXFormController *formController;
@property (nonatomic, strong) User *user;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.user = [[User alloc] init];
    
    self.formController = [[FXFormController alloc] init];
    self.formController.tableView = self.tableView;
    self.formController.delegate = self;
    self.formController.form = self.user;
}

- (IBAction)OnLoginClick:(id)sender {
    self.user.scenario = @"login";
    if(![self.user validate])
        [self showErrors];
    else {
        [self showOk];
    }
}

- (IBAction)OnRegisterClick:(id)sender {
    self.user.scenario = @"register";
    if(![self.user validate])
        [self showErrors];
    else {
        [self showOk];
    }
}

-(void)showOk {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"OK"
                                                    message:[NSString stringWithFormat:@"Everything is valid for scenario: %@", self.user.scenario]
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

-(void)showErrors {
    NSMutableString *message = [NSMutableString string];
    
    [self.user.errors enumerateKeysAndObjectsUsingBlock:^(NSString *attribute, NSArray *errors, BOOL *stop) {
        for(NSString *error in errors) {
            [message appendFormat:@"- %@\n", error];
        };
    }];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!"
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}
@end
