//
//  PTHPartyDetailTableViewController.h
//  Party Hunt
//
//  Created by Jared McFarland on 10/12/14.
//  Copyright (c) 2014 Jared Colin McFarland. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PFObject;

@interface PTHPartyDetailTableViewController : UITableViewController

@property (strong, nonatomic) PFObject *party;

@end
