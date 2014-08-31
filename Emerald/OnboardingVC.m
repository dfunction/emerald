//
//  OnboardingVC.m
//  Emerald
//
//  Created by Juan Sebastian Angarita on 8/27/14.
//  Copyright (c) 2014 deltafunction.co. All rights reserved.
//

#import "OnboardingVC.h"
#import "PaymentVC.h"

@interface OnboardingVC ()

@property (strong, nonatomic) NSMutableArray* nibNames;

@end

@implementation OnboardingVC

- (id)initWithTransitionStyle:(UIPageViewControllerTransitionStyle)style navigationOrientation:(UIPageViewControllerNavigationOrientation)navigationOrientation options:(NSDictionary *)options
{
    self = [super initWithTransitionStyle:style navigationOrientation:navigationOrientation options:options];
    if (self) {
        self.dataSource = self;
        
        self.nibNames = [[NSMutableArray alloc] init];
        
        [self.nibNames addObject:@"OnboardingPage1"];
        [self.nibNames addObject:@"OnboardingPage2"];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(hideOnboarding)
                                                     name:@"OnboardingSkipped"
                                                   object:nil];
        NSArray *initialVC = [[NSArray alloc] initWithObjects:[[UIViewController alloc] initWithNibName:[self.nibNames objectAtIndex:0] bundle:nil], nil];
        
        [self setViewControllers:initialVC direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    CGRect finalFrame = self.view.frame;
    self.view.frame  = CGRectMake(0, 490, 320, 460);
    
    [UIView animateWithDuration:0.5
                          delay:0.1
                        options: UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.view.frame = finalFrame;
                     }
                     completion:^(BOOL finished){
                     }];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissNumberPad)];
    
    [self.view addGestureRecognizer:tap];
}

- (void) dismissNumberPad {
    if ([((UIViewController*)self.viewControllers[0]).nibName isEqualToString:self.nibNames[1] ]) {
        [((STPView*)[self.view viewWithTag:1]).paymentView resignFirstResponder];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)hideOnboarding
{
    [UIView animateWithDuration:0.5
                          delay:0.1
                        options: UIViewAnimationCurveEaseIn
                     animations:^{
                         self.view.frame = CGRectMake(0, [[UIScreen mainScreen] bounds].size.height, 320, 460);
                     }
                     completion:^(BOOL finished){
                         [self.view removeFromSuperview];
                         [[NSNotificationCenter defaultCenter]
                          postNotificationName:@"OnboardingViewHidden"
                          object:self];
                         [[NSNotificationCenter defaultCenter] removeObserver:self name:@"OnboardingSkipped" object:nil];
                     }];
}

# pragma mark - UIPageViewControllerDataSource

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{    
    NSUInteger index = [self.nibNames indexOfObject:viewController.nibName];
    return [self viewControllerAtIndex:(index - 1)];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = [self.nibNames indexOfObject:viewController.nibName];
    return [self viewControllerAtIndex:(index + 1)];
}

- (UIViewController *)viewControllerAtIndex:(NSUInteger)index
{
    if (([self.nibNames count] == 0) || (index >= [self.nibNames count])) {
        return nil;
    }
    
    if (index == 1) {
        return [[PaymentVC alloc] initWithNibName:[self.nibNames objectAtIndex:(index)] bundle:nil];
    } else {
        return [[UIViewController alloc] initWithNibName:[self.nibNames objectAtIndex:(index)] bundle:nil];
    }
}

@end
