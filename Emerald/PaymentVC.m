//
//  PaymentVC.m
//  Emerald
//
//  Created by Juan Sebastian Angarita on 7/23/14.
//  Copyright (c) 2014 deltafunction.co. All rights reserved.
//

#import "PaymentVC.h"
#import "User.h"

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
    NSLog(@"Received token %@", token.tokenId);
    // Create user with token
    NSDictionary *customer = [[NSDictionary alloc] init];
    NSDictionary *card = [[NSDictionary alloc] init];
    [card setValue:token.card.number forKey:@"number"];
    [card setValue:[NSString stringWithFormat:@"%lu",(unsigned long)token.card.expMonth] forKey:@"exp_month"];
    [card setValue:[NSString stringWithFormat:@"%lu",(unsigned long)token.card.expYear] forKey:@"exp_year"];
    [card setValue:token.card.cvc forKey:@"cvc"];
    NSData *jsonCardData = [NSJSONSerialization dataWithJSONObject:card
                                                       options:0
                                                         error:NULL];
    NSString *JSONCardString = [[NSString alloc] initWithBytes:[jsonCardData bytes] length:[jsonCardData length] encoding:NSUTF8StringEncoding];
    [customer setValue:JSONCardString forKey:@"card"];
    NSData *jsonCustomerData = [NSJSONSerialization dataWithJSONObject:customer
                                                               options:0
                                                                 error:NULL];
    NSString *JSONCustomerString = [[NSString alloc] initWithBytes:[jsonCustomerData bytes] length:[jsonCustomerData length] encoding:NSUTF8StringEncoding];
    NSLog(@"JSON Customer: %@", JSONCustomerString);
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

// Retrieve the managed object
- (NSManagedObjectContext *) managedObjectContext
{
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    User *user = [self fetchUser];
    if (user) {
        
    } else {
        self.stripeView = [[STPView alloc] initWithFrame:CGRectMake(15,20,290,55)
                                                  andKey:@"pk_test_6pRNASCoBOKtIshFeQd4XMUh"];
        self.stripeView.delegate = self;
        [self.view addSubview:self.stripeView];
    }
}

- (User *)fetchUser {
    // Create request for the user
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"User"];
    // Fetch the user from the request
    NSArray *users = [context executeFetchRequest:request error:NULL];
    return [users firstObject];
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
