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

@property STPView* stripeView;

typedef enum PaymentViewType {
    ONBOARDING,
    DONATING,
    SIMPLE
} PaymentViewType;

- (void)stripeView:(STPView *)view withCard:(PKCard *)card isValid:(BOOL)valid;
- (id) initForPopupWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andEpisodeName:(NSString*) episodeName andViewType:(PaymentViewType) viewType;

@end
