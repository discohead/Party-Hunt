//
//  PTHCache.m
//  Party Hunt
//
//  Created by Jared McFarland on 9/25/14.
//  Copyright (c) 2014 Jared Colin McFarland. All rights reserved.
//

#import "PTHCache.h"
#import "PTHConstants.h"

@interface PTHCache ()

@property (nonatomic, strong) NSCache *cache;
-(void)setAttributes:(NSDictionary *)attributes forParty:(PFObject *)party;

@end

@implementation PTHCache

#pragma mark - Initialization

+ (id)sharedCache
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        self.cache = [[NSCache alloc] init];
    }
    return self;
}

#pragma mark - PTHCache

- (void)clear
{
    [self.cache removeAllObjects];
}

- (void)setAttributesForParty:(PFObject *)party upvoters:(NSArray *)upvoters commenters:(NSArray *)commenters upvotedByCurrentUser:(BOOL)upvotedByCurrentUser
{
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                [NSNumber numberWithBool:upvotedByCurrentUser],kPTHPartyAttributesIsUpvotedByCurrentUserKey,
                                @([upvoters count]), kPTHPartyAttributesUpvoteCountKey,
                                upvoters, kPTHPartyAttributesUpvotersKey,
                                @([commenters count]), kPTHPartyAttributesCommentCountKey,
                                commenters, kPTHPartyAttributesCommentersKey,
                                nil];
    
    [self setAttributes:attributes forParty:party];
}

- (NSDictionary *)attributesForParty:(PFObject *)party
{
    NSString *key = [self keyForParty:party];
    return [self.cache objectForKey:key];
}

- (NSNumber *)upvoteCountForParty:(PFObject *)party
{
    NSDictionary *attributes = [self attributesForParty:party];
    if (attributes)
    {
        return [attributes objectForKey:kPTHPartyAttributesUpvoteCountKey];
    }
    
    return [NSNumber numberWithInt:0];
}
- (NSNumber *)commentCountForParty:(PFObject *)party
{
    NSDictionary *attributes = [self attributesForParty:party];
    if (attributes)
    {
        return [attributes objectForKey:kPTHPartyAttributesCommentCountKey];
    }
    
    return [NSNumber numberWithInt:0];
}

- (NSArray *)upvotersForParty:(PFObject *)party
{
    NSDictionary *attributes = [self attributesForParty:party];
    if (attributes)
    {
        return [attributes objectForKey:kPTHPartyAttributesUpvotersKey];
    }
    
    return [NSArray array];
}

- (NSArray *)commentersForParty:(PFObject *)party
{
    NSDictionary *attributes = [self attributesForParty:party];
    if (attributes)
    {
        return [attributes objectForKey:kPTHPartyAttributesCommentersKey];
    }
    
    return [NSArray array];
}

- (void)setPartyIsUpvotedByCurrentUser:(PFObject *)party upvoted:(BOOL)upvoted
{
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:[self attributesForParty:party]];
    [attributes setObject:[NSNumber numberWithBool:upvoted] forKey:kPTHPartyAttributesIsUpvotedByCurrentUserKey];
    [self setAttributes:attributes forParty:party];
}

- (BOOL)isPartyUpvotedByCurrentUser:(PFObject *)party
{
    NSDictionary *attributes = [self attributesForParty:party];
    if (attributes)
    {
        return [[attributes objectForKey:kPTHPartyAttributesIsUpvotedByCurrentUserKey] boolValue];
    }
    
    return NO;
}

- (void)incrementUpvoteCountForParty:(PFObject *)party
{
    NSNumber *upvoteCount = [NSNumber numberWithInt:[[self upvoteCountForParty:party] intValue] + 1];
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:[self attributesForParty:party]];
    [attributes setObject:upvoteCount forKey:kPTHPartyAttributesUpvoteCountKey];
    [self setAttributes:attributes forParty:party];
}

- (void)decrementUpvoteCountForParty:(PFObject *)party
{
    NSNumber *upvoteCount = [NSNumber numberWithInt:[[self upvoteCountForParty:party] intValue] - 1];
    if ([upvoteCount intValue] < 0)
    {
        return;
    }
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:[self attributesForParty:party]];
    [attributes setObject:upvoteCount forKey:kPTHPartyAttributesUpvoteCountKey];
    [self setAttributes:attributes forParty:party];
}

- (void)incrementCommentCountForParty:(PFObject *)party
{
    NSNumber *commentCount = [NSNumber numberWithInt:[[self commentCountForParty:party] intValue] + 1];
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:[self attributesForParty:party]];
    [attributes setObject:commentCount forKey:kPTHPartyAttributesCommentCountKey];
}

- (void)decrementCommentCountForParty:(PFObject *)party
{
    NSNumber *commentCount = [NSNumber numberWithInt:[[self commentCountForParty:party] intValue] -1];
    if ([commentCount intValue] < 0)
    {
        return;
    }
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:[self attributesForParty:party]];
    [attributes setObject:commentCount forKey:kPTHPartyAttributesCommentCountKey];
    [self setAttributes:attributes forParty:party];
}

- (NSDictionary *)attributesForUser:(PFUser *)user
{
    NSString *key = [self keyForUser:user];
    return [self.cache objectForKey:key];
}

- (NSNumber *)partyCountForUser:(PFUser *)user
{
    NSDictionary *attributes = [self attributesForUser:user];
    if (attributes)
    {
        NSNumber *partyCount = [attributes objectForKey:kPTHUserAttributesPartyCountKey];
        if (partyCount)
        {
            return partyCount;
        }
    }
    
    return [NSNumber numberWithInt:0];
}

- (BOOL)friendStatusForUser:(PFUser *)user
{
    NSDictionary *attributes = [self attributesForUser:user];
    if (attributes)
    {
        NSNumber *friendStatus = [attributes objectForKey:kPTHUserAttributesIsFriendOfCurrentUserKey];
        if (friendStatus)
        {
            return [friendStatus boolValue];
        }
    }
    
    return NO;
}

- (void)setPartyCount:(NSNumber *)count user:(PFUser *)user
{
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:[self attributesForUser:user]];
    [attributes setObject:count forKey:kPTHUserAttributesPartyCountKey];
    [self setAttributes:attributes forUser:user];
}

- (void)setFriendStatus:(BOOL)isFriend user:(PFUser *)user
{
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:[self attributesForUser:user]];
    [attributes setObject:[NSNumber numberWithBool:isFriend] forKey:kPTHUserAttributesIsFriendOfCurrentUserKey];
    [self setAttributes:attributes forUser:user];
}

- (void)setFacebookFriends:(NSArray *)friends
{
    NSString *key = kPTHUserDefaultsCacheFacebookFriendsKey;
    [self.cache setObject:friends forKey:key];
    [[NSUserDefaults standardUserDefaults] setObject:friends forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSArray *)facebookFriends
{
    NSString *key = kPTHUserDefaultsCacheFacebookFriendsKey;
    if ([self.cache objectForKey:key])
    {
        return [self.cache objectForKey:key];
    }
    
    NSArray *friends = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    
    if (friends)
    {
        [self.cache setObject:friends forKey:key];
    }
    
    return friends;
}

#pragma mark - ()

- (void)setAttributes:(NSDictionary *)attributes forParty:(PFObject *)party
{
    NSString *key = [self keyForParty:party];
    [self.cache setObject:attributes forKey:key];
}

- (void)setAttributes:(NSDictionary *)attributes forUser:(PFObject *)user
{
    NSString *key = [self keyForUser:user];
    [self.cache setObject:attributes forKey:key];
}

- (NSString *)keyForParty:(PFObject *)party
{
    return [NSString stringWithFormat:@"party_%@", [party objectId]];
}

- (NSString *)keyForUser:(PFObject *)user
{
    return [NSString stringWithFormat:@"user_%@", [user objectId]];
}

@end
