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
@property (strong, nonatomic) UIButton* skipButton;
@property (strong, nonatomic) UIButton* saveButton;
@property (strong, nonatomic) NSString* episodeName;
@property (strong, nonatomic) UILabel* bodyLabel;
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
        [self postOnboardingFinished];
    }];
}

- (IBAction)cancel:(id)sender
{
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"HidePaymentView"
     object:self];
}

- (IBAction)saveAndDonate:(id)sender
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
        self.skipButton = (UIButton*)[self.view viewWithTag:3];
        [self.skipButton addTarget:self action:@selector(createUser) forControlEvents:UIControlEventTouchUpInside];
        self.saveButton = (UIButton*)[self.view viewWithTag:2];
        [self.saveButton addTarget:self action:@selector(save:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (id) initForPopupWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andEpisodeName:(NSString*) episodeName
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.episodeName = episodeName;
        self.skipButton = (UIButton*)[self.view viewWithTag:3];
        [self.skipButton addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
        [self.skipButton setTitle:@"Cancel" forState:UIControlStateNormal];
        self.saveButton = (UIButton*)[self.view viewWithTag:2];
        [self.saveButton setTitle:@"Save & Donate" forState:UIControlStateNormal];
        [self.saveButton addTarget:self action:@selector(saveAndDonate:) forControlEvents:UIControlEventTouchUpInside];
        self.bodyLabel = (UILabel*)[self.view viewWithTag:4];
        self.bodyLabel.text = [NSString stringWithFormat:@"Donate $1 for \"%@\" by entering your CC info here.", self.episodeName];
    }
    return self;
}

- (void)createUser
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.stripeView = (STPView *)[self.view viewWithTag:1];
    self.stripeView.key = STRIPE_KEY;
    self.stripeView.delegate = self;
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
