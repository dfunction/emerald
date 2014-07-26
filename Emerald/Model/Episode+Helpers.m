//
//  Episode+Helpers.m
//  Emerald
//
//  Created by Juan Sebastian Angarita on 7/20/14.
//  Copyright (c) 2014 deltafunction.co. All rights reserved.
//

#import "Episode+Helpers.h"

@implementation Episode (Helpers)

- (NSComparisonResult) dateCompare: (Episode*)episode
{
    // Fri, 30 May 2014 13:20:18 -0400
    NSDateFormatter *formater = [[NSDateFormatter alloc] init];
    [formater setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss Z"];
    NSDate *dateA = [formater dateFromString:[self date]];
    NSDate *dateB = [formater dateFromString:[episode date]];
    return [dateB compare:dateA];
}

@end
