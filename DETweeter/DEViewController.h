//
//  DEViewController.h
//  DETweeter
//
//  Copyright (c) 2011-2012 Double Encore, Inc. All rights reserved.
//

@interface DEViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIButton *deTweetButton;
@property (strong, nonatomic) IBOutlet UIButton *twTweetButton;
@property (strong, nonatomic) IBOutlet UIImageView *backgroundView;
@property (strong, nonatomic) IBOutlet UIView *buttonView;

- (IBAction)tweetUs:(id)sender;
- (IBAction)tweetThem:(id)sender;

@end
