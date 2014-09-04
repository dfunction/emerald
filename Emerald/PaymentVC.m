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
@property (strong, nonatomic) NSString* episodeName;
@property (strong, nonatomic) IBOutlet UILabel *bodyLabel;
@property (strong, nonatomic) IBOutlet STPView *stripeView;
@property (strong, nonatomic) IBOutlet UIButton *acceptButton;
@property (strong, nonatomic) IBOutlet UIButton *dismissButton;
@property (nonatomic) PaymentViewType viewType;
@end

@implementation PaymentVC

# pragma mark Main
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.stripeView.key = STRIPE_KEY;
    self.stripeView.delegate = self;
    
    switch (self.viewType) {
        case PaymentViewTypeOnboarding:
        {
            [self.acceptButton setTitle:@"Save" forState:UIControlStateNormal];
            [self.dismissButton setTitle:@"Skip" forState:UIControlStateNormal];
        }
        break;
        case PaymentViewTypeDonating:
        {
            [self.acceptButton setTitle:@"Save & Donate" forState:UIControlStateNormal];
            [self.dismissButton setTitle:@"Cancel" forState:UIControlStateNormal];
            self.bodyLabel.text = [NSString stringWithFormat:@"Donate $1 for \"%@\" by entering your CC info here.", self.episodeName];
        }
        break;
        case PaymentViewTypeSimple:
        default:
        {
            [self.acceptButton setTitle:@"Save" forState:UIControlStateNormal];
            [self.dismissButton setTitle:@"Cancel" forState:UIControlStateNormal];
        }
        break;
    }
}

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil type:(PaymentViewType)type episodeName:(NSString*) episodeName
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.episodeName = episodeName;
        self.viewType = type;
    }
    return self;
}

# pragma mark Actions

- (IBAction)acceptAction:(id)sender
{
    switch (self.viewType) {
        case PaymentViewTypeOnboarding:
            [self saveAndFinishOnboarding];
            break;
        case PaymentViewTypeDonating:
            [self saveAndDonate];
            break;
        case PaymentViewTypeSimple:
        default:
            [self saveAndHidePaymentView];
            break;
    }
}


- (IBAction)dismissAction:(id)sender
{
    switch (self.viewType) {
        case PaymentViewTypeOnboarding:
            [self createUserAndFinishOnboarding];
            break;
        case PaymentViewTypeDonating:
        case PaymentViewTypeSimple:
        default:
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"HidePaymentView"
             object:self];
            break;
    }
}

# pragma mark Helpers

- (void)saveAndFinishOnboarding
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
        [self postOnboardingFinished];
    }];
}

- (void)saveAndHidePaymentView
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
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"HidePaymentView"
         object:self];
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"ReloadSettingsView"
         object:self];
    }];
}

- (void)saveAndDonate
{
    [self.stripeView createToken:^(STPToken *token, NSError *error) {
        if (error) {
            // Handle error
            [self handleError:error];
        } else {
            // Send off token to your server
            [self handleToken:token];
            if ([User fetchUser].stripeCustomerId) {
                [RequestC chargeWithEpisodeName:self.episodeName];
                [[NSNotificationCenter defaultCenter]
                 postNotificationName:@"HidePaymentView"
                 object:self];
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Error" message: @"Please try again later." delegate: self cancelButtonTitle: @"Ok" otherButtonTitles: nil];
                [alert show];
            }
        }
    }];
}

- (void)createUserAndFinishOnboarding
{
    User *user = [User fetchUser];
    if (!user) {
        [User createUserWithCustomerId:nil];
    }
    [self postOnboardingFinished];
}

- (void)postOnboardingFinished
{
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"OnboardingFinished"
     object:self];
}

# pragma mark Stripe

- (void)stripeView:(STPView *)view withCard:(PKCard *)card isValid:(BOOL)valid {}

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
    [RequestC pushUserWithToken:token];
}
@end
