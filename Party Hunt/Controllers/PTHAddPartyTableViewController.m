//
//  PTHAddPartyTableViewController.m
//  Party Hunt
//
//  Created by Jared McFarland on 9/23/14.
//  Copyright (c) 2014 Jared Colin McFarland. All rights reserved.
//

#import "PTHAddPartyTableViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import "PTHCache.h"
#import "PTHConstants.h"
#import "PTHUtility.h"

@interface PTHAddPartyTableViewController () <UIAlertViewDelegate, FBRequestConnectionDelegate>
- (IBAction)didPressCancelBarButton:(id)sender;

@end

@implementation PTHAddPartyTableViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        self.events = [NSMutableDictionary dictionary];
        [self getFbEventsForCurrentUser];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.refreshControl addTarget:self action:@selector(getFbEventsForCurrentUser) forControlEvents:UIControlEventValueChanged];
    
    // Self-sizing table view cells in iOS 8 require that the rowHeight property of the table view be set to the constant UITableViewAutomaticDimension
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    // Self-sizing table view cells in iOS 8 are enabled when the estimatedRowHeight property of the table view is set to a non-zero value.
    // Setting the estimated row height prevents the table view from calling tableView:heightForRowAtIndexPath: for every row in the table on first load;
    // it will only be called as cells are about to scroll onscreen. This is a major performance optimization.
    self.tableView.estimatedRowHeight = 82.0; // set this to whatever your "average" cell height is; it doesn't need to be very accurate

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    // Return the number of sections.
    return 6;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    // Return the number of rows in the section.
    NSInteger rows;
    
    switch (section)
    {
        case 0:
            rows = 1;
            break;
            
        case 1:
            rows = [self.events[kPTHFbEventsCreated] count];
            break;
        
        case 2:
            rows = [self.events[kPTHFbEventsAttending] count];
            break;
            
        case 3:
            rows = [self.events[kPTHFbEventsMaybe] count];
            break;
            
        case 4:
            rows = [self.events[kPTHFbEventsNotReplied] count];
            break;
            
        case 5:
            rows = [self.events[kPTHFbEventsDeclined] count];
            break;
        
        default:
            rows = 0;
            break;
    }
    
    return rows;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    
    // Configure the cell...
    switch (indexPath.section)
    {
        case 0:
            cell.textLabel.text = @"Create Event";
            break;
        
        case 1:
            cell.textLabel.text = self.events[kPTHFbEventsCreated][indexPath.row][@"name"];
            break;
        
        case 2:
            cell.textLabel.text = self.events[kPTHFbEventsAttending][indexPath.row][@"name"];
            break;
            
        case 3:
            cell.textLabel.text = self.events[kPTHFbEventsMaybe][indexPath.row][@"name"];
            break;
            
        case 4:
            cell.textLabel.text = self.events[kPTHFbEventsNotReplied][indexPath.row][@"name"];
            break;
            
        case 5:
            cell.textLabel.text = self.events[kPTHFbEventsDeclined][indexPath.row][@"name"];
        default:
            break;
    }
    
    return cell;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title;
    
    switch (section)
    {
        case 0:
            title = @"Submit a Non-Facebook Event";
            break;
            
        case 1:
            title = @"Events you created";
            break;
            
        case 2:
            title = @"Events you are attending";
            break;
            
        case 3:
            title = @"Events you may be attending";
            break;
            
        case 4:
            title = @"Events you have not replied to";
            break;
            
        case 5:
            title = @"Events you have declined";
            break;
            
        default:
            break;
    }
    
    return title;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section)
    {
        case 0:
            // TODO: create custom event page
            break;
            
        case 1:
            [self addPartyFromFBEvent:self.events[kPTHFbEventsCreated][indexPath.row]];
            break;
            
        case 2:
            [self addPartyFromFBEvent:self.events[kPTHFbEventsAttending][indexPath.row]];
            break;
            
        case 3:
            [self addPartyFromFBEvent:self.events[kPTHFbEventsMaybe][indexPath.row]];
            break;
            
        case 4:
            [self addPartyFromFBEvent:self.events[kPTHFbEventsNotReplied][indexPath.row]];
            break;
            
        case 5:
            [self addPartyFromFBEvent:self.events[kPTHFbEventsDeclined][indexPath.row]];
        default:
            break;
    }
    
}

- (void)addPartyFromFBEvent:(NSDictionary *)fbEvent
{
    NSMutableDictionary *mutableFbEvent = [fbEvent mutableCopy];
    [mutableFbEvent setObject:fbEvent[@"id"] forKey:kPTHPartyFbEventIdKey];
    [mutableFbEvent removeObjectForKey:@"id"];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
    
    if ([fbEvent objectForKey:kPTHPartyStartTimeKey])
    {
        NSString *startTimeString = [fbEvent objectForKey:kPTHPartyStartTimeKey];
        NSDate *startDate = [dateFormatter dateFromString:startTimeString];
        [mutableFbEvent setValue:startDate forKey:kPTHPartyStartTimeKey];
    }
    if ([fbEvent objectForKey:kPTHPartyEndTimeKey])
    {
        NSString *endTimeString = [fbEvent objectForKey:kPTHPartyEndTimeKey];
        NSDate *endDate = [dateFormatter dateFromString:endTimeString];
        [mutableFbEvent setValue:endDate forKey:kPTHPartyEndTimeKey];
    }
    
    PFObject *party = [PFObject objectWithClassName:kPTHPartyClassKey dictionary:mutableFbEvent];
    
    [party setObject:[PFUser currentUser] forKey:kPTHPartyUserKey];     
    [party setObject:@(0) forKey:kPTHPartyCommentCountKey];
    [party setObject:@(0) forKey:kPTHPartyUpvoteCountKey];
    [party addUniqueObject:[PFUser currentUser] forKey:kPTHPartyUpvotersKey];
    
    NSNumber *latitude = [fbEvent valueForKeyPath:@"venue.latitude"];
    NSNumber *longitude = [fbEvent valueForKeyPath:@"venue.longitude"];
    
    if (latitude && longitude)
    {
        PFGeoPoint *geoLocation = [PFGeoPoint geoPointWithLatitude:latitude.doubleValue longitude:longitude.doubleValue];
        [party setObject:geoLocation forKey:kPTHPartyGeoLocationKey];
    }
    
    [party saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!succeeded)
        {
            NSLog(@"Error saving party: %@", [error localizedDescription]);
        } else
        {
            [PTHUtility upvotePartyInBackground:party block:^(BOOL succeeded, NSError *error) {
                if (!succeeded)
                {
                    NSLog(@"Error upvoting party in background: %@", [error localizedDescription]);
                } else
                {
                    [self.delegate didAddParty:party];
                }
            }];
            NSLog(@"Party saved successfully");
        }
    }];
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)getFbEventsForCurrentUser
{
    if ([PFFacebookUtils isLinkedWithUser:[PFUser currentUser]])
    {
        NSArray *permissions = [[[FBSession activeSession] accessTokenData] permissions];
        
        if (![permissions containsObject:@"user_events"])
        {
            __block BOOL permissionGranted;
            
            [PFFacebookUtils reauthorizeUser:[PFUser currentUser] withPublishPermissions:[NSArray arrayWithObjects:@"public_profile",@"user_friends",@"email",@"user_events", nil] audience:FBSessionDefaultAudienceFriends block:^(BOOL succeeded, NSError *error) {
                if (!succeeded)
                {
                    NSLog(@"Error obtaining user_events permission: %@", [error localizedDescription]);
                    [self.events setObject:error forKey:@"authError"];
                }
                permissionGranted = succeeded;
            }];
            if (!permissionGranted)
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Permissions Error" message:@"This app does not have permission to access your Facebook Events" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Re-Authorize", nil];
                [alert show];
            }
        }
        
        FBRequest *createdRequest = [FBRequest requestForGraphPath:@"me/events/created?fields=name,description,start_time,end_time,location,venue,privacy"];
        FBRequest *attendingRequest = [FBRequest requestForGraphPath:@"me/events/attending?fields=name,description,start_time,end_time,location,venue,privacy"];
        FBRequest *maybeRequest = [FBRequest requestForGraphPath:@"me/events/maybe?fields=name,description,start_time,end_time,location,venue,privacy"];
        FBRequest *notRepliedRequest = [FBRequest requestForGraphPath:@"me/events/not_replied?fields=name,description,start_time,end_time,location,venue,privacy"];
        FBRequest *declinedRequest = [FBRequest requestForGraphPath:@"me/events/declined?fields=name,description,start_time,end_time,location,venue,privacy"];
        
        FBRequestConnection *requestConnection = [[FBRequestConnection alloc] init];
        
        [requestConnection addRequest:createdRequest completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            if (!error)
            {
                [self.events setObject:result[@"data"] forKey:kPTHFbEventsCreated];
            } else
            {
                [self.events setObject:error forKey:kPTHFbEventsCreated];
                NSLog(@"Error getting events/created: %@", [error localizedDescription]);
            }
        }];
        
        [requestConnection addRequest:attendingRequest completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            if (!error)
            {
                [self.events setObject:result[@"data"] forKey:kPTHFbEventsAttending];
            } else
            {
                [self.events setObject:error forKey:kPTHFbEventsAttending];
                NSLog(@"Error getting events/attending: %@", [error localizedDescription]);
            }
        }];
        
        [requestConnection addRequest:maybeRequest completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            if (!error)
            {
                [self.events setObject:result[@"data"] forKey:kPTHFbEventsMaybe];
            } else
            {
                [self.events setObject:error forKey:kPTHFbEventsMaybe];
                NSLog(@"Error getting events/maybe: %@", [error localizedDescription]);
            }
        }];
        
        [requestConnection addRequest:notRepliedRequest completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            if (!error)
            {
                [self.events setObject:result[@"data"] forKey:kPTHFbEventsNotReplied];
            } else
            {
                [self.events setObject:error forKey:kPTHFbEventsNotReplied];
                NSLog(@"Error getting events/not_replied: %@", [error localizedDescription]);
            }
        }];
        
        [requestConnection addRequest:declinedRequest completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            if (!error)
            {
                [self.events setObject:result[@"data"] forKey:kPTHFbEventsDeclined];
            } else
            {
                [self.events setObject:error forKey:kPTHFbEventsDeclined];
                NSLog(@"Error getting events/declined: %@", [error localizedDescription]);
            }
        }];
        requestConnection.delegate = self;
        [requestConnection start];
    } else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Login Error" message:@"No active Facebook session found" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Log in w/ Facebook", nil];
        [alert show];
    }
    
}

#pragma mark - FBRequestConnectionDelegate

- (void)requestConnectionDidFinishLoading:(FBRequestConnection *)connection fromCache:(BOOL)isCached
{
    [self.tableView reloadData];
    [self.refreshControl endRefreshing];
}

- (IBAction)didPressCancelBarButton:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}
@end
