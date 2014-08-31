//
//  User.h
//  Emerald
//
//  Created by Juan Sebastian Angarita on 8/30/14.
//  Copyright (c) 2014 deltafunction.co. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface User : NSManagedObject

@property (nonatomic, retain) NSString * stripeCustomerId;

@end
