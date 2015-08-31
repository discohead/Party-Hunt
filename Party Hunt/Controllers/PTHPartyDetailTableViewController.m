//
//  PTHPartyDetailTableViewController.m
//  Party Hunt
//
//  Created by Jared McFarland on 10/12/14.
//  Copyright (c) 2014 Jared Colin McFarland. All rights reserved.
//

#import "PTHPartyDetailTableViewController.h"
#import <Parse/Parse.h>
#import "PTHPartyTableViewCell.h"
#import "PTHPartyPhotoTableViewCell.h"
#import "PTHAddressTableViewCell.h"
#import "PTHPartyDescriptionTableViewCell.h"
#import "PTHConstants.h"
#import "PTHUtility.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface PTHPartyDetailTableViewController () <PTHPartyTableViewCellDelegate>

@property (weak, nonatomic) IBOutlet UIButton *joinButton;
@property (weak, nonatomic) IBOutlet UIButton *maybeButton;
@property (weak, nonatomic) IBOutlet UIButton *declineButton;
@property (weak, nonatomic) IBOutlet PTHPartyTableViewCell *partyCell;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UITextView *aboutTextView;
@property (weak, nonatomic) IBOutlet PTHPartyPhotoTableViewCell *photoCell;
@property (weak, nonatomic) IBOutlet PTHAddressTableViewCell *addressCell;
@property (weak, nonatomic) IBOutlet PTHPartyDescriptionTableViewCell *partyDescriptionCell;
@property (weak, nonatomic) IBOutlet UILabel *aboutLabel;

@end

@implementation PTHPartyDetailTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Self-sizing table view cells in iOS 8 require that the rowHeight property of the table view be set to the constant UITableViewAutomaticDimension
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    // Self-sizing table view cells in iOS 8 are enabled when the estimatedRowHeight property of the table view is set to a non-zero value.
    // Setting the estimated row height prevents the table view from calling tableView:heightForRowAtIndexPath: for every row in the table on first load;
    // it will only be called as cells are about to scroll onscreen. This is a major performance optimization.
    self.tableView.estimatedRowHeight = 82.0; // set this to whatever your "average" cell height is; it doesn't need to be very accurate}
    
    NSURL *eventPhotoURL = [NSURL URLWithString:self.party[@"cover"][@"source"]];
    [self.photoCell.partyPhotoImageView sd_setImageWithURL:eventPhotoURL];
    

    
    NSArray *upvoters = self.party[kPTHPartyUpvotersKey];
    BOOL isUpvotedByCurrentUser = [PTHUtility userArray:upvoters containsUser:[PFUser currentUser]];
    [self.partyCell setUpvoteStatus:isUpvotedByCurrentUser];
    
    self.partyCell.nameLabel.text = self.party[kPTHPartyNameKey];
    self.partyCell.upvoteCountLabel.text = [NSString stringWithFormat:@"%@", self.party[kPTHPartyUpvoteCountKey]];
    self.partyCell.commentCountLabel.text = [NSString stringWithFormat:@"%@", self.party[kPTHPartyCommentCountKey]];
    self.partyCell.locationLabel.text = self.party[kPTHPartyLocationKey];
    self.partyCell.delegate = self;
    
    NSDateFormatter *hourFormatter = [[NSDateFormatter alloc] init];
    [hourFormatter setDateFormat:@"ha"];
    
    NSDate *startDate = [self.party objectForKey:kPTHPartyStartTimeKey];
    NSString *startTime = [[hourFormatter stringFromDate:startDate] lowercaseString];
    
    NSDate *endDate = [self.party objectForKey:kPTHPartyEndTimeKey];
    NSString *endTime = [[hourFormatter stringFromDate:endDate] lowercaseString];
    
    NSString *hoursString = [NSString stringWithFormat:@"%@ - %@", startTime, endTime];
    
    if (!startTime)
    {
        hoursString = nil;
    }
    
    if (!endTime)
    {
        hoursString = startTime;
    }
    
    self.partyCell.hoursLabel.text = hoursString;
    
    self.addressCell.addressLabel.text = [NSString stringWithFormat:@"%@\n%@, %@ %@",self.party[kPTHPartyVenueKey][@"street"],
                                                                          self.party[kPTHPartyVenueKey][@"city"],
                                                                          self.party[kPTHPartyVenueKey][@"state"],
                                                                          self.party[kPTHPartyVenueKey][@"zip"]];
    
    self.partyDescriptionCell.partyDescriptionLabel.text = self.party[kPTHPartyDescriptionKey];
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.partyCell setNeedsUpdateConstraints];
    [self.partyCell updateConstraintsIfNeeded];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 2)
    {
        // Load comments view controller
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (section == 0)
    {
        return 4;
    } else
    {
        return 1;
    }
}


#pragma mark - PTHPartyTableViewCellDelegate

- (void)partyTableViewCell:(PTHPartyTableViewCell *)partyTableViewCell didTapUpvoteButton:(UIButton *)button {
    
    // Disable the button so users cannot send duplicate requests
    [partyTableViewCell shouldEnableUpvoteButton:NO];
    
    BOOL upvoted = !button.selected;
    [partyTableViewCell setUpvoteStatus:upvoted];
    
    NSString *originalUpvoteCount = partyTableViewCell.upvoteCountLabel.text;
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    
    NSNumber *upvoteCount = [numberFormatter numberFromString:partyTableViewCell.upvoteCountLabel.text];
    if (upvoted) {
        upvoteCount = [NSNumber numberWithInt:[upvoteCount intValue] + 1];
    } else {
        if ([upvoteCount intValue] > 0) {
            upvoteCount = [NSNumber numberWithInt:[upvoteCount intValue] - 1];
        }
    }
    
    partyTableViewCell.upvoteCountLabel.text = [numberFormatter stringFromNumber:upvoteCount];
    
    if (upvoted) {
        [PTHUtility upvotePartyInBackground:self.party block:^(BOOL succeeded, NSError *error) {
            PTHPartyTableViewCell *actualTableViewCell = self.partyCell;
            [actualTableViewCell shouldEnableUpvoteButton:YES];
            [actualTableViewCell setUpvoteStatus:succeeded];
            
            if (!succeeded) {
                actualTableViewCell.upvoteCountLabel.text = originalUpvoteCount;
            } else
            {
                [self.party addUniqueObject:[PFUser currentUser] forKey:@"upvoters"];
            }
        }];
    } else {
        [PTHUtility undoUpvotePartyInBackground:self.party block:^(BOOL succeeded, NSError *error) {
            PTHPartyTableViewCell *actualTableViewCell = self.partyCell;
            [actualTableViewCell shouldEnableUpvoteButton:YES];
            [actualTableViewCell setUpvoteStatus:!succeeded];
            
            if (!succeeded) {
                actualTableViewCell.upvoteCountLabel.text = originalUpvoteCount;
            } else
            {
                [self.party removeObject:[PFUser currentUser] forKey:@"upvoters"];
            }
        }];
    }
}

@end
