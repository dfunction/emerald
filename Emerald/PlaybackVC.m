//
//  PlaybackVC.m
//  Emerald
//
//  Created by Juan Sebastian Angarita on 7/19/14.
//  Copyright (c) 2014 deltafunction.co. All rights reserved.
//

#import "PlaybackVC.h"
#import "RequestC.h"

@interface PlaybackVC ()
@property (strong, nonatomic) AVAudioPlayer *player;
@property (strong, nonatomic) NSString *state;
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
    // Do any additional setup after loading the view.
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
