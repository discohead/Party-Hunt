//
//  PTHPartyDetailTableViewCell.h
//  Party Hunt
//
//  Created by Jared McFarland on 10/12/14.
//  Copyright (c) 2014 Jared Colin McFarland. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PTHPartyDetailTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *upvoteButton;
@property (weak, nonatomic) IBOutlet UILabel *upvoteCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *streetAddressLabel;
@property (weak, nonatomic) IBOutlet UILabel *cityStateZipLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *hoursLabel;
@property (weak, nonatomic) IBOutlet UILabel *ageLabel;

@end
