//
//  PTHUtility.m
//  Party Hunt
//
//  Created by Jared McFarland on 9/22/14.
//  Copyright (c) 2014 Jared Colin McFarland. All rights reserved.
//

#import "PTHUtility.h"
#import <FacebookSDK/FacebookSDK.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import "PTHConstants.h"
#import "PTHCache.h"
#import <Bolts/Bolts.h>

@implementation PTHUtility

#pragma mark - User Utilities

+ (BOOL)userArray:(NSArray *)userArray containsUser:(PFUser *)user
{
    NSPredicate *constainsUser = [NSPredicate predicateWithFormat:@"objectId = %@",[user objectId]];
    NSUInteger indexOfUser = [userArray indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return [constainsUser evaluateWithObject:obj];
    }];
    
    if (indexOfUser == NSNotFound)
    {
        return NO;
    }
    
    return YES;
}

#pragma mark - Upvote Parties

+ (void)upvotePartyInBackground:(id)party block:(void (^)(BOOL succeeded, NSError *error))completionBlock {
    PFQuery *queryExistingUpvotes = [PFQuery queryWithClassName:kPTHActivityClassKey];
    [queryExistingUpvotes whereKey:kPTHActivityPartyKey equalTo:party];
    [queryExistingUpvotes whereKey:kPTHActivityTypeKey equalTo:kPTHActivityTypeUpvote];
    [queryExistingUpvotes whereKey:kPTHActivityFromUserKey equalTo:[PFUser currentUser]];
    [queryExistingUpvotes setCachePolicy:kPFCachePolicyNetworkOnly];
    [queryExistingUpvotes findObjectsInBackgroundWithBlock:^(NSArray *upvotes, NSError *error) {
        if (!error) {
            for (PFObject *upvote in upvotes) {
                [upvote deleteInBackground];
            }
        }
        
        // proceed to creating new upvote
        PFObject *upvoteActivity = [PFObject objectWithClassName:kPTHActivityClassKey];
        [upvoteActivity setObject:kPTHActivityTypeUpvote forKey:kPTHActivityTypeKey];
        [upvoteActivity setObject:[PFUser currentUser] forKey:kPTHActivityFromUserKey];
        [upvoteActivity setObject:[party objectForKey:kPTHPartyUserKey] forKey:kPTHActivityToUserKey];
        [upvoteActivity setObject:party forKey:kPTHActivityPartyKey];
        
        PFACL *upvoteACL = [PFACL ACLWithUser:[PFUser currentUser]];
        [upvoteACL setPublicReadAccess:YES];
        [upvoteACL setWriteAccess:YES forUser:[party objectForKey:kPTHPartyUserKey]];
        upvoteActivity.ACL = upvoteACL;
        
        [upvoteActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (completionBlock) {
                completionBlock(succeeded,error);
            }
                /*
                [[NSNotificationCenter defaultCenter] postNotificationName:PAPUtilityUserLikedUnlikedPhotoCallbackFinishedNotification object:photo userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:succeeded] forKey:PAPPhotoDetailsViewControllerUserLikedUnlikedPhotoNotificationUserInfoLikedKey]];
                 */
        }];
    }];
    
}

+ (void)undoUpvotePartyInBackground:(id)party block:(void (^)(BOOL succeeded, NSError *error))completionBlock {
    PFQuery *queryExistingUpvotes = [PFQuery queryWithClassName:kPTHActivityClassKey];
    [queryExistingUpvotes whereKey:kPTHActivityPartyKey equalTo:party];
    [queryExistingUpvotes whereKey:kPTHActivityTypeKey equalTo:kPTHActivityTypeUpvote];
    [queryExistingUpvotes whereKey:kPTHActivityFromUserKey equalTo:[PFUser currentUser]];
    [queryExistingUpvotes setCachePolicy:kPFCachePolicyNetworkOnly];
    [queryExistingUpvotes findObjectsInBackgroundWithBlock:^(NSArray *upvotes, NSError *error) {
        if (!error) {
            for (PFObject *upvote in upvotes) {
                [upvote deleteInBackground];
            }
            
            if (completionBlock) {
                completionBlock(YES,nil);
            }
                /*
                [[NSNotificationCenter defaultCenter] postNotificationName:PAPUtilityUserLikedUnlikedPhotoCallbackFinishedNotification object:photo userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:PAPPhotoDetailsViewControllerUserLikedUnlikedPhotoNotificationUserInfoLikedKey]];
                 */
            
        } else {
            if (completionBlock) {
                completionBlock(NO,error);
            }
        }
    }];  
}

+ (NSDictionary *)getFbEventsForCurrentUser
{
    
    __block NSMutableDictionary *eventsDictionary = [NSMutableDictionary dictionary];
    
    NSArray *permissions = [[[FBSession activeSession] accessTokenData] permissions];
    
    if (![permissions containsObject:@"user_events"])
    {
        __block BOOL permissionGranted;
        
        [PFFacebookUtils reauthorizeUser:[PFUser currentUser] withPublishPermissions:[NSArray arrayWithObjects:@"public_profile",@"user_friends",@"email",@"user_events", nil] audience:FBSessionDefaultAudienceFriends block:^(BOOL succeeded, NSError *error) {
            if (!succeeded)
            {
                NSLog(@"Error obtaining user_events permission: %@", [error localizedDescription]);
                [eventsDictionary setObject:error forKey:@"authError"];
            }
            permissionGranted = succeeded;
        }];
        if (!permissionGranted)
        {
            return eventsDictionary;
        }
    }
    
    FBRequest *createdRequest = [FBRequest requestForGraphPath:@"me/events/created?fields=name,description,start_time,end_time,location,venue,privacy"];
    FBRequest *attendingRequest = [FBRequest requestForGraphPath:@"me/events/attending?fields=name,description,start_time,end_time,location,venue,privacy"];
    FBRequest *maybeRequest = [FBRequest requestForGraphPath:@"me/events/maybe?fields=name,description,start_time,end_time,location,venue,privacy"];
    FBRequest *notRepliedRequest = [FBRequest requestForGraphPath:@"me/events/not_replied?fields=name,description,start_time,end_time,location,venue,privacy"];
    FBRequest *declinedRequest = [FBRequest requestForGraphPath:@"me/events/declined?fields=name,description,start_time,end_time,location,venue,privacy"];
    
    FBRequestConnection *requestConnection = [[FBRequestConnection alloc] init];
    
    [requestConnection addRequest:createdRequest completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error)
        {
            [eventsDictionary setObject:result forKey:kPTHFbEventsCreated];
        } else
        {
            [eventsDictionary setObject:error forKey:kPTHFbEventsCreated];
        }
    }];
    
    [requestConnection addRequest:attendingRequest completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error)
        {
            [eventsDictionary setObject:result forKey:kPTHFbEventsAttending];
        } else
        {
            [eventsDictionary setObject:error forKey:kPTHFbEventsAttending];
        }
    }];
    
    [requestConnection addRequest:maybeRequest completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error)
        {
            [eventsDictionary setObject:result forKey:kPTHFbEventsMaybe];
        } else
        {
            [eventsDictionary setObject:error forKey:kPTHFbEventsMaybe];
        }
    }];
    
    [requestConnection addRequest:notRepliedRequest completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error)
        {
            [eventsDictionary setObject:result forKey:kPTHFbEventsNotReplied];
        } else
        {
            [eventsDictionary setObject:error forKey:kPTHFbEventsNotReplied];
        }
    }];
    
    [requestConnection addRequest:declinedRequest completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error)
        {
            [eventsDictionary setObject:result forKey:kPTHFbEventsDeclined];
        } else
        {
            [eventsDictionary setObject:error forKey:kPTHFbEventsDeclined];
        }
    }];
    
    [requestConnection start];
    NSLog(@"eventsDictionary = %@", eventsDictionary);
    return eventsDictionary;
}
@end
