//
//  Downloader.m
//  Emerald
//
//  Created by Juan Sebastian Angarita on 8/3/14.
//  Copyright (c) 2014 deltafunction.co. All rights reserved.
//

#import "Downloader.h"
#import "EpisodeCell.h"

@implementation Downloader

-(void) downloadAudioFor:(Episode*) episode to:(NSMutableData*) data withProgressViewPath:(NSIndexPath*) path andUITableView: (UITableView*) tableView
{
    self.episode = episode;
    self.url = self.episode.url;
    self.path = path;
    self.data = data;
    self.tableView = tableView;
    NSURL *nsUrl = [NSURL URLWithString:self.url];
    NSURLRequest *request = [NSURLRequest requestWithURL:nsUrl];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
    self.episode.dataIsDownloading = [[NSNumber alloc] initWithBool:YES];
    [self.episode.managedObjectContext save:NULL];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
    NSDictionary *dict = httpResponse.allHeaderFields;
    NSString *lengthString = [dict valueForKey:@"Content-Length"];
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    NSNumber *length = [formatter numberFromString:lengthString];
    self.totalBytes = length.unsignedIntegerValue;
    
    self.data = [[NSMutableData alloc] initWithCapacity:self.totalBytes];
}
     
 - (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.data appendData:data];
    self.receivedBytes += data.length;
    
    // Actual progress is self.receivedBytes / self.totalBytes
    float progress = (float)self.receivedBytes / (float)self.totalBytes;
    
    UIProgressView* view = ((EpisodeCell*)[self.tableView cellForRowAtIndexPath: self.path]).progress;
    
    [view setProgress:progress animated:YES];
}

 - (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    self.episode.dataIsDownloading = [[NSNumber alloc] initWithBool:NO];
    self.episode.audio = self.data;
    [self.episode.managedObjectContext save:NULL];
    
    
    EpisodeCell* cell = ((EpisodeCell*)[self.tableView cellForRowAtIndexPath: self.path]);
    [cell changeStateTo:FULL];
}
 
 - (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    //handle error
}

@end
