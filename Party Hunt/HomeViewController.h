//
//  HomeViewController.h
//  Party Hunt
//
//  Created by Jared McFarland on 9/20/14.
//  Copyright (c) 2014 Jared Colin McFarland. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeViewController : UIViewController

- (IBAction)signOutButtonTapped:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *welcomeLabel;
@property (weak, nonatomic) IBOutlet UIButton *signInOutButton;

@end
