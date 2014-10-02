//
//  PTHNewestPartiesViewController.m
//  Party Hunt
//
//  Created by Jared McFarland on 10/1/14.
//  Copyright (c) 2014 Jared Colin McFarland. All rights reserved.
//

#import "PTHNewestPartiesViewController.h"

@interface PTHNewestPartiesViewController ()

@end

@implementation PTHNewestPartiesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tabBarController.navigationItem.title = @"Newest Parties";
}

- (void)configureCell:(PTHPartyTableViewCell *)cell forObject:(PFObject *)party atIndexPath:(NSIndexPath *)indexPath
{
    
    NSArray *upvoters = [party objectForKey:kPTHPartyUpvotersKey];
    BOOL isUpvotedByCurrentUser = [PTHUtility userArray:upvoters containsUser:[PFUser currentUser]];
    [cell setUpvoteStatus:isUpvotedByCurrentUser];
    
    cell.nameLabel.text = [party valueForKey:kPTHPartyNameKey];
    //cell.bylineLabel.text = [object objectForKey:@"description"];
    
    NSTimeInterval timeSinceCreated = [[NSDate date] timeIntervalSinceDate:party.createdAt];
    float ageInHours = timeSinceCreated/60.0/60.0;
    
    cell.upvoteCountLabel.text = [NSString stringWithFormat:@"%@",[party valueForKey:kPTHPartyUpvoteCountKey]];
    cell.commentImageView.image = nil;
    cell.commentCountLabel.text = [NSString stringWithFormat:@"%.0fh",ageInHours];
    NSDateFormatter *hourFormatter = [[NSDateFormatter alloc] init];
    [hourFormatter setDateFormat:@"ha"];
    
    NSDate *startDate = [party valueForKey:kPTHPartyStartTimeKey];
    NSString *startTime = [[hourFormatter stringFromDate:startDate] lowercaseString];
    
    NSDate *endDate = [party valueForKey:kPTHPartyEndTimeKey];
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
    
    cell.hoursLabel.text = hoursString;
    cell.locationLabel.text = [party valueForKey:kPTHPartyLocationKey];
    cell.delegate = self;
}

- (PFQuery *)queryForTable
{
    PFQuery *query = [PFQuery queryWithClassName:kPTHPartyClassKey];
    [self constrainQueryToSelectedDate:query];
    PFGeoPoint *currentLocation = [PFGeoPoint geoPointWithLocation:self.locationManager.location];
    [query whereKey:kPTHPartyGeoLocationKey nearGeoPoint:currentLocation withinMiles:kPTHAreaOfInterest];
    [query orderByDescending:@"createdAt"];
    return query;
}

@end
