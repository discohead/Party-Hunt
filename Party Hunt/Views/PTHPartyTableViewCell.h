//
//  PTHPartyTableViewCell.h
//  Party Hunt
//
//  Created by Jared McFarland on 9/21/14.
//  Copyright (c) 2014 Jared Colin McFarland. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE

@class PFObject;

@protocol PTHPartyTableViewCellDelegate;

@interface PTHPartyTableViewCell : UITableViewCell

@property (strong, nonatomic) PFObject *party;
@property (weak, nonatomic) IBOutlet UIImageView *commentImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
//@property (weak, nonatomic) IBOutlet UILabel *bylineLabel;
@property (weak, nonatomic) IBOutlet UILabel *upvoteCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *hoursLabel;
@property (weak, nonatomic) IBOutlet UIButton *upvoteButton;
@property (weak, nonatomic) id <PTHPartyTableViewCellDelegate> delegate;

- (void)shouldEnableUpvoteButton:(BOOL)enabled;
- (void)setUpvoteStatus:(BOOL)upvoted;


@end

@protocol PTHPartyTableViewCellDelegate <NSObject>

@optional

- (void)partyTableViewCell:(PTHPartyTableViewCell *)partyTableViewCell didTapUpvoteButton:(UIButton *)button;

@end
