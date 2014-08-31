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



- (void)stripeView:(STPView *)view withCard:(PKCard *)card isValid:(BOOL)valid;

@end
