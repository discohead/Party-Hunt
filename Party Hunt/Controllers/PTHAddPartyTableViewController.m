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

@interface PTHAddPartyTableViewController ()

@property (strong,nonatomic) NSArray *eventsCreated;
@property (strong,nonatomic) NSArray *eventsAttending;
@property (strong,nonatomic) NSArray *eventsMaybe;
@property (strong,nonatomic) NSArray *eventsNotReplied;
@property (strong,nonatomic) NSArray *eventsDeclined;

@end

@implementation PTHAddPartyTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.eventsCreated = [[[PFUser currentUser] objectForKey:@"fbEventsCreated"] objectForKey:@"data"];
    self.eventsAttending = [[[PFUser currentUser] objectForKey:@"fbEventsAttending"] objectForKey:@"data"];
    self.eventsMaybe = [[[PFUser currentUser] objectForKey:@"fbEventsMaybe"] objectForKey:@"data"];
    self.eventsNotReplied = [[[PFUser currentUser] objectForKey:@"fbEventsNotReplied"] objectForKey:@"data"];
    self.eventsDeclined = [[[PFUser currentUser] objectForKey:@"fbEventsDeclined"] objectForKey:@"data"];

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
            rows = [self.eventsCreated count];
            break;
        
        case 2:
            rows = [self.eventsAttending count];
            break;
            
        case 3:
            rows = [self.eventsMaybe count];
            break;
            
        case 4:
            rows = [self.eventsNotReplied count];
            break;
            
        case 5:
            rows = [self.eventsDeclined count];
            break;
        
        default:
            break;
    }
    
    return rows;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    // Configure the cell...
    switch (indexPath.section)
    {
        case 0:
            cell.textLabel.text = @"Create Event";
            break;
        
        case 1:
            cell.textLabel.text = [[self.eventsCreated objectAtIndex:indexPath.row] objectForKey:@"name"];
            break;
        
        case 2:
            cell.textLabel.text = [[self.eventsAttending objectAtIndex:indexPath.row] objectForKey:@"name"];
            break;
            
        case 3:
            cell.textLabel.text = [[self.eventsMaybe objectAtIndex:indexPath.row] objectForKey:@"name"];
            break;
            
        case 4:
            cell.textLabel.text = [[self.eventsNotReplied objectAtIndex:indexPath.row] objectForKey:@"name"];
            break;
            
        case 5:
            cell.textLabel.text = [[self.eventsDeclined objectAtIndex:indexPath.row] objectForKey:@"name"];
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
            [self addPartyFromFBEvent:self.eventsCreated[indexPath.row]];
            break;
            
        case 2:
            [self addPartyFromFBEvent:self.eventsAttending[indexPath.row]];
            break;
            
        case 3:
            [self addPartyFromFBEvent:self.eventsMaybe[indexPath.row]];
            break;
            
        case 4:
            [self addPartyFromFBEvent:self.eventsNotReplied[indexPath.row]];
            break;
            
        case 5:
            [self addPartyFromFBEvent:self.eventsDeclined[indexPath.row]];
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)addPartyFromFBEvent:(NSDictionary *)fbEvent
{
    //NSLog(@"fbEvent.description = %@", [fbEvent valueForKey:@"description"]);
    NSNumber *eventId = [fbEvent valueForKey:@"id"];
    PFObject *party = [PFObject objectWithClassName:@"Party" dictionary:fbEvent];
    [party setObject:eventId forKey:@"fbEventId"];
    
    [party setObject:[PFUser currentUser] forKey:@"user"];
    [party setObject:@(0) forKey:@"commentCount"];
    [party setObject:@(1) forKey:@"upvoteCount"];
    [[PTHCache sharedCache] setPartyIsUpvotedByCurrentUser:party upvoted:YES];
    
    NSNumber *latitude = [fbEvent valueForKeyPath:@"venue.latitude"];
    NSNumber *longitude = [fbEvent valueForKeyPath:@"venue.longitude"];
    
    if (latitude && longitude)
    {
        PFGeoPoint *geoLocation = [PFGeoPoint geoPointWithLatitude:latitude.doubleValue longitude:longitude.doubleValue];
        [party setObject:geoLocation forKey:@"geoLocation"];
    }
    
    [party saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!succeeded)
        {
            NSLog(@"Error saving party: %@", [error localizedDescription]);
        }
    }];
}

@end
