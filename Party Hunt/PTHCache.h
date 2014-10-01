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

- (NSDictionary *)attributesForUser:(PFUser *)user;
- (NSNumber *)partyCountForUser:(PFUser *)user;
- (BOOL)friendStatusForUser:(PFUser *)user;
- (void)setPartyCount:(NSNumber *)count user:(PFUser *)user;
- (void)setFriendStatus:(BOOL)isFriend user:(PFUser *)user;

- (void)setFacebookFriends:(NSArray *)friends;
- (NSArray *)facebookFriends;

@end
