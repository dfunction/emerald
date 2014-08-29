//
//  UiTabBarC.m
//  Emerald
//
//  Created by Juan Sebastian Angarita on 8/27/14.
//  Copyright (c) 2014 deltafunction.co. All rights reserved.
//

#import "UITabBarC.h"
#import "OnboardingVC.h"

@interface UITabBarC ()

@property (strong, nonatomic) OnboardingVC *onboardingVC;

@end

@implementation UITabBarC

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Custom initialization
        self.onboardingVC = [[OnboardingVC alloc]initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(destroyOnboardingVC)
                                                     name:@"OnboardingViewHidden"
                                                   object:nil];

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view addSubview:self.onboardingVC.view];
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
