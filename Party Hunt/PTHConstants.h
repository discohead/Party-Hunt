//
//  PTHConstants.h
//  Party Hunt
//
//  Created by Jared McFarland on 9/25/14.
//  Copyright (c) 2014 Jared Colin McFarland. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PTHConstants : NSObject

#pragma mark - NSUserDefaults
extern NSString *const kPTHUserDefaultsActivityFeedViewControllerLastRefreshKey;
extern NSString *const kPTHUserDefaultsCacheFacebookFriendsKey;

#pragma mark - PFObject Activity Class
// Class key
extern NSString *const kPTHActivityClassKey;

// Field keys
extern NSString *const kPTHActivityTypeKey;
extern NSString *const kPTHActivityFromUserKey;
extern NSString *const kPTHActivityToUserKey;
extern NSString *const kPTHActivityContentKey;
extern NSString *const kPTHActivityPartyKey;
extern NSString *const kPTHActivityParentCommentKey;

// Type values
extern NSString *const kPTHActivityTypeUpvote;
extern NSString *const kPTHActivityTypeFriend;
extern NSString *const kPTHActivityTypeComment;
extern NSString *const kPTHActivityTypeJoined;
extern NSString *const kPTHActivityTypeSubmitted;


#pragma mark - PFObject User Class
// Field keys
extern NSString *const kPTHUserDisplayNameKey;
extern NSString *const kPTHUserFacebookIDKey;
extern NSString *const kPTHUserPhotoIDKey;
extern NSString *const kPTHUserProfilePicSmallKey;
extern NSString *const kPTHUserProfilePicMediumKey;
extern NSString *const kPTHUserFacebookFriendsKey;
extern NSString *const kPTHUserAlreadyAutoFollowedFacebookFriendsKey;

#pragma mark - Facebook Event Keys

extern NSString *const kPTHFbEventsCreated;
extern NSString *const kPTHFbEventsAttending;
extern NSString *const kPTHFbEventsMaybe;
extern NSString *const kPTHFbEventsNotReplied;
extern NSString *const kPTHFbEventsDeclined;

#pragma mark - PFObject Party Class
// Class key
extern NSString *const kPTHPartyClassKey;

// Field keys
extern NSString *const kPTHPartyNameKey;
extern NSString *const kPTHPartyGeoLocationKey;
extern NSString *const kPTHPartyStartTimeKey;
extern NSString *const kPTHPartyEndTimeKey;
extern NSString *const kPTHPartyFbEventIdKey;
extern NSString *const kPTHPartyUserKey;
extern NSString *const kPTHPartyVenueKey;
extern NSString *const kPTHPartyDescriptionKey;
extern NSString *const kPTHPartyLocationKey;
extern NSString *const kPTHPartyPrivacyKey;
extern NSString *const kPTHPartyCommentCountKey;
extern NSString *const kPTHPartyUpvotersKey;
extern NSString *const kPTHPartyUpvoteCountKey;
extern NSString *const kPTHPartyTicketLinkKey;

#pragma mark - Cached User Attributes
// keys
extern NSString *const kPTHUserAttributesPartyCountKey;
extern NSString *const kPTHUserAttributesIsFriendOfCurrentUserKey;

#pragma mark - Cell Identifiers

extern NSString *const kPTHPartyCellIdentifier;
extern NSString *const kPTHDetailCellIdentifier;
extern NSString *const kPTHDescriptionCellIdentifier;
extern NSString *const kPTHPhotoCellIdentifier;
extern NSString *const kPTHAddressCellIdentifier;
extern NSString *const kPTHCommentCellIdentifier;

extern double const kPTHAreaOfInterest;

@end
