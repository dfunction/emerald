//
//  EpisodesTVC.m
//  Emerald
//
//  Created by Juan Sebastian Angarita on 7/19/14.
//  Copyright (c) 2014 deltafunction.co. All rights reserved.
//

#import "EpisodesTVC.h"
#import "Podcast.h"
#import "Episode+Helpers.h"
#import "Podcast+Helpers.h"
#import "PlaybackVC.h"  // for segue
#import "Downloader.h"
#import "EpisodeCell.h"

@interface EpisodesTVC ()
@property (strong) NSArray *episodes;   // of Episode
@property (strong) Podcast *podcast;
@end

@implementation EpisodesTVC

#pragma mark - Actions

- (IBAction)pressedDownload:(id)sender {
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    EpisodeCell* cell = (EpisodeCell*)[self.tableView cellForRowAtIndexPath:indexPath];
    Episode *episode = [[self episodes] objectAtIndex:[[[self tableView] indexPathForCell:cell] row]];
    
    [cell changeStateTo:DOWNLOADING];
    
    [self downloadAudioForEpisode:episode withCell:cell];
}

#pragma mark - Action Helpers

- (void) downloadAudioForEpisode: (Episode*)episode withCell: (EpisodeCell*) cell
{
    episode.dataIsDownloading = [[NSNumber alloc] initWithBool:YES];
    [episode.managedObjectContext save:NULL];
    
    // Fetch audio
    NSMutableData *soundData;
    Downloader* downloader = [[Downloader alloc] init];
    [downloader downloadAudioFor:episode to:soundData withProgressViewPath:[self.tableView indexPathForCell: cell] andUITableView: self.tableView];
    
    // Fetch image
    NSData *imageData;
    imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:episode.imageUrl]];
    [episode setVisual:imageData];
    [episode.managedObjectContext save:NULL];
}

#pragma mark - Main

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    [self initData];
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    // Reset download flags
    for (NSUInteger i = 0; i < [self.episodes count]; i++) {
        Episode* episode = (Episode*)[self.episodes objectAtIndex:i];
        episode.dataIsDownloading = [[NSNumber alloc] initWithBool:NO];
        [episode.managedObjectContext save:NULL];
    }
}

- (IBAction)doRefresh:(UIRefreshControl *)sender {
    self.episodes = [[self.podcast fetchEpisodes] sortedArrayUsingSelector:@selector(dateCompare:)];
    //TODO: Update view?
    [sender endRefreshing];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[self episodes] count];
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"EpisodePushSegue"]) {
        PlaybackVC *playbackVC = [segue destinationViewController];
        Episode *episode = [[self episodes] objectAtIndex:[[[self tableView] indexPathForSelectedRow] row]];
        [playbackVC setEpisode:episode];
    }
}

- (EpisodeCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EpisodeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EpisodeCell" forIndexPath:indexPath];
    Episode *episode = [[self episodes] objectAtIndex:[indexPath row]];
    
    // Configure the cell...
    [[cell title] setText:episode.title];
    
    if ([episode.dataIsDownloading isEqualToNumber:[[NSNumber alloc] initWithBool:YES]]) {
        [cell changeStateTo:DOWNLOADING];
    } else if ([episode.dataIsDownloading isEqualToNumber:[[NSNumber alloc] initWithBool:NO]] && episode.audioPath && episode.visual) {
        [cell changeStateTo:FULL];
    } else {
        [cell changeStateTo:EMPTY];
    }
    
    return cell;
}

#pragma mark - Main Helpers

- (void)initData
{
    // Create the podcast if it doesn't exist
    NSString *title = @"Radiolab";
    NSURL *url = [NSURL URLWithString:@"http://feeds.wnyc.org/radiolab?format=xml"];
    // Create request for the podcast
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Podcast"];
    [request setPredicate:[NSPredicate predicateWithFormat:@"title == %@", title]];
    // Fetch the podcast from the request
    NSArray *podcasts = [context executeFetchRequest:request error:NULL];
    
    if ([podcasts count] == 0) {
        self.podcast = [[Podcast alloc] initWithEntity:[NSEntityDescription entityForName:@"Podcast" inManagedObjectContext:context] insertIntoManagedObjectContext:context];
        [self.podcast setTitle:title];
        [self.podcast setUrl: [url absoluteString]];
        [context insertObject:self.podcast];
        [context save:NULL];
    } else {
        self.podcast = [podcasts firstObject];
    }
    
    if ([[self.podcast episodes] count] == 0) {
        [self setEpisodes:[[self.podcast fetchEpisodes] sortedArrayUsingSelector:@selector(dateCompare:)]];
    } else {
        [self setEpisodes:[[[self.podcast episodes] allObjects] sortedArrayUsingSelector:@selector(dateCompare:)]];
    }
    [context save:NULL];
}

// Retrieve the managed object
- (NSManagedObjectContext *) managedObjectContext
{
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}
@end
