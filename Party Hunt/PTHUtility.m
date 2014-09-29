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

@implementation PTHUtility

#pragma mark Like Photos

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
            
            // refresh cache
            PFQuery *query = [PTHUtility queryForActivitiesOnParty:party cachePolicy:kPFCachePolicyNetworkOnly];
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (!error) {
                    
                    NSMutableArray *upvoters = [NSMutableArray array];
                    NSMutableArray *commenters = [NSMutableArray array];
                    
                    BOOL isUpvotedByCurrentUser = NO;
                    
                    for (PFObject *activity in objects) {
                        if ([[activity objectForKey:kPTHActivityTypeKey] isEqualToString:kPTHActivityTypeUpvote] && [activity objectForKey:kPTHActivityFromUserKey]) {
                            [upvoters addObject:[activity objectForKey:kPTHActivityFromUserKey]];
                        } else if ([[activity objectForKey:kPTHActivityTypeKey] isEqualToString:kPTHActivityTypeComment] && [activity objectForKey:kPTHActivityFromUserKey]) {
                            [commenters addObject:[activity objectForKey:kPTHActivityFromUserKey]];
                        }
                        
                        if ([[[activity objectForKey:kPTHActivityFromUserKey] objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
                            if ([[activity objectForKey:kPTHActivityTypeKey] isEqualToString:kPTHActivityTypeUpvote]) {
                                isUpvotedByCurrentUser = YES;
                            }
                        }
                    }
                    
                    [[PTHCache sharedCache] setAttributesForParty:party upvoters:upvoters commenters:commenters upvotedByCurrentUser:isUpvotedByCurrentUser];
                }
                /*
                [[NSNotificationCenter defaultCenter] postNotificationName:PAPUtilityUserLikedUnlikedPhotoCallbackFinishedNotification object:photo userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:succeeded] forKey:PAPPhotoDetailsViewControllerUserLikedUnlikedPhotoNotificationUserInfoLikedKey]];
                 */
            }];
            
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
            
            // refresh cache
            PFQuery *query = [PTHUtility queryForActivitiesOnParty:party cachePolicy:kPFCachePolicyNetworkOnly];
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (!error) {
                    
                    NSMutableArray *upvoters = [NSMutableArray array];
                    NSMutableArray *commenters = [NSMutableArray array];
                    
                    BOOL isUpvotedByCurrentUser = NO;
                    
                    for (PFObject *activity in objects) {
                        if ([[activity objectForKey:kPTHActivityTypeKey] isEqualToString:kPTHActivityTypeUpvote]) {
                            [upvoters addObject:[activity objectForKey:kPTHActivityFromUserKey]];
                        } else if ([[activity objectForKey:kPTHActivityTypeKey] isEqualToString:kPTHActivityTypeComment]) {
                            [commenters addObject:[activity objectForKey:kPTHActivityFromUserKey]];
                        }
                        
                        if ([[[activity objectForKey:kPTHActivityFromUserKey] objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
                            if ([[activity objectForKey:kPTHActivityTypeKey] isEqualToString:kPTHActivityTypeUpvote]) {
                                isUpvotedByCurrentUser = YES;
                            }
                        }
                    }
                    
                    [[PTHCache sharedCache] setAttributesForParty:party upvoters:upvoters commenters:commenters upvotedByCurrentUser:isUpvotedByCurrentUser];
                }
                /*
                [[NSNotificationCenter defaultCenter] postNotificationName:PAPUtilityUserLikedUnlikedPhotoCallbackFinishedNotification object:photo userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:PAPPhotoDetailsViewControllerUserLikedUnlikedPhotoNotificationUserInfoLikedKey]];
                 */
            }];
            
        } else {
            if (completionBlock) {
                completionBlock(NO,error);
            }
        }
    }];  
}

#pragma mark Activities

+ (PFQuery *)queryForActivitiesOnParty:(PFObject *)party cachePolicy:(PFCachePolicy)cachePolicy {
    PFQuery *queryUpvotes = [PFQuery queryWithClassName:kPTHActivityClassKey];
    [queryUpvotes whereKey:kPTHActivityPartyKey equalTo:party];
    [queryUpvotes whereKey:kPTHActivityTypeKey equalTo:kPTHActivityTypeUpvote];
    
    PFQuery *queryComments = [PFQuery queryWithClassName:kPTHActivityClassKey];
    [queryComments whereKey:kPTHActivityPartyKey equalTo:party];
    [queryComments whereKey:kPTHActivityTypeKey equalTo:kPTHActivityTypeComment];
    
    PFQuery *query = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:queryUpvotes,queryComments,nil]];
    [query setCachePolicy:cachePolicy];
    [query includeKey:kPTHActivityFromUserKey];
    [query includeKey:kPTHActivityPartyKey];
    
    return query;
}


+ (void)updateFacebookEventsForUser:(PFUser *)user
{
    // Request events/created
    
    [FBRequestConnection startWithGraphPath:@"me/events/created?fields=name,description,start_time,end_time,location,venue,privacy"
                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                              if (!error) {
                                  
                                  [user setObject:result forKey:@"fbEventsCreated"];
                                  
                                  // Request events/attending
                                  
                                  [FBRequestConnection startWithGraphPath:@"me/events/attending?fields=name,description,start_time,end_time,location,venue,privacy"
                                                        completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                                                            if (!error) {
                                                                [user setObject:result forKey:@"fbEventsAttending"];
                                                                
                                                                // Request events/maybe
                                                                
                                                                [FBRequestConnection startWithGraphPath:@"me/events/maybe?fields=name,description,start_time,end_time,location,venue,privacy"
                                                                                      completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                                                                                          if (!error) {
                                                                                              [user setObject:result forKey:@"fbEventsMaybe"];
                                                                                              
                                                                                              // Request events/declined
                                                                                              
                                                                                              [FBRequestConnection startWithGraphPath:@"me/events/declined?fields=name,description,start_time,end_time,location,venue,privacy"
                                                                                                                    completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                                                                                                                        if (!error) {
                                                                                                                            [user setObject:result forKey:@"fbEventsDeclined"];
                                                                                                                            
                                                                                                                            // Request events/not_replied
                                                                                                                            
                                                                                                                            [FBRequestConnection startWithGraphPath:@"me/events/not_replied?fields=name,description,start_time,end_time,location,venue,privacy"
                                                                                                                                                  completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                                                                                                                                                      if (!error) {
                                                                                                                                                          [user setObject:result forKey:@"fbEventsNotReplied"];
                                                                                                                                                          [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                                                                                                                                              if (!succeeded)
                                                                                                                                                              {
                                                                                                                                                                  NSLog(@"Error saving user events: %@", [error localizedDescription]);
                                                                                                                                                              } else
                                                                                                                                                              {
                                                                                                                                                                  NSLog(@"User events saved!");
                                                                                                                                                              }
                                                                                                                                                          }];
                                                                                                                                                      } else {
                                                                                                                                                          // An error occurred, we need to handle the error
                                                                                                                                                          // See: https://developers.facebook.com/docs/ios/errors
                                                                                                                                                          
                                                                                                                                                          NSLog(@"Error retrieving events/not_replied: %@", [error localizedDescription]);
                                                                                                                                                      }
                                                                                                                                                  }];
                                                                                                                        } else {
                                                                                                                            // An error occurred, we need to handle the error
                                                                                                                            // See: https://developers.facebook.com/docs/ios/errors
                                                                                                                            
                                                                                                                            NSLog(@"Error retrieving events/declined: %@", [error localizedDescription]);
                                                                                                                        }
                                                                                                                    }];
                                                                                          } else {
                                                                                              // An error occurred, we need to handle the error
                                                                                              // See: https://developers.facebook.com/docs/ios/errors
                                                                                              
                                                                                              NSLog(@"Error retrieving events/maybe: %@", [error localizedDescription]);
                                                                                          }
                                                                                      }];
                                                            } else {
                                                                // An error occurred, we need to handle the error
                                                                // See: https://developers.facebook.com/docs/ios/errors
                                                                
                                                                NSLog(@"Error retrieving events/attending: %@", [error localizedDescription]);
                                                            }
                                                        }];
                              } else {
                                  // An error occurred, we need to handle the error
                                  // See: https://developers.facebook.com/docs/ios/errors
                                  
                                  NSLog(@"Error retrieving events/created: %@", [error localizedDescription]);
                              }
                          }];
}

@end
