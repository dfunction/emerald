//
//  User+Helpers.m
//  Emerald
//
//  Created by Nora Tarano on 7/26/14.
//  Copyright (c) 2014 deltafunction.co. All rights reserved.
//

#import "User+Helpers.h"

@implementation User (Helpers)

// Retrieve the managed object
+ (NSManagedObjectContext *) managedObjectContext
{
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}

+ (User *)createUserWithCustomerId:(NSString *)customerId
{
    NSManagedObjectContext *context = [self managedObjectContext];
    
    User *user = [[User alloc] initWithEntity:[NSEntityDescription entityForName:@"User" inManagedObjectContext:context] insertIntoManagedObjectContext:context];
    user.stripeCustomerId = customerId;
    
    [context save:NULL];
    
    return user;
}

+ (User *)fetchUser {
    // Create request for the user
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"User"];
    // Fetch the user from the request
    NSArray *users = [context executeFetchRequest:request error:NULL];
    return [users firstObject];
}

@end
