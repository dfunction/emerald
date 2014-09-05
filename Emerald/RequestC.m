//
//  RequestC.m
//  Emerald
//
//  Created by Nora Tarano on 7/26/14.
//  Copyright (c) 2014 deltafunction.co. All rights reserved.
//

#import "RequestC.h"
#import "User+Helpers.h"

@interface RequestC ()

@end


@implementation RequestC

static NSString *const emeraldAPIURL = @"http://localhost:3000";//@"http://emerald.deltafunction.co";
static NSString *const emeraldCustomerEndpoint = @"customers";
static NSString *const emeraldChargeEndpoint = @"charge";

+ (void)pushUserWithToken:(STPToken *)token
{
    // Setup body of request
    NSDictionary *body = @{
                           @"tokenId": token.tokenId,
                           @"deviceId": [[UIDevice currentDevice].identifierForVendor UUIDString]
                           };
    NSData *bodyJSON = [NSJSONSerialization dataWithJSONObject:body options:NSJSONWritingPrettyPrinted error:NULL];
    // Setup the request
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[[NSURL URLWithString:emeraldAPIURL] URLByAppendingPathComponent:emeraldCustomerEndpoint]];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    request.HTTPMethod = @"POST";
    request.HTTPBody = bodyJSON;
    // Sent the request
    NSLog(@"Sending POST %@ %@", request, body);
    NSURLResponse* response;
    NSError* error;
    NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if (error) {
        // Handle error
        NSLog(@"NSURLConnection: %@", error);
    } else {
        // Check response
        NSDictionary *res = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:NULL];
        NSLog(@"result: %@, data: %@", [res objectForKey:@"result"], [res objectForKey:@"customerId"]);
        NSString *customerId = [res objectForKey:@"customerId"];
        if (customerId) {
            NSManagedObjectContext *context = [User managedObjectContext];
            User *user = [User fetchUser];
            if (!user) user = [[User alloc] initWithEntity:[NSEntityDescription entityForName:@"User" inManagedObjectContext:context] insertIntoManagedObjectContext:context];
            user.stripeCustomerId = customerId;
            user.last4 = token.card.last4;
            user.brand = token.card.type;
            [[user managedObjectContext] save:NULL];
            NSLog(@"Created user %@", user.stripeCustomerId);
        } else {
            NSLog(@"Server responded with error: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        }
    }

}

+ (void)chargeWithEpisodeName:(NSString *)episodeName
{
    User *user = [User fetchUser];
    NSString *tokenId = user.stripeCustomerId;
    NSString *deviceId = [[UIDevice currentDevice].identifierForVendor UUIDString];
    NSDictionary *body = @{
                           @"customerId": tokenId,
                           @"deviceId": deviceId,
                           @"episodeName": episodeName
                           };
    NSData *bodyJSON = [NSJSONSerialization dataWithJSONObject:body options:NSJSONWritingPrettyPrinted error:NULL];
    // Setup the request
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[[NSURL URLWithString:emeraldAPIURL] URLByAppendingPathComponent:emeraldChargeEndpoint]];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    request.HTTPMethod = @"POST";
    request.HTTPBody = bodyJSON;
    // Sent the request
    NSLog(@"Sending POST %@ %@", request, body);
    NSURLResponse* response;
    NSError* error;
    NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if (error) {
        // Handle error
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"PaymentError"
         object:self];
        NSLog(@"NSURLConnection: %@", error);
    } else {
        // Check response
        NSDictionary *res = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:NULL];
        if ([[res objectForKey:@"result"] isEqualToString:@"success"]) {
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"PaymentSuccess"
             object:self];
        } else {
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"PaymentError"
             object:self];
            NSLog(@"Server responded with error: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        }
    }
}

+ (void)deleteUser
{
    // Setup body of request
    NSDictionary *body = @{@"deviceId": [[UIDevice currentDevice].identifierForVendor UUIDString]};
    NSData *bodyJSON = [NSJSONSerialization dataWithJSONObject:body options:NSJSONWritingPrettyPrinted error:NULL];
    // Setup the request
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[[[NSURL URLWithString:emeraldAPIURL] URLByAppendingPathComponent:emeraldCustomerEndpoint] URLByAppendingPathComponent:@"delete"]];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    request.HTTPMethod = @"POST";
    request.HTTPBody = bodyJSON;
    // Sent the request
    NSLog(@"Sending POST %@ %@", request, body);
    NSURLResponse* response;
    NSError* error;
    NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if (error) {
        // Handle error
        NSLog(@"NSURLConnection: %@", error);
    } else {
        // Check response
        NSDictionary *res = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:NULL];
        NSString *result = [res objectForKey:@"result"];
        if ([result isEqualToString:@"success"]) {
            User *user = [User fetchUser];
            NSManagedObjectContext *context = [User managedObjectContext];
            [context deleteObject:user];
            NSLog(@"Deleted user");
        } else {
            NSLog(@"Server responded with error: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        }
    }
}

@end
