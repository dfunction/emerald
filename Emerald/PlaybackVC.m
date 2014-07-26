//
//  PlaybackVC.m
//  Emerald
//
//  Created by Juan Sebastian Angarita on 7/19/14.
//  Copyright (c) 2014 deltafunction.co. All rights reserved.
//

#import "PlaybackVC.h"
#import "RequestC.h"
#import "ALDBlurImageProcessor.h"

#define TOP_BAR_HEIGHT  88

@interface PlaybackVC ()
@property (strong, nonatomic) AVAudioPlayer *player;
@property (strong, nonatomic) NSString *state;
@property (strong, nonatomic) UIImageView *thumbnailView;
@property (strong, nonatomic) UITextView *titleView;
@end

@implementation PlaybackVC

- (IBAction)playButtonPressed:(UIButton *)sender {
    if ([self.state compare:@"paused"] == 0) {
        [[self player] play];
        self.state = @"playing";
        [sender setTitle:@"Pause" forState:UIControlStateNormal];
    } else if ([self.state compare:@"playing"] == 0) {
        [[self player] pause];
        self.state = @"paused";
        [sender setTitle:@"Play" forState:UIControlStateNormal];
    }
}

- (IBAction)donateButtonPressed:(UIButton *)sender {
    [RequestC chargeWithEpisodeName:self.episode.title];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Get Audio
    NSData *soundData;
    if ([[self episode] audio] == NULL) {
        soundData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[[self episode] url]]];
        [[self episode] setAudio:soundData];
        [[[self episode] managedObjectContext] save:NULL];
    } else {
        soundData = [[self episode] audio];
    }
    NSError *error;
    [self setPlayer:[[AVAudioPlayer alloc] initWithData:soundData error:&error]];
    if (error)
    {
        NSLog(@"Error in audioPlayer: %@", [error localizedDescription]);
    } else {
        [[self player] setVolume:1.0];
        [[self player] prepareToPlay];
    }
    
    // Set thumbnail size and position
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat tbHeight = TOP_BAR_HEIGHT;
    CGRect thumbnailFrame = CGRectMake(0, 0, width, width + tbHeight);
    self.thumbnailView = [[UIImageView alloc] initWithFrame:thumbnailFrame];
    self.thumbnailView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:self.thumbnailView];
    
    // Set the image
    NSData *imageData;
    if ([[self episode] visual] == NULL) {
        imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[[self episode] imageUrl]]];
        [[self episode] setVisual:imageData];
        [[[self episode] managedObjectContext] save:NULL];
    } else {
        imageData = [[self episode] visual];
    }
    UIImage *thumbnail = [[UIImage alloc] initWithData:imageData];
    ALDBlurImageProcessor *blurImageProcessor = [[ALDBlurImageProcessor alloc] initWithImage: thumbnail];
    UIImage *blurredThumbnail = [blurImageProcessor syncBlurWithRadius:5 iterations:10 errorCode:NULL];
    [self.thumbnailView setImage:blurredThumbnail];
    
    CGRect textFrame = CGRectMake(0, tbHeight, width, width);
    self.titleView = [[UITextView alloc] initWithFrame:textFrame];
    self.titleView.backgroundColor = [UIColor clearColor];
    self.titleView.textColor = [UIColor whiteColor];
    self.titleView.font = [UIFont boldSystemFontOfSize:36.0];
    self.titleView.text = self.episode.title;
    CGFloat topCorrect = self.titleView.bounds.size.height - self.titleView.contentSize.height;
    topCorrect = topCorrect < 0.0 ? 0.0 : topCorrect;
    self.titleView.contentOffset = CGPointMake(400, 400);
    self.titleView.selectable = NO;
    self.titleView.editable = NO;
    [self.view addSubview:self.titleView];
    NSLog(@"offset %f", self.titleView.contentSize.height);
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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
