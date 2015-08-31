//
//  PTHCommentsTableViewController.m
//  Party Hunt
//
//  Created by Jared McFarland on 12/29/14.
//  Copyright (c) 2014 Jared Colin McFarland. All rights reserved.
//

#import "PTHCommentsTableViewController.h"
#import "PTHCommentTableViewCell.h"

@interface PTHCommentsTableViewController ()

@end

@implementation PTHCommentsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (PFQuery *)queryForTable
{
    PFQuery *query = [PFQuery queryWithClassName:kPTHActivityClassKey];
    [query whereKey:kPTHActivityTypeKey equalTo:kPTHActivityTypeComment];
    [query whereKey:kPTHActivityPartyKey equalTo:self.party];
    [query orderByAscending:@"createdAt"];
    return query;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object
{
    PTHCommentTableViewCell *commentCell = (PTHCommentTableViewCell *)[tableView dequeueReusableCellWithIdentifier:kPTHCommentCellIdentifier];
    
    if (commentCell == nil)
    {
        commentCell = [[PTHCommentTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kPTHCommentCellIdentifier];
    }
    
    [self configureCell:commentCell forObject:object atIndexPath:indexPath];
    
    [commentCell setNeedsUpdateConstraints];
    [commentCell updateConstraintsIfNeeded];
    
    return commentCell;
    
}

- (void)configureCell:(PTHCommentTableViewCell *)cell forObject:(PFObject *)object atIndexPath:(NSIndexPath *)indexPath
{
    PFUser *commmenter = [object objectForKey:kPTHActivityFromUserKey];
    cell.usernameLabel.text = commmenter.username;
    cell.commentLabel.text = [object objectForKey:kPTHActivityContentKey];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
