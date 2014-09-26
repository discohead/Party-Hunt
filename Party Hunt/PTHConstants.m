//
//  PTHConstants.m
//  Party Hunt
//
//  Created by Jared McFarland on 9/25/14.
//  Copyright (c) 2014 Jared Colin McFarland. All rights reserved.
//

#import "PTHConstants.h"

@implementation PTHConstants

NSString *const kPTHUserDefaultsActivityFeedViewControllerLastRefreshKey    = @"com.jared.mcfarland.Party-Hunt.userDefaults.activityFeedViewController.lastRefresh";
NSString *const kPTHUserDefaultsCacheFacebookFriendsKey                     = @"com.jared.mcfarland.Party-Hunt.userDefaults.cache.facebookFriends";

#pragma mark - PFObject Activity Class
// Class key
NSString *const kPTHActivityClassKey = @"Activity";

// Field keys
NSString *const kPTHActivityTypeKey              = @"type";
NSString *const kPTHActivityFromUserKey          = @"fromUser";
NSString *const kPTHActivityToUserKey            = @"toUser";
NSString *const kPTHActivityContentKey           = @"content";
NSString *const kPTHActivityPartyKey             = @"party";
NSString *const kPTHActivityParentCommentKey     = @"parentComment";

// Type values
NSString *const kPTHActivityTypeUpvote    = @"upvote";
NSString *const kPTHActivityTypeFriend    = @"friend";
NSString *const kPTHActivityTypeComment   = @"comment";
NSString *const kPTHActivityTypeJoined    = @"joined";
NSString *const kPTHActivityTypeSubmitted = @"submitted";


#pragma mark - PFObject User Class
// Field keys
NSString *const kPTHUserDisplayNameKey                          = @"displayName";
NSString *const kPTHUserFacebookIDKey                           = @"facebookId";
NSString *const kPTHUserPhotoIDKey                              = @"photoId";
NSString *const kPTHUserProfilePicSmallKey                      = @"profilePictureSmall";
NSString *const kPTHUserProfilePicMediumKey                     = @"profilePictureMedium";
NSString *const kPTHUserFacebookFriendsKey                      = @"facebookFriends";
NSString *const kPTHUserAlreadyAutoFollowedFacebookFriendsKey   = @"userAlreadyAutoFollowedFacebookFriends";


#pragma mark - PFObject Party Class
// Class key
NSString *const kPTHPartyClassKey = @"Party";

// Field keys
NSString *const kPTHPartyNameKey          = @"name";
NSString *const kPTHPartyGeoLocationKey   = @"geoLocation";
NSString *const kPTHPartyStartTimeKey     = @"start_time";
NSString *const kPTHPartyEndTimeKey       = @"end_time";
NSString *const kPTHPartyFbEventIdKey     = @"fbEventId";
NSString *const kPTHPartyUserKey          = @"user";


#pragma mark - Cached Party Attributes
// keys
NSString *const kPTHPartyAttributesIsUpvotedByCurrentUserKey = @"isUpvotedByCurrentUser";
NSString *const kPTHPartyAttributesUpvoteCountKey            = @"upvoteCount";
NSString *const kPTHPartyAttributesUpvotersKey               = @"upvoters";
NSString *const kPTHPartyAttributesCommentCountKey           = @"commentCount";
NSString *const kPTHPartyAttributesCommentersKey             = @"commenters";


#pragma mark - Cached User Attributes
// keys
NSString *const kPTHUserAttributesPartyCountKey                 = @"partyCount";
NSString *const kPTHUserAttributesIsFriendOfCurrentUserKey      = @"isFriendOfCurrentUser";

@end