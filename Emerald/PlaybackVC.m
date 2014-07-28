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

#define TOP_BAR_HEIGHT  64

@interface PlaybackVC ()
@property (strong, nonatomic) AVAudioPlayer *player;
@property (strong, nonatomic) NSString *state;
@property (strong, nonatomic) UIImageView *thumbnailView;
@property (strong, nonatomic) UIImageView *backgroundView;
@property (strong, nonatomic) UILabel *titleView;
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
    
    // Get the episode's image
    NSData *imageData;
    if ([[self episode] visual] == NULL) {
        imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[[self episode] imageUrl]]];
        [[self episode] setVisual:imageData];
        [[[self episode] managedObjectContext] save:NULL];
    } else {
        imageData = [[self episode] visual];
    }
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    
    // Background view
    // frame
    CGRect backgroundFrame = CGRectMake(0, TOP_BAR_HEIGHT, width, width);
    self.backgroundView = [[UIImageView alloc] initWithFrame:backgroundFrame];
    self.backgroundView.contentMode = UIViewContentModeScaleAspectFit;
    // image
    UIImage *backgroundImage = [[UIImage alloc] initWithData:imageData];
    ALDBlurImageProcessor *blurImageProcessor = [[ALDBlurImageProcessor alloc] initWithImage:backgroundImage];
    UIImage *blurredBackgroundImage = [blurImageProcessor syncBlurWithRadius:10 iterations:10 errorCode:NULL];
    [self.backgroundView setImage:blurredBackgroundImage];
    [self.view addSubview:self.backgroundView];
    
    // Thumbnail view
    // frame
    CGRect thumbnailFrame = CGRectMake(width*1/16, TOP_BAR_HEIGHT + width*11/16, width*4/16, width/4);
    self.thumbnailView = [[UIImageView alloc] initWithFrame:thumbnailFrame];
    self.thumbnailView.contentMode = UIViewContentModeScaleAspectFit;
    self.thumbnailView.clipsToBounds = YES;
    self.thumbnailView.layer.cornerRadius = self.thumbnailView.bounds.size.width / 2;
    self.thumbnailView.layer.masksToBounds = YES;
    self.thumbnailView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.thumbnailView.layer.borderWidth = 2.0f;

    // image
    UIImage *thumbnailImage = [[UIImage alloc] initWithData:imageData];
    [self.thumbnailView setImage:thumbnailImage];
    [self.view addSubview: self.thumbnailView];
    
    // Title label
    // process
    NSArray *comps = [self.episode.title componentsSeparatedByString:@": "];
    NSString *titleString;
    if ([comps count] == 2) {
        titleString = [NSString stringWithFormat:@"%@:\r%@", comps[0], comps[1]];
    } else {
        titleString = self.episode.title;
    }
    // view
    CGRect textFrame = CGRectMake(width*6/16, TOP_BAR_HEIGHT + width*11/16, width*10/16, width/4);
    self.titleView = [[UILabel alloc] initWithFrame:textFrame];
    self.titleView.text = titleString;
    self.titleView.textColor = [UIColor whiteColor];
    self.titleView.font = [UIFont systemFontOfSize:18.0];
    self.titleView.textAlignment = NSTextAlignmentLeft;
    self.titleView.backgroundColor = [UIColor clearColor];
    self.titleView.lineBreakMode = NSLineBreakByWordWrapping;
    self.titleView.numberOfLines = 0;
    [self.view addSubview:self.titleView];
    
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
