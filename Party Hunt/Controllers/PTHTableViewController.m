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


@interface PTHTableViewController () <PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate, PTHPartyTableViewCellDelegate>

@property (nonatomic, strong) NSMutableDictionary *outstandingCellQueries;

@end

@implementation PTHTableViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        self.parseClassName = kPTHPartyClassKey;
        self.outstandingCellQueries = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    PFUser *user = [PFUser currentUser];
    if (user)
    {
        [PTHUtility updateFacebookEventsForUser:user];
    } else
    {
        [self beginLogin];
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object
{
    
    static NSString *CellIdentifier = @"PartyCell";
    
    PTHPartyTableViewCell *cell = (PTHPartyTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[PTHPartyTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
   [self configureCell:cell forObject:object atIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(PTHPartyTableViewCell *)cell forObject:(PFObject *)object atIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *attributesForParty = [[PTHCache sharedCache] attributesForParty:object];
    
    if (attributesForParty)
    {
        [cell setUpvoteStatus:[[PTHCache sharedCache] isPartyUpvotedByCurrentUser:object]];
        cell.voteCountLabel.text = [[[PTHCache sharedCache] upvoteCountForParty:object] description];
        cell.commentCountLabel.text = [[[PTHCache sharedCache] commentCountForParty:object] description];
    } else {
        
        @synchronized(self)
        {
            // check if we can update the cache
            NSNumber *outstandingCellQueryStatus = [self.outstandingCellQueries objectForKey:@(indexPath.row)];
            if (!outstandingCellQueryStatus)
            {
                PFQuery *query = [PTHUtility queryForActivitiesOnParty:object cachePolicy:kPFCachePolicyNetworkOnly];
                [self.outstandingCellQueries setObject:query forKey:@(indexPath.row)];
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
                        cell.voteCountLabel.text = [[[PTHCache sharedCache] upvoteCountForParty:object] description];
                        cell.commentCountLabel.text = [[[PTHCache sharedCache] commentCountForParty:object] description];
                    }
                }];
            }
        }
    }
    cell.titleLabel.text = [object valueForKey:@"name"];
    //cell.bylineLabel.text = [object objectForKey:@"description"];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
    
    NSDateFormatter *hourFormatter = [[NSDateFormatter alloc] init];
    [hourFormatter setDateFormat:@"h a"];
    
    NSString *startTime = [object valueForKey:@"start_time"];
    NSDate *startDate = [dateFormatter dateFromString:startTime];
    startTime = [hourFormatter stringFromDate:startDate];
    
    NSString *endTime = [object valueForKey:@"end_time"];
    NSDate *endDate = [dateFormatter dateFromString:endTime];
    endTime = [hourFormatter stringFromDate:endDate];
    
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
    NSString *location = [object valueForKey:@"location"];
    if ([location length] > 20)
    {
        location = [location substringToIndex:20];
    }
    
    cell.locationLabel.text = location;
    cell.delegate = self;
}

#pragma mark - PTHPartyTableViewCellDelegate

- (void)partyTableViewCell:(PTHPartyTableViewCell *)partyTableViewCell didTapUpvoteButton:(UIButton *)button {

    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:partyTableViewCell];
    PFObject *party = self.objects[indexPath.row];
    // Disable the button so users cannot send duplicate requests
    [partyTableViewCell shouldEnableUpvoteButton:NO];
    
    BOOL upvoted = !button.selected;
    [partyTableViewCell setUpvoteStatus:upvoted];
    
    NSString *originalUpvoteCount = partyTableViewCell.voteCountLabel.text;
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    
    NSNumber *upvoteCount = [numberFormatter numberFromString:partyTableViewCell.voteCountLabel.text];
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
    
    partyTableViewCell.voteCountLabel.text = [numberFormatter stringFromNumber:upvoteCount];
    
    if (upvoted) {
        [PTHUtility upvotePartyInBackground:party block:^(BOOL succeeded, NSError *error) {
            PTHPartyTableViewCell *actualTableViewCell = (PTHPartyTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
            [actualTableViewCell shouldEnableUpvoteButton:YES];
            [actualTableViewCell setUpvoteStatus:succeeded];
            
            if (!succeeded) {
                actualTableViewCell.voteCountLabel.text = originalUpvoteCount;
            }
        }];
    } else {
        [PTHUtility undoUpvotePartyInBackground:party block:^(BOOL succeeded, NSError *error) {
            PTHPartyTableViewCell *actualTableViewCell = (PTHPartyTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
            [actualTableViewCell shouldEnableUpvoteButton:YES];
            [actualTableViewCell setUpvoteStatus:!succeeded];
            
            if (!succeeded) {
                actualTableViewCell.voteCountLabel.text = originalUpvoteCount;
            }
        }];
    }
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


@end
