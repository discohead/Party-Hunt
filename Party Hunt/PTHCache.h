//
//  PTHCache.h
//  Party Hunt
//
//  Created by Jared McFarland on 9/25/14.
//  Copyright (c) 2014 Jared Colin McFarland. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface PTHCache : NSObject

+ (id)sharedCache;

- (void)clear;
- (void)setAttributesForParty:(PFObject *)party upvoters:(NSArray *)upvoters commenters:(NSArray *)commenters upvotedByCurrentUser:(BOOL)upvotedByCurrentUser;
- (NSDictionary *)attributesForParty:(PFObject *)party;
- (NSNumber *)upvoteCountForParty:(PFObject *)party;
- (NSNumber *)commentCountForParty:(PFObject *)party;
- (NSArray *)upvotersForParty:(PFObject *)party;
- (NSArray *)commentersForParty:(PFObject *)party;
- (void)setPartyIsUpvotedByCurrentUser:(PFObject *)party upvoted:(BOOL)upvoted;
- (BOOL)isPartyUpvotedByCurrentUser:(PFObject *)party;
- (void)incrementUpvoteCountForParty:(PFObject *)party;
- (void)decrementUpvoteCountForParty:(PFObject *)party;
- (void)incrementCommentCountForParty:(PFObject *)party;
- (void)decrementCommentCountForParty:(PFObject *)party;

- (NSDictionary *)attributesForUser:(PFUser *)user;
- (NSNumber *)partyCountForUser:(PFUser *)user;
- (BOOL)friendStatusForUser:(PFUser *)user;
- (void)setPartyCount:(NSNumber *)count user:(PFUser *)user;
- (void)setFriendStatus:(BOOL)isFriend user:(PFUser *)user;

- (void)setFacebookFriends:(NSArray *)friends;
- (NSArray *)facebookFriends;

@end
