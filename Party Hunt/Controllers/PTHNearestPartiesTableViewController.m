//
//  PTHNearestPartiesTableViewController.m
//  Party Hunt
//
//  Created by Jared McFarland on 10/1/14.
//  Copyright (c) 2014 Jared Colin McFarland. All rights reserved.
//

#import "PTHNearestPartiesTableViewController.h"

@interface PTHNearestPartiesTableViewController ()

@end

@implementation PTHNearestPartiesTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.tabBarController.navigationItem.title = @"Nearest Parties";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)configureCell:(PTHPartyTableViewCell *)cell forObject:(PFObject *)party atIndexPath:(NSIndexPath *)indexPath
{
    
    NSArray *upvoters = [party objectForKey:kPTHPartyUpvotersKey];
    BOOL isUpvotedByCurrentUser = [PTHUtility userArray:upvoters containsUser:[PFUser currentUser]];
    [cell setUpvoteStatus:isUpvotedByCurrentUser];
    
    cell.nameLabel.text = [party valueForKey:kPTHPartyNameKey];
    //cell.bylineLabel.text = [object objectForKey:@"description"];
    
    PFGeoPoint *geoPoint = [party objectForKey:kPTHPartyGeoLocationKey];
    CLLocation *partyLocation = [[CLLocation alloc] initWithLatitude:geoPoint.latitude longitude:geoPoint.longitude];
    CLLocationDistance distance = [self.locationManager.location distanceFromLocation:partyLocation];
    double distanceInMiles = distance * 0.00062137;
    
    cell.upvoteCountLabel.text = [NSString stringWithFormat:@"%@",[party valueForKey:kPTHPartyUpvoteCountKey]];
    cell.commentImageView.image = nil;
    cell.commentCountLabel.text = [NSString stringWithFormat:@"%.1fmi",distanceInMiles];
    
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
    CLLocation *location = self.locationManager.location;
    PFGeoPoint *geoPoint = [PFGeoPoint geoPointWithLocation:location];
    [query whereKey:kPTHPartyGeoLocationKey nearGeoPoint:geoPoint withinMiles:kPTHAreaOfInterest];
    [self constrainQueryToSelectedDate:query];
    return query;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
