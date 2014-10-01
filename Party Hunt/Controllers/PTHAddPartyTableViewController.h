//
//  PTHAddPartyTableViewController.h
//  Party Hunt
//
//  Created by Jared McFarland on 9/23/14.
//  Copyright (c) 2014 Jared Colin McFarland. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PFObject;

@protocol PTHAddPartyTableViewControllerDelegate <NSObject>

- (void)didAddParty:(PFObject *)party;

@end

@interface PTHAddPartyTableViewController : UITableViewController

@property (strong, nonatomic) NSMutableDictionary *events;
@property (weak, nonatomic) id <PTHAddPartyTableViewControllerDelegate> delegate;

@end
