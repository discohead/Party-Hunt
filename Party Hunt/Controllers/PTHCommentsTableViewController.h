//
//  PTHCommentsTableViewController.h
//  Party Hunt
//
//  Created by Jared McFarland on 12/29/14.
//  Copyright (c) 2014 Jared Colin McFarland. All rights reserved.
//
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import "PTHConstants.h"
#import "PTHUtility.h"
#import "PFQueryTableViewController.h"

@interface PTHCommentsTableViewController : PFQueryTableViewController

@property (strong, nonatomic) PFObject *party;

@end
