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
#import "User+Helpers.h"
#import "PaymentVC.h"

#define TOP_BAR_HEIGHT  64

@interface PlaybackVC ()
@property (strong, nonatomic) AVAudioPlayer *player;
@property (strong, nonatomic) NSString *state;
@property (strong, nonatomic) IBOutlet UIImageView *thumbnailView;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *playButton;
@property (strong, nonatomic) IBOutlet UIProgressView *playerProgressView;
@property (strong, nonatomic) IBOutlet UIButton *donateButton;
@property (strong, nonatomic) NSTimer *playerProgressTimer;
@end

@implementation PlaybackVC

- (IBAction)playButtonPressed:(UIBarButtonItem *)sender {
    if ([self.state compare:@"paused"] == 0) {
        [[self player] play];
        self.state = @"playing";
    } else if ([self.state compare:@"playing"] == 0) {
        [[self player] pause];
        self.state = @"paused";
    }
}

- (IBAction)donateButtonPressed:(UIBarButtonItem *)sender {
    User* user = [User fetchUser];
    if (user && user.stripeCustomerId) {
        [RequestC chargeWithEpisodeName:self.episode.title];
    } else {
        NSNumber *viewType = [[NSNumber alloc] initWithInt:PaymentViewTypeDonating];
        NSDictionary* dict = [NSDictionary dictionaryWithObjects:[[NSArray alloc] initWithObjects:self.episode.title, viewType, nil]
                                                         forKeys:[[NSArray alloc] initWithObjects:@"episodeName", @"viewType", nil]];
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"ShowPaymentView"
         object:self
         userInfo:dict];
    }
    
}

- (void)paymentSuccess
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Emerald Payment" message:@"Thank you for your $1 donation!" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
    [alert show];
}

- (void)paymentError
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please try again later" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
    [alert show];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(paymentSuccess)
                                                     name:@"PaymentSuccess"
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(paymentError)
                                                     name:@"PaymentError"
                                                   object:nil];
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
    
    // Thumbnail View
    UIImage *thumbnailImage = [[UIImage alloc] initWithData:imageData];
    ALDBlurImageProcessor *blurImageProcessor = [[ALDBlurImageProcessor alloc] initWithImage:thumbnailImage];
    UIImage *blurredThumbnailImage = [blurImageProcessor syncBlurWithRadius:5 iterations:10 errorCode:NULL];
    [self.thumbnailView setImage:blurredThumbnailImage];
    
    // Title label
    NSString *titleString = self.episode.title;
    self.titleLabel.text = titleString;
    
    self.playerProgressTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateCurrentTime) userInfo:nil repeats:YES];
}

- (void)updateCurrentTime
{
    float progress = self.player.currentTime * 1.0 / self.player.duration;
    [self.playerProgressView setProgress:progress animated:YES];
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
