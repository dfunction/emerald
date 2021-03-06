//
//  Episode.h
//  Emerald
//
//  Created by Juan Sebastian Angarita on 8/27/14.
//  Copyright (c) 2014 deltafunction.co. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Podcast;

@interface Episode : NSManagedObject

@property (nonatomic, retain) NSString * audioPath;
@property (nonatomic, retain) NSNumber * dataIsDownloading;
@property (nonatomic, retain) NSString * date;
@property (nonatomic, retain) NSString * imageUrl;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSData * visual;
@property (nonatomic, retain) Podcast *podcast;

@end
