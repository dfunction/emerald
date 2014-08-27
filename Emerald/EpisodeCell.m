//
//  EpisodeCell.m
//  Emerald
//
//  Created by Juan Sebastian Angarita on 8/26/14.
//  Copyright (c) 2014 deltafunction.co. All rights reserved.
//

#import "EpisodeCell.h"

@implementation EpisodeCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.state = EMPTY;
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)changeStateTo:(CellState)state {
    self.download.hidden = YES;
    self.progress.hidden = YES;
    self.accessoryType = UITableViewCellAccessoryNone;
    switch (state) {
        case EMPTY:
            self.download.hidden = NO;
            break;
        case DOWNLOADING:
            self.progress.hidden = NO;
            break;
        case FULL:
        default:
            self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
    }
}

@end
