//
//  RequestC.h
//  Emerald
//
//  Created by Nora Tarano on 7/26/14.
//  Copyright (c) 2014 deltafunction.co. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RequestC : NSObject

+ (void)pushUserWithTokenId:(NSString *)tokenId;
+ (void)chargeWithEpisodeName:(NSString *)episodeName;

@end
