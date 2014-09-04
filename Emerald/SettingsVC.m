//
//  SettingsVC.m
//  Emerald
//
//  Created by Juan Sebastian Angarita on 9/2/14.
//  Copyright (c) 2014 deltafunction.co. All rights reserved.
//

#import "SettingsVC.h"
#import "User+Helpers.h"
#import "PaymentVC.h"

@interface SettingsVC ()
@property (strong, nonatomic) IBOutlet UIView *ccInfoView;
@property (strong, nonatomic) IBOutlet UIImageView *ccBrandImageView;
@property (strong, nonatomic) IBOutlet UIButton *addCCButton;
@property (strong, nonatomic) IBOutlet UILabel *ccNumberLabel;
@end

@implementation SettingsVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    User* user = [User fetchUser];
    self.ccInfoView.hidden = YES;
    self.addCCButton.hidden = YES;
    if (user.stripeCustomerId) {
        self.ccNumberLabel.text = [NSString stringWithFormat:@"xxxx-xxxx-xxxx-%@",user.last4];
        self.ccBrandImageView.image = [UIImage imageNamed:@"placeholder.png"];
        self.ccInfoView.hidden = NO;
    } else {
        self.addCCButton.hidden = NO;
    }
}

- (IBAction)deleteUser:(UIButton *)sender {
    //TODO
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
- (IBAction)addCC:(UIButton *)sender {
    NSNumber *viewType = [[NSNumber alloc] initWithInt:PaymentViewTypeSimple];
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:viewType forKey:@"viewType"];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"ShowPaymentView"
     object:self
     userInfo:userInfo];
}

@end
