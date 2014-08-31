//
//  EpisodeCell.h
//  Emerald
//
//  Created by Juan Sebastian Angarita on 8/26/14.
//  Copyright (c) 2014 deltafunction.co. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum CellState {
    EMPTY,
    DOWNLOADING,
    FULL
} CellState;

@interface EpisodeCell : UITableViewCell

- (void)changeStateTo:(CellState)state;

@property (strong, nonatomic) IBOutlet UILabel *title;
@property (strong, nonatomic)IBOutlet UIProgressView *progress;
@property (strong, nonatomic) IBOutlet UIButton *download;
@end
