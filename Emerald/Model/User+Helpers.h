//
//  User+Helpers.h
//  Emerald
//
//  Created by Nora Tarano on 7/26/14.
//  Copyright (c) 2014 deltafunction.co. All rights reserved.
//

#import "User.h"

@interface User (Helpers)

+ (NSManagedObjectContext *)managedObjectContext;
+ (User *)createUserWithCustomerId:(NSString *)customerId;
+ (User *)fetchUser;

@end
