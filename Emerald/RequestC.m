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

static NSString *const emeraldAPIURL = @"http://Brooklyn.local:3000";//@"http://emerald.deltafunction.co";
static NSString *const emeraldCustomerEndpoint = @"customers";
static NSString *const emeraldChargeEndpoint = @"charge";

+ (void)pushUserWithTokenId:(NSString *)tokenId
{
    // Setup body of request
    NSDictionary *body = @{
                           @"tokenId": tokenId,
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
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if (error) {
                                   // Handle error
                                   NSLog(@"NSURLConnection: %@", error);
                               } else {
                                   // Check response
                                   NSDictionary *res = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:NULL];
                                   NSLog(@"result: %@, data: %@", [res objectForKey:@"result"], [res objectForKey:@"customerId"]);
                                   NSString *customerId = [res objectForKey:@"customerId"];
                                   if (customerId) {
                                       User *user = [User fetchUser];
                                       if (user) {
                                           user.stripeCustomerId = customerId;
                                           [[user managedObjectContext] save:NULL];
                                           NSLog(@"user id %@", user.stripeCustomerId);
                                       } else {
                                           [User createUserWithCustomerId:customerId];
                                           NSLog(@"Created new user: %@", customerId);
                                       }
                                   } else {
                                       NSLog(@"Server responded with error: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                                   }
                               }
                           }];

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
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if (error) {
                                   // Handle error
                                   NSLog(@"NSURLConnection: %@", error);
                               } else {
                                   // Check response
                                   NSDictionary *res = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:NULL];
                                   if ([[res objectForKey:@"result"] isEqualToString:@"success"]) {
                                       UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Emerald Payment" message:@"Thank you for your $1 donation!" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
                                       [alert show];
                                   } else {
                                       NSLog(@"Server responded with error: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                                   }
                               }
                           }];
}


@end
