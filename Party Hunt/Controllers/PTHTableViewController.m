//
//  PTHTableViewController.m
//  Party Hunt
//
//  Created by Jared McFarland on 9/21/14.
//  Copyright (c) 2014 Jared Colin McFarland. All rights reserved.
//

#import "PTHTableViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import "PTHPartyTableViewCell.h"
#import "PTHUtility.h"
#import "PTHCache.h"
#import "PTHConstants.h"

static NSString *CellIdentifier = @"PartyCell";


@interface PTHTableViewController () <PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate, PTHPartyTableViewCellDelegate>

@property (nonatomic, strong) NSMutableDictionary *outstandingCellQueries;

// A dictionary of offscreen cells that are used within the tableView:heightForRowAtIndexPath: method to
// handle the height calculations. These are never drawn onscreen. The dictionary is in the format:
//      { NSString *reuseIdentifier : UITableViewCell *offscreenCell, ... }
@property (strong, nonatomic) NSMutableDictionary *offscreenCells;

@end

@implementation PTHTableViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        self.parseClassName = kPTHPartyClassKey;
        self.outstandingCellQueries = [NSMutableDictionary dictionary];
        self.offscreenCells = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Self-sizing table view cells in iOS 8 require that the rowHeight property of the table view be set to the constant UITableViewAutomaticDimension
    // self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    // Self-sizing table view cells in iOS 8 are enabled when the estimatedRowHeight property of the table view is set to a non-zero value.
    // Setting the estimated row height prevents the table view from calling tableView:heightForRowAtIndexPath: for every row in the table on first load;
    // it will only be called as cells are about to scroll onscreen. This is a major performance optimization.
    // self.tableView.estimatedRowHeight = 66.0; // set this to whatever your "average" cell height is; it doesn't need to be very accurate
    
    PFUser *user = [PFUser currentUser];
    if (user)
    {
        [PTHUtility updateFacebookEventsForUser:user];
    } else
    {
        [self beginLogin];
    }
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self loadObjects];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object
{
    
    static NSString *CellIdentifier = @"PartyCell";
    
    PTHPartyTableViewCell *cell = (PTHPartyTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[PTHPartyTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
   [self configureCell:cell forObject:object atIndexPath:indexPath];
    
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
    
    return cell;
}

- (void)configureCell:(PTHPartyTableViewCell *)cell forObject:(PFObject *)object atIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *attributesForParty = [[PTHCache sharedCache] attributesForParty:object];
    
    if (attributesForParty)
    {
        [cell setUpvoteStatus:[[PTHCache sharedCache] isPartyUpvotedByCurrentUser:object]];
        
        if (cell.upvoteButton.alpha < 1.0f)
        {
            [UIView animateWithDuration:0.200f animations:^{
                cell.upvoteButton.alpha = 1.0f;
            }];
        }
    } else {
        
        cell.upvoteButton.alpha = 0.0f;
        
        @synchronized(self)
        {
            // check if we can update the cache
            NSNumber *outstandingCellQueryStatus = [self.outstandingCellQueries objectForKey:@(indexPath.row)];
            if (!outstandingCellQueryStatus)
            {
                PFQuery *query = [PTHUtility queryForActivitiesOnParty:object cachePolicy:kPFCachePolicyNetworkOnly];
                //[self.outstandingCellQueries setObject:@(YES) forKey:@(indexPath.row)];
                [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                    @synchronized(self)
                    {
                        [self.outstandingCellQueries removeObjectForKey:@(indexPath.row)];
                        
                        if (error)
                        {
                            return;
                        }
                        
                        NSMutableArray *upvoters = [NSMutableArray array];
                        NSMutableArray *commenters = [NSMutableArray array];
                        
                        BOOL isUpvotedByCurrentUser = NO;
                        
                        for (PFObject *activity in objects)
                        {
                            if ([[activity objectForKey:kPTHActivityTypeKey] isEqualToString:kPTHActivityTypeUpvote] && [activity objectForKey:kPTHActivityFromUserKey])
                            {
                                [upvoters addObject:[activity objectForKey:kPTHActivityFromUserKey]];
                            } else if ([[activity objectForKey:kPTHActivityTypeKey] isEqualToString:kPTHActivityTypeComment] && [activity objectForKey:kPTHActivityFromUserKey])
                            {
                                [commenters addObject:[activity objectForKey:kPTHActivityFromUserKey]];
                            }
                            
                            if ([[[activity objectForKey:kPTHActivityFromUserKey] objectId] isEqualToString:[[PFUser currentUser] objectId]])
                            {
                                if ([[activity objectForKey:kPTHActivityTypeKey] isEqualToString:kPTHActivityTypeUpvote])
                                {
                                    isUpvotedByCurrentUser = YES;
                                }
                            }
                        }
                        
                        [[PTHCache sharedCache] setAttributesForParty:object upvoters:upvoters commenters:commenters upvotedByCurrentUser:isUpvotedByCurrentUser];
                        
                        [cell setUpvoteStatus:[[PTHCache sharedCache] isPartyUpvotedByCurrentUser:object]];
                        
                        if (cell.upvoteButton.alpha < 1.0f)
                        {
                            [UIView animateWithDuration:0.200f animations:^{
                                cell.upvoteButton.alpha = 1.0f;
                            }];
                        }
                    }
                }];
            }
        }
    }
    
    cell.nameLabel.text = [object valueForKey:@"name"];
    //cell.bylineLabel.text = [object objectForKey:@"description"];
    
    cell.upvoteCountLabel.text = [NSString stringWithFormat:@"%@",[object valueForKey:@"upvoteCount"]];
    cell.commentCountLabel.text = [NSString stringWithFormat:@"%@",[object valueForKey:@"commentCount"]];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
    
    NSDateFormatter *hourFormatter = [[NSDateFormatter alloc] init];
    [hourFormatter setDateFormat:@"ha"];
    
    NSString *startTime = [object valueForKey:@"start_time"];
    NSDate *startDate = [dateFormatter dateFromString:startTime];
    startTime = [[hourFormatter stringFromDate:startDate] lowercaseString];
    
    NSString *endTime = [object valueForKey:@"end_time"];
    NSDate *endDate = [dateFormatter dateFromString:endTime];
    endTime = [[hourFormatter stringFromDate:endDate] lowercaseString];
    
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
    cell.locationLabel.text = [object valueForKey:@"location"];
    cell.delegate = self;
}


- (PFQuery *)queryForTable
{
    PFQuery *query = [PFQuery queryWithClassName:@"Party"];
    [query orderByDescending:@"upvoteCount"];
    return query;
}

#pragma mark - PTHPartyTableViewCellDelegate

- (void)partyTableViewCell:(PTHPartyTableViewCell *)partyTableViewCell didTapUpvoteButton:(UIButton *)button {

    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:partyTableViewCell];
    PFObject *party = self.objects[indexPath.row];
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
        [[PTHCache sharedCache] incrementUpvoteCountForParty:party];
    } else {
        if ([upvoteCount intValue] > 0) {
            upvoteCount = [NSNumber numberWithInt:[upvoteCount intValue] - 1];
        }
        [[PTHCache sharedCache] decrementUpvoteCountForParty:party];
    }
    
   [[PTHCache sharedCache] setPartyIsUpvotedByCurrentUser:party upvoted:upvoted];
    
    partyTableViewCell.upvoteCountLabel.text = [numberFormatter stringFromNumber:upvoteCount];
    
    if (upvoted) {
        [PTHUtility upvotePartyInBackground:party block:^(BOOL succeeded, NSError *error) {
            PTHPartyTableViewCell *actualTableViewCell = (PTHPartyTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
            [actualTableViewCell shouldEnableUpvoteButton:YES];
            [actualTableViewCell setUpvoteStatus:succeeded];
            
            if (!succeeded) {
                actualTableViewCell.upvoteCountLabel.text = originalUpvoteCount;
            }
        }];
    } else {
        [PTHUtility undoUpvotePartyInBackground:party block:^(BOOL succeeded, NSError *error) {
            PTHPartyTableViewCell *actualTableViewCell = (PTHPartyTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
            [actualTableViewCell shouldEnableUpvoteButton:YES];
            [actualTableViewCell setUpvoteStatus:!succeeded];
            
            if (!succeeded) {
                actualTableViewCell.upvoteCountLabel.text = originalUpvoteCount;
            }
        }];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 82;
}

#pragma mark - PFLogInViewControllerDelegate

-(BOOL)logInViewController:(PFLogInViewController *)logInController shouldBeginLogInWithUsername:(NSString *)username password:(NSString *)password
{
    // Check if both fields are completed
    if (username && password && username.length && password.length)
    {
        return YES; // Begin login process
    }
    
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Missing Information", nil) message:NSLocalizedString(@"Username AND Password both required!", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
    return NO; // Interrupt login process
    
}

- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user
{
    [self dismissViewControllerAnimated:YES completion:NULL];
    [PTHUtility updateFacebookEventsForUser:user];
}

-(void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error
{
    NSString *errorMessage = [error localizedDescription];
    
    [[[UIAlertView alloc] initWithTitle:@"Failed to Login!"
                                message:errorMessage
                               delegate:nil
                      cancelButtonTitle:@"ok"
                      otherButtonTitles:nil] show];
    
    NSLog(@"Failed to log in with error: %@", [error localizedDescription]);
}

-(void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController
{
    NSLog(@"User dismissed the logInViewController");
}

#pragma mark - PFSignUpViewControllerDelegate

// Sent to the delegate to determine whether the sign up request should be submitted to the server
-(BOOL)signUpViewController:(PFSignUpViewController *)signUpController shouldBeginSignUp:(NSDictionary *)info
{
    BOOL informationComplete = YES;
    
    // loop through all of the submitted data
    for (id key in info)
    {
        NSString *field = [info objectForKey:key];
        if (!field || !field.length)
        {
            informationComplete = NO;
            break;
        }
    }
    
    // Display an alert if a field wasn't completed
    if (!informationComplete) {
        [[[UIAlertView alloc] initWithTitle:@"Missing Information"
                                    message:@"Make sure you fill out all of the information!"
                                   delegate:nil
                          cancelButtonTitle:@"ok"
                          otherButtonTitles:nil] show];
    }
    
    return informationComplete;
}

// Sent to the delegate when a PFUser is signed up.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user {
    
    [self dismissViewControllerAnimated:YES completion:NULL]; // Dismiss the PFSignUpViewController
}

// Sent to the delegate when the sign up attempt fails.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didFailToSignUpWithError:(NSError *)error {
    NSString *errorMessage = [error localizedDescription];
    
    [[[UIAlertView alloc] initWithTitle:@"Failed to Sign Up!"
                                message:errorMessage
                               delegate:nil
                      cancelButtonTitle:@"ok"
                      otherButtonTitles:nil] show];
    
    NSLog(@"Failed to sign up with error: %@", errorMessage);
}

// Sent to the delegate when the sign up screen is dismissed.
- (void)signUpViewControllerDidCancelSignUp:(PFSignUpViewController *)signUpController {
    NSLog(@"User dismissed the signUpViewController");
}

#pragma mark - Log In

- (void)beginLogin
{
    // Create the log in view controller
    PFLogInViewController *logInViewController = [[PFLogInViewController alloc] init];
    [logInViewController setDelegate:self];
    
    // Create the sign up view controller
    PFSignUpViewController *signUpViewController = [[PFSignUpViewController alloc] init];
    [signUpViewController setDelegate:self];
    
    // Assign our sign up controll to be displayed from the login controller
    [logInViewController setSignUpController:signUpViewController];
    
    [logInViewController setFacebookPermissions:[NSArray arrayWithObjects:@"public_profile",@"user_friends",@"email",@"user_events", nil]];
    [logInViewController setFields: PFLogInFieldsUsernameAndPassword | PFLogInFieldsLogInButton | PFLogInFieldsSignUpButton | PFLogInFieldsTwitter | PFLogInFieldsFacebook | PFLogInFieldsDismissButton];
    
    // Present the log in view controller
    [self presentViewController:logInViewController animated:YES completion:NULL];
}

- (IBAction)logOut {
    // clear cache
    [[PTHCache sharedCache] clear];
    
    // clear NSUserDefaults
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kPTHUserDefaultsCacheFacebookFriendsKey];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kPTHUserDefaultsActivityFeedViewControllerLastRefreshKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // Unsubscribe from push notifications by removing the user association from the current installation.
    // [[PFInstallation currentInstallation] removeObjectForKey:kPAPInstallationUserKey];
    // [[PFInstallation currentInstallation] saveInBackground];
    
    // Clear all caches
    [PFQuery clearAllCachedResults];
    
    // Log out
    [PFUser logOut];
    
    [self beginLogin];

}

@end
