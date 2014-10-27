//
//  PTHPartyDetailTableViewController.m
//  Party Hunt
//
//  Created by Jared McFarland on 10/12/14.
//  Copyright (c) 2014 Jared Colin McFarland. All rights reserved.
//

#import "PTHPartyDetailTableViewController.h"
#import <Parse/Parse.h>
#import "PTHPartyDetailTableViewCell.h"
#import "PTHConstants.h"
#import "PTHUtility.h"

@interface PTHPartyDetailTableViewController ()

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
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell;
    
    // Configure the cell...
    if (indexPath.section == 0 && indexPath.row == 0)
    {
        PTHPartyDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kPTHDetailCellIdentifier forIndexPath:indexPath];
        cell.nameLabel.text = [self.party objectForKey:kPTHPartyNameKey];
        cell.locationLabel.text = [self.party objectForKey:kPTHPartyLocationKey];
        cell.streetAddressLabel.text = [self.party objectForKey:kPTHPartyVenueKey][@"street"];
        cell.cityStateZipLabel.text = [NSString stringWithFormat:@"%@, %@ %@",[self.party objectForKey:kPTHPartyVenueKey][@"city"],
                                                                              [self.party objectForKey:kPTHPartyVenueKey][@"state"],
                                                                              [self.party objectForKey:kPTHPartyVenueKey][@"zip"]];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"EEE, MMM d, yyyy"];
        cell.dateLabel.text = [dateFormatter stringFromDate:[self.party objectForKey:kPTHPartyStartTimeKey]];
        
        [dateFormatter setDateFormat:@"ha"];
        NSDate *startDate = [self.party valueForKey:kPTHPartyStartTimeKey];
        NSString *startTime = [[dateFormatter stringFromDate:startDate] lowercaseString];
        
        NSDate *endDate = [self.party valueForKey:kPTHPartyEndTimeKey];
        NSString *endTime = [[dateFormatter stringFromDate:endDate] lowercaseString];
        
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

        NSTimeInterval timeSinceCreated = [[NSDate date] timeIntervalSinceDate:self.party.createdAt];
        float ageInHours = timeSinceCreated/60.0/60.0;
        cell.ageLabel.text = [NSString stringWithFormat:@"%.0fh",ageInHours];
        
        [cell setNeedsUpdateConstraints];
        [cell updateConstraintsIfNeeded];
        
        return cell;
    }
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
