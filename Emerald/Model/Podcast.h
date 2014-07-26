//
//  Podcast.h
//  Emerald
//
//  Created by Juan Sebastian Angarita on 7/19/14.
//  Copyright (c) 2014 deltafunction.co. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Episode;

@interface Podcast : NSManagedObject

@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSSet *episodes;
@end

@interface Podcast (CoreDataGeneratedAccessors)

- (void)addEpisodesObject:(Episode *)value;
- (void)removeEpisodesObject:(Episode *)value;
- (void)addEpisodes:(NSSet *)values;
- (void)removeEpisodes:(NSSet *)values;

@end
