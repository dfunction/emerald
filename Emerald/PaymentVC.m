//
//  PaymentVC.m
//  Emerald
//
//  Created by Juan Sebastian Angarita on 7/23/14.
//  Copyright (c) 2014 deltafunction.co. All rights reserved.
//

#import "PaymentVC.h"
#import "User+Helpers.h"
#import "RequestC.h"

#define STRIPE_KEY  @"pk_test_8twZAQ2hxIw36UUWXjBqLCfU"

@interface PaymentVC ()

@end

@implementation PaymentVC

- (IBAction)save:(id)sender
{
    // Call 'createToken' when the save button is tapped
    [self.stripeView createToken:^(STPToken *token, NSError *error) {
        if (error) {
            // Handle error
            [self handleError:error];
        } else {
            // Send off token to your server
            [self handleToken:token];
        }
    }];
}

- (void)handleError:(NSError *)error
{
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error")
                                                      message:[error localizedDescription]
                                                     delegate:nil
                                            cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                            otherButtonTitles:nil];
    [message show];
}

- (void)handleToken:(STPToken *)token
{
    NSLog(@"Received token %@\n%@", token.tokenId, token.card.last4);
    [RequestC pushUserWithTokenId:token.tokenId];
}

- (void)stripeView:(STPView *)view withCard:(PKCard *)card isValid:(BOOL)valid
{
    // Toggle navigation, for example
    // self.saveButton.enabled = valid;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    User *user = [User fetchUser];
    if (user) {
        // TODO: setup list card view
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Emerald Settings" message:@"User exists" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
        [alert show];
    } else {
        self.stripeView = [[STPView alloc] initWithFrame:CGRectMake(15,20,290,55)
                                                  andKey:STRIPE_KEY];
        self.stripeView.delegate = self;
        [self.view addSubview:self.stripeView];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
