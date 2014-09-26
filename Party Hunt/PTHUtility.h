//
//  PTHUtility.h
//  Party Hunt
//
//  Created by Jared McFarland on 9/22/14.
//  Copyright (c) 2014 Jared Colin McFarland. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface PTHUtility : NSObject

+ (void)updateFacebookEventsForUser:(PFUser *)user;
+ (void)upvotePartyInBackground:(id)party block:(void (^)(BOOL succeeded, NSError *error))completionBlock;
+ (void)undoUpvotePartyInBackground:(id)party block:(void (^)(BOOL succeeded, NSError *error))completionBlock;

+ (PFQuery *)queryForActivitiesOnParty:(PFObject *)party cachePolicy:(PFCachePolicy)cachePolicy;
@end
