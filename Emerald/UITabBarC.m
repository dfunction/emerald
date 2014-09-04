//
//  UiTabBarC.m
//  Emerald
//
//  Created by Juan Sebastian Angarita on 8/27/14.
//  Copyright (c) 2014 deltafunction.co. All rights reserved.
//

#import "UITabBarC.h"
#import "OnboardingVC.h"
#import "User+Helpers.h"
#import "PaymentVC.h"


@interface UITabBarC ()

@property (strong, nonatomic) OnboardingVC *onboardingVC;
@property (strong, nonatomic) PaymentVC *paymentVC;

@end

@implementation UITabBarC

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Custom initialization
        if (![User fetchUser]) {
            self.onboardingVC = [[OnboardingVC alloc]initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
            
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(destroyOnboardingVC)
                                                         name:@"OnboardingViewHidden"
                                                       object:nil];
        }
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(showPaymentView:)
                                                     name:@"ShowPaymentView"
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(hidePaymentView)
                                                     name:@"HidePaymentView"
                                                   object:nil];

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (self.onboardingVC) [self.view addSubview:self.onboardingVC.view];
}

- (void) destroyOnboardingVC
{
    self.onboardingVC = NULL;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"OnboardingViewHidden" object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showPaymentView:(NSNotification *)notification
{
    PaymentViewType viewType = (PaymentViewType)[(NSNumber*)[notification.userInfo valueForKey:@"viewType"] intValue];
    self.paymentVC = [[PaymentVC alloc] initWithNibName:@"OnboardingPage2" bundle:nil type:viewType episodeName:[notification.userInfo valueForKey:@"episodeName"]];

    CGRect finalFrame = self.paymentVC.view.frame;
    self.paymentVC.view.frame  = CGRectMake(0, self.view.bounds.size.height, self.view.bounds.size.width, self.view.bounds.size.height);
    
    [UIView animateWithDuration:0.5
                          delay:0.1
                        options: UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.paymentVC.view.frame = finalFrame;
                     }
                     completion:^(BOOL finished){
                     }];
    [self.view addSubview:self.paymentVC.view];
}

- (void)hidePaymentView
{
    [UIView animateWithDuration:0.5
                          delay:0.1
                        options: UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.paymentVC.view.frame = CGRectMake(0, [[UIScreen mainScreen] bounds].size.height, self.view.bounds.size.width, self.view.bounds.size.height);
                     }
                     completion:^(BOOL finished){
                         [self.paymentVC.view removeFromSuperview];
                         self.paymentVC = NULL;
                     }];
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
