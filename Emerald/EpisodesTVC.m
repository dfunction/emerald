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

@interface EpisodesTVC ()
@property (strong) NSArray *episodes;   // of Episode
@end

@implementation EpisodesTVC

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
    
    Podcast *podcast = NULL;
    if ([podcasts count] == 0) {
        podcast = [[Podcast alloc] initWithEntity:[NSEntityDescription entityForName:@"Podcast" inManagedObjectContext:context] insertIntoManagedObjectContext:context];
        [podcast setTitle:title];
        [podcast setUrl: [url absoluteString]];
        [context insertObject:podcast];
        [context save:NULL];
    } else {
        podcast = [podcasts firstObject];
    }
    
    if ([[podcast episodes] count] == 0) {
        [self setEpisodes:[podcast fetchEpisodes]];
    } else {
        [self setEpisodes:[[[podcast episodes] allObjects]sortedArrayUsingSelector:@selector(dateCompare:)]];
    }
    [context save:NULL];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    [self initData];
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EpisodeCell" forIndexPath:indexPath];
    
    // Configure the cell...
    [[cell textLabel] setText:[[[self episodes] objectAtIndex:[indexPath row]] title]];
    
    return cell;
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"EpisodePushSegue"]) {
        PlaybackVC *playbackVC = [segue destinationViewController];
        Episode *episode = [[self episodes] objectAtIndex:[[[self tableView] indexPathForSelectedRow] row]];
        [playbackVC setEpisode:episode];
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
