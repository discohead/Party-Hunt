//
//  PTHTabBarController.m
//  Party Hunt
//
//  Created by Jared McFarland on 10/1/14.
//  Copyright (c) 2014 Jared Colin McFarland. All rights reserved.
//

#import "PTHTabBarController.h"
#import "PTHTableViewController.h"

@interface PTHTabBarController ()

@end

@implementation PTHTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

#pragma mark - PTHAddPartyTableViewControllerDelegate

- (void)didAddParty:(PFObject *)party
{
    [(PTHTableViewController *)self.selectedViewController loadObjects];
}

#pragma mark - Prepare for segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"TabBarToAddPartySegue"])
    {
        UINavigationController *navController = (UINavigationController *)segue.destinationViewController;
        PTHAddPartyTableViewController *addPartyVC = (PTHAddPartyTableViewController *)[navController topViewController];
        addPartyVC.delegate = self;
    }
}

@end
