//
//  PTHTableViewController.m
//  Party Hunt
//
//  Created by Jared McFarland on 9/21/14.
//  Copyright (c) 2014 Jared Colin McFarland. All rights reserved.
//

#import "PTHTableViewController.h"
#import "PTHTabBarController.h"
#import "PTHPartyDetailTableViewController.h"


@interface PTHTableViewController () <PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate>

@property CGRect initialFrame;

@end

@implementation PTHTableViewController

#pragma mark - Initializers

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        self.parseClassName = kPTHPartyClassKey;
    }
    return self;
}

- (CLLocationManager *)locationManager
{
    if (_locationManager != nil)
    {
        return _locationManager;
    }
    
    _locationManager = [[CLLocationManager alloc] init];
    [_locationManager setDesiredAccuracy:kCLLocationAccuracyKilometer];
    [_locationManager setDelegate:self];
    
    return _locationManager;
}

#pragma mark - UIView methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined )
    {
        [self.locationManager requestWhenInUseAuthorization];
    }
    
    [[self locationManager] startUpdatingLocation];
    
    // Self-sizing table view cells in iOS 8 require that the rowHeight property of the table view be set to the constant UITableViewAutomaticDimension
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    // Self-sizing table view cells in iOS 8 are enabled when the estimatedRowHeight property of the table view is set to a non-zero value.
    // Setting the estimated row height prevents the table view from calling tableView:heightForRowAtIndexPath: for every row in the table on first load;
    // it will only be called as cells are about to scroll onscreen. This is a major performance optimization.
    self.tableView.estimatedRowHeight = 82.0; // set this to whatever your "average" cell height is; it doesn't need to be very accurate
    
    self.datePicker = [[DIDatepicker alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, 60)];
    
    [self.datePicker fillDatesFromCurrentDate:30];
    
    [self.datePicker addTarget:self action:@selector(updateSelectedDate) forControlEvents:UIControlEventValueChanged];
    
    [self.datePicker selectDateAtIndex:((PTHTabBarController *)self.tabBarController).selectedDateIndex];
    
    [self.tableView setTableHeaderView:self.datePicker];
    
    PFUser *user = [PFUser currentUser];
    if (!user)
    {
        [self beginLogin];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([self.datePicker.dates indexOfObject:self.datePicker.selectedDate] != ((PTHTabBarController *)self.tabBarController).selectedDateIndex)
    {
        [self.datePicker selectDateAtIndex:((PTHTabBarController *)self.tabBarController).selectedDateIndex];
    }
}

#pragma mark - UITableViewDataSource

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object
{
    
    PTHPartyTableViewCell *cell = (PTHPartyTableViewCell *)[tableView dequeueReusableCellWithIdentifier:kPTHPartyCellIdentifier];
    
    if (cell == nil) {
        cell = [[PTHPartyTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kPTHPartyCellIdentifier];
    }
    
   [self configureCell:cell forObject:object atIndexPath:indexPath];
    
    // Make sure the constraints have been added to this cell, since it may have just been created from scratch
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"ToDetailSegue" sender:self.objects[indexPath.row]];
}

- (void)configureCell:(PTHPartyTableViewCell *)cell forObject:(PFObject *)party atIndexPath:(NSIndexPath *)indexPath
{
    // Sub-classes must override this method

}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ToDetailSegue"])
    {
        PTHPartyDetailTableViewController *detailVC = (PTHPartyDetailTableViewController *)segue.destinationViewController;
        detailVC.party = sender;
    }
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
    } else {
        if ([upvoteCount intValue] > 0) {
            upvoteCount = [NSNumber numberWithInt:[upvoteCount intValue] - 1];
        }
    }
    
    partyTableViewCell.upvoteCountLabel.text = [numberFormatter stringFromNumber:upvoteCount];
    
    if (upvoted) {
        [PTHUtility upvotePartyInBackground:party block:^(BOOL succeeded, NSError *error) {
            PTHPartyTableViewCell *actualTableViewCell = (PTHPartyTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
            [actualTableViewCell shouldEnableUpvoteButton:YES];
            [actualTableViewCell setUpvoteStatus:succeeded];
            
            if (!succeeded) {
                actualTableViewCell.upvoteCountLabel.text = originalUpvoteCount;
            } else
            {
                [party addUniqueObject:[PFUser currentUser] forKey:@"upvoters"];
            }
        }];
    } else {
        [PTHUtility undoUpvotePartyInBackground:party block:^(BOOL succeeded, NSError *error) {
            PTHPartyTableViewCell *actualTableViewCell = (PTHPartyTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
            [actualTableViewCell shouldEnableUpvoteButton:YES];
            [actualTableViewCell setUpvoteStatus:!succeeded];
            
            if (!succeeded) {
                actualTableViewCell.upvoteCountLabel.text = originalUpvoteCount;
            } else
            {
                [party removeObject:[PFUser currentUser] forKey:@"upvoters"];
            }
        }];
    }
}

#pragma mark - Date Picker

- (void)updateSelectedDate
{
    NSUInteger datePickerIndex = [self.datePicker.dates indexOfObject:self.datePicker.selectedDate];
    
    if (datePickerIndex < self.datePicker.dates.count)
    {
        ((PTHTabBarController *)self.tabBarController).selectedDateIndex = datePickerIndex;
    }
    
    [self loadObjects];
}


#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse)
    {
        //[self loadObjects];
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

#pragma mark - Log In / Out

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
    
    [logInViewController setFacebookPermissions:[NSArray arrayWithObjects:@"public_profile",@"user_friends",@"email", nil]];
    [logInViewController setFields: PFLogInFieldsUsernameAndPassword | PFLogInFieldsLogInButton | PFLogInFieldsSignUpButton | PFLogInFieldsTwitter | PFLogInFieldsFacebook | PFLogInFieldsDismissButton];
    
    // Present the log in view controller
    [self presentViewController:logInViewController animated:YES completion:NULL];
}

- (void)logOut {
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
