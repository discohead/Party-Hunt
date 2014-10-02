//
//  PTHTableViewController.h
//  Party Hunt
//
//  Created by Jared McFarland on 9/21/14.
//  Copyright (c) 2014 Jared Colin McFarland. All rights reserved.
//

#import <Parse/Parse.h>
#import <FacebookSDK/FacebookSDK.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import <CoreLocation/CoreLocation.h>
#import <DIDatepicker/DIDatepicker.h>
#import "PTHPartyTableViewCell.h"
#import "PTHUtility.h"
#import "PTHCache.h"
#import "PTHConstants.h"
#import "PTHAddPartyTableViewController.h"

@class PTHPartyTableViewCell, PFObject;

@interface PTHTableViewController : PFQueryTableViewController <PTHAddPartyTableViewControllerDelegate, PTHPartyTableViewCellDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) DIDatepicker *datePicker;
@property (strong, nonatomic) CLLocationManager *locationManager;

- (void)configureCell:(PTHPartyTableViewCell *)cell forObject:(PFObject *)party atIndexPath:(NSIndexPath *)indexPath;
- (void)constrainQueryToSelectedDate:(PFQuery *)query;

@end
