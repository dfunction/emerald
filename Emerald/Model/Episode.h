//
//  Episode.h
//  Emerald
//
//  Created by Juan Sebastian Angarita on 7/20/14.
//  Copyright (c) 2014 deltafunction.co. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Podcast;

@interface Episode : NSManagedObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSData * audio;
@property (nonatomic, retain) NSString * date;
@property (nonatomic, retain) Podcast *podcast;

@end
