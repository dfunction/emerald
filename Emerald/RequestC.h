//
//  RequestC.h
//  Emerald
//
//  Created by Nora Tarano on 7/26/14.
//  Copyright (c) 2014 deltafunction.co. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STPView.h"


@interface RequestC : NSObject

+ (void)pushUserWithToken:(STPToken *)token;
+ (void)chargeWithEpisodeName:(NSString *)episodeName;
+ (void)deleteUser;

@end
