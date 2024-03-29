//
//  PTHTopPartiesTableViewController.m
//  Party Hunt
//
//  Created by Jared McFarland on 10/1/14.
//  Copyright (c) 2014 Jared Colin McFarland. All rights reserved.
//

#import "PTHTopPartiesTableViewController.h"

@interface PTHTopPartiesTableViewController ()

@end

@implementation PTHTopPartiesTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.tabBarController.navigationItem.title = @"Top Parties";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    
    [query orderByDescending:kPTHPartyUpvoteCountKey];
    
    return query;
}

- (void)configureCell:(PTHPartyTableViewCell *)cell forObject:(PFObject *)party atIndexPath:(NSIndexPath *)indexPath
{

    NSArray *upvoters = [party objectForKey:kPTHPartyUpvotersKey];
    BOOL isUpvotedByCurrentUser = [PTHUtility userArray:upvoters containsUser:[PFUser currentUser]];
    [cell setUpvoteStatus:isUpvotedByCurrentUser];
    
    cell.nameLabel.text = [party objectForKey:kPTHPartyNameKey];
    //cell.bylineLabel.text = [object objectForKey:@"description"];
    
    cell.upvoteCountLabel.text = [NSString stringWithFormat:@"%@",[party objectForKey:kPTHPartyUpvoteCountKey]];
    cell.commentCountLabel.text = [NSString stringWithFormat:@"%@",[party objectForKey:kPTHPartyCommentCountKey]];
    
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

@end
