//
//  PaymentVC.h
//  Emerald
//
//  Created by Juan Sebastian Angarita on 7/23/14.
//  Copyright (c) 2014 deltafunction.co. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STPView.h"

@interface PaymentVC : UIViewController <STPViewDelegate>

typedef enum PaymentViewType {
    PaymentViewTypeOnboarding,
    PaymentViewTypeDonating,
    PaymentViewTypeSimple
} PaymentViewType;

- (void)stripeView:(STPView *)view withCard:(PKCard *)card isValid:(BOOL)valid;
- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil type:(PaymentViewType)type episodeName:(NSString*) episodeName;

@end
