//
//  Downloader.h
//  Emerald
//
//  Created by Juan Sebastian Angarita on 8/3/14.
//  Copyright (c) 2014 deltafunction.co. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Episode.h"


@interface Downloader : NSObject <NSURLConnectionDataDelegate>

-(void) downloadAudioFor:(Episode*) episode to:(NSMutableData*) data withProgressViewPath:(NSIndexPath*) path andUITableView: (UITableView*) tableView;

@property NSMutableData *data;
@property NSUInteger totalBytes;
@property NSUInteger receivedBytes;
@property NSIndexPath *path;
@property NSString *url;
@property Episode* episode;
@property UITableView* tableView;
@end

