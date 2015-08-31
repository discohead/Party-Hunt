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
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.tabBarController.navigationItem.title = @"Newest";
}

- (void)configureCell:(PTHPartyTableViewCell *)cell forObject:(PFObject *)party atIndexPath:(NSIndexPath *)indexPath
{
    
    NSArray *upvoters = [party objectForKey:kPTHPartyUpvotersKey];
    BOOL isUpvotedByCurrentUser = [PTHUtility userArray:upvoters containsUser:[PFUser currentUser]];
    [cell setUpvoteStatus:isUpvotedByCurrentUser];
    
    cell.nameLabel.text = [party objectForKey:kPTHPartyNameKey];
    //cell.bylineLabel.text = [object objectForKey:@"description"];
    
    NSTimeInterval timeSinceCreated = [[NSDate date] timeIntervalSinceDate:party.createdAt];
    float ageInHours = timeSinceCreated/60.0/60.0;
    
    cell.upvoteCountLabel.text = [NSString stringWithFormat:@"%@",[party objectForKey:kPTHPartyUpvoteCountKey]];
    cell.commentImageView.image = nil;
    cell.commentCountLabel.text = [NSString stringWithFormat:@"%.0fh",ageInHours];
    NSDateFormatter *hourFormatter = [[NSDateFormatter alloc] init];
    [hourFormatter setDateFormat:@"ha"];
    
    NSDate *startDate = [party objectForKey:kPTHPartyStartTimeKey];
    NSString *startTime = [[hourFormatter stringFromDate:startDate] lowercaseString];
    
    NSDate *endDate = [party objectForKey:kPTHPartyEndTimeKey];
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
    cell.locationLabel.text = [party objectForKey:kPTHPartyLocationKey];
    cell.delegate = self;
}

- (PFQuery *)queryForTable
{
    PFQuery *query = [PFQuery queryWithClassName:kPTHPartyClassKey];
    /*
    NSDate *selectedDate = self.datePicker.selectedDate;
    if (!selectedDate)
    {
        selectedDate = [NSDate date];
    }
    
    [PTHUtility constrainQuery:query toDate:selectedDate];
     */
    PFGeoPoint *currentLocation = [PFGeoPoint geoPointWithLocation:self.locationManager.location];
    [query whereKey:kPTHPartyGeoLocationKey nearGeoPoint:currentLocation withinMiles:kPTHAreaOfInterest];
    [query orderByDescending:@"createdAt"];
    return query;
}

@end
