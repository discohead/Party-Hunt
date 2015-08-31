//
//  PTHPartyTableViewCell.m
//  Party Hunt
//
//  Created by Jared McFarland on 9/21/14.
//  Copyright (c) 2014 Jared Colin McFarland. All rights reserved.
//

#import "PTHPartyTableViewCell.h"
#import "PTHConstants.h"
#import "PTHUtility.h"
#import <Parse/Parse.h>

@implementation PTHPartyTableViewCell

- (void)awakeFromNib {
    // Initialization code
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)didTapUpvoteButtonAction:(UIButton *)button {
    if (self.delegate && [self.delegate respondsToSelector:@selector(partyTableViewCell:didTapUpvoteButton:)]) {
        [self.delegate partyTableViewCell:self didTapUpvoteButton:button];
    }
}

- (void)setUpvoteStatus:(BOOL)upvoted {
    [self.upvoteButton setSelected:upvoted];
    
    if (upvoted) {
        [self.upvoteButton setImage:[UIImage imageNamed:@"upvoteActive"] forState:UIControlStateNormal];
    } else {
        [self.upvoteButton setImage:[UIImage imageNamed:@"upvoteInactive"] forState:UIControlStateNormal];
    }
}

- (void)shouldEnableUpvoteButton:(BOOL)enabled {
    if (enabled) {
        [self.upvoteButton addTarget:self action:@selector(didTapUpvoteButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    } else {
        [self.upvoteButton removeTarget:self action:@selector(didTapUpvoteButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
}

@end
