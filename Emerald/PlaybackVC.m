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
@property (strong, nonatomic) UIImageView *backgroundView;
@property (strong, nonatomic) UIView *titleView;
@property (strong, nonatomic) UIImageView *thumbnailView;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UIButton *playButton;
@property (strong, nonatomic) UIButton *donateButton;
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
    
    // Prepare audio
    NSFileManager* fileManager = [[NSFileManager alloc] init];
    NSData *soundData;
    if ([[self episode] audioPath] == nil) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Do not yet have audio data." delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil];
        [alert show];
        return;
    } else {
        soundData = [fileManager contentsAtPath: self.episode.audioPath];
    }

    [self setPlayer:[[AVAudioPlayer alloc] initWithData:soundData error:NULL]];
    [self.player setVolume:1.0];
    [self.player prepareToPlay];

    
    // Get the episode's image
    NSData *imageData;
    if ([[self episode] visual] == nil) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Do not yet have image data." delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil];
        [alert show];
        return;
    } else {
        imageData = [[self episode] visual];
    }
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    
    // Background view
    // frame
    CGRect backgroundFrame = CGRectMake(0, 0, width, height);
    self.backgroundView = [[UIImageView alloc] initWithFrame:backgroundFrame];
    self.backgroundView.contentMode = UIViewContentModeScaleAspectFill;
    self.backgroundView.clipsToBounds = YES;
    // image
    UIImage *backgroundImage = [[UIImage alloc] initWithData:imageData];
    ALDBlurImageProcessor *blurImageProcessor = [[ALDBlurImageProcessor alloc] initWithImage:backgroundImage];
    UIImage *blurredBackgroundImage = [blurImageProcessor syncBlurWithRadius:10 iterations:10 errorCode:NULL];
    [self.backgroundView setImage:blurredBackgroundImage];
    [self.view addSubview:self.backgroundView];
    
    // Title view
    [self makeTitleViewWithImageData:imageData];
    
    // Player
    // play button
    CGFloat playerY = CGRectGetMaxY(self.titleView.frame);
    CGRect playerFrame = CGRectMake(width*1/16, playerY + width/16, width*2/16, width*2/16);
    UIImage *playImage = [UIImage imageNamed:@"play"];
    self.playButton = [[UIButton alloc] initWithFrame:playerFrame];
    self.playButton.backgroundColor = [UIColor blackColor];
    [self.playButton setImage:playImage forState:UIControlStateNormal];
    [self.playButton addTarget:self action:@selector(playButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.playButton];
    
    // Donation
    // donate button
    CGFloat donateY = CGRectGetMaxY(self.playButton.frame);
    CGRect donateFrame = CGRectMake(width*1/16, donateY + width/16, width*2/16, width*2/16);
    self.donateButton = [[UIButton alloc] initWithFrame:donateFrame];
    self.donateButton.backgroundColor = [UIColor blackColor];
    [self.donateButton setTitle:@"$1" forState:UIControlStateNormal];
    [self.donateButton addTarget:self action:@selector(donateButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.donateButton];
}

- (void)makeTitleViewWithImageData:(NSData *)imageData {
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    
    // Title view
    CGRect titleViewFrame = CGRectMake(width*1/16, height/4, width*14/16, height/5);
    self.titleView = [[UIView alloc] initWithFrame:titleViewFrame];
    self.titleView.backgroundColor = [UIColor blackColor];
    
    // Thumbnail view
    // frame
    CGFloat thumbnailSize = CGRectGetHeight(titleViewFrame);
    CGRect thumbnailFrame = CGRectMake(0, 0, thumbnailSize, thumbnailSize);
    self.thumbnailView = [[UIImageView alloc] initWithFrame:thumbnailFrame];
    self.thumbnailView.clipsToBounds = YES;
    self.thumbnailView.contentMode = UIViewContentModeScaleAspectFill;
    self.thumbnailView.layer.masksToBounds = YES;
    // image
    UIImage *thumbnailImage = [[UIImage alloc] initWithData:imageData];
    [self.thumbnailView setImage:thumbnailImage];
    [self.titleView addSubview: self.thumbnailView];
    
    // Title label
    // process title
    NSArray *comps = [self.episode.title componentsSeparatedByString:@": "];
    NSString *titleString;
    if ([comps count] == 2) {
        titleString = [NSString stringWithFormat:@"%@:\r%@", comps[0], comps[1]];
    } else {
        titleString = self.episode.title;
    }
    // view
    CGRect textFrame = CGRectMake(thumbnailSize, 0, CGRectGetWidth(titleViewFrame)-thumbnailSize, CGRectGetHeight(titleViewFrame));
    self.titleLabel = [[UILabel alloc] initWithFrame:textFrame];
    self.titleLabel.text = [titleString uppercaseString];
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.font = [UIFont boldSystemFontOfSize:14.0];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.backgroundColor = [UIColor clearColor];
    self.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.titleLabel.numberOfLines = 0;
    [self.titleView addSubview:self.titleLabel];

    [self.view addSubview:self.titleView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIImage *)image:(UIImage *)image ByApplyingAlpha:(CGFloat) alpha {
    UIGraphicsBeginImageContextWithOptions(image.size, NO, 0.0f);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGRect area = CGRectMake(0, 0, image.size.width, image.size.height);
    
    CGContextScaleCTM(ctx, 1, -1);
    CGContextTranslateCTM(ctx, 0, -area.size.height);
    
    CGContextSetBlendMode(ctx, kCGBlendModeMultiply);
    
    CGContextSetAlpha(ctx, alpha);
    
    CGContextDrawImage(ctx, area, image.CGImage);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newImage;
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
