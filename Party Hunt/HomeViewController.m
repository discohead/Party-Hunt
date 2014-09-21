//
//  HomeViewController.m
//  Party Hunt
//
//  Created by Jared McFarland on 9/20/14.
//  Copyright (c) 2014 Jared Colin McFarland. All rights reserved.
//

#import "HomeViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>

@interface HomeViewController () <PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate>

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}

- (void)viewWillAppear:(BOOL)animated
{
    if ([PFUser currentUser]) {
        self.welcomeLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Welcome %@!", nil), [[PFUser currentUser] username]];
        [self.signInOutButton setTitle:@"Sign Out" forState:UIControlStateNormal];
    } else {
        self.welcomeLabel.text = NSLocalizedString(@"Not logged in", nil);
        [self.signInOutButton setTitle:@"Sign In" forState:UIControlStateNormal];
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
    [self.signInOutButton setTitle:@"Sign Out" forState:UIControlStateNormal];
    self.welcomeLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Welcome %@!", nil), [[PFUser currentUser] username]];
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

#pragma mark - Sign Out

- (IBAction)signOutButtonTapped:(id)sender
{
    if ([PFUser currentUser])
    {
        [PFUser logOut];
        self.welcomeLabel.text = @"Logged Out";
        [self.signInOutButton setTitle:@"Sign In" forState:UIControlStateNormal];
    } else
    {
        [self beginLogin];
    }
    
}
@end
