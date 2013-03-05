//
//  DEViewController.m
//  DETweeter
//
//  Copyright (c) 2011-2012 Double Encore, Inc. All rights reserved.
//

#import "DEViewController.h"
#import "DETweetComposeViewController.h"
#import "UIDevice+DETweetComposeViewController.h"
#import <Twitter/Twitter.h>


@interface DEViewController ()
@property (nonatomic, strong) NSArray *tweets;
@end


@implementation DEViewController

#pragma mark - Superclass Overrides

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self updateFramesForOrientation:self.interfaceOrientation];
    
    self.tweets = @[@"Step into my office.",
                   @"Please take a seat. I suppose you're wondering why I called you all here…",
                   @"You eyeballin' me son?!",
                   @"I'm going to make him an offer he can't refuse.",
                   @"You talkin' to me?",
                   @"Who's in charge here?",
                   @"I swear, the cat was alive when I left.",
                   @"I will never get into the trash ever again. I swear.",
                   @"Somebody throw me a bone here!",
                   @"Really? Another meeting?",
                   @"Type faster!",
                   @"How was I supposed to know you didn't leave the trash out for me?",
                   @"It's been a ruff day for all of us.",
                   @"The maple kind, yeah?",
                   @"Unless you brought enough biscuits for everyone I suggest you leave.",
                   @"Would you file a new TPS report for 1 Scooby Snack? How about 2?"];
    
    [self tweetUs];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([UIDevice de_isPhone]) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    }
    else {
        return YES;
    }
}


- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
    [self updateFramesForOrientation:interfaceOrientation];
}



#pragma mark - Private

- (void)updateFramesForOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    CGRect frame = self.buttonView.frame;
    frame.origin.x = trunc((self.view.bounds.size.width - frame.size.width) / 2);
    if ([UIDevice de_isPhone]) {
        frame.origin.y = UIInterfaceOrientationIsPortrait(interfaceOrientation) ? 306.0f : 210.0f;
    }
    else {
        frame.origin.y = UIInterfaceOrientationIsPortrait(interfaceOrientation) ? 722.0f : 535.0f;
    }
    self.buttonView.frame = frame;
    
    frame = self.backgroundView.frame;
    frame.origin.x = trunc((self.view.bounds.size.width - frame.size.width) / 2);
    frame.origin.y = trunc((self.view.bounds.size.height - frame.size.height) / 2) - 10.0f;
    self.backgroundView.frame = frame;
}


- (void)tweetUs
{    
    DETweetComposeViewController *tcvc = [[DETweetComposeViewController alloc] init];
    self.modalPresentationStyle = UIModalPresentationCurrentContext;
    [self addTweetContent:tcvc];
    
    [self presentModalViewController:tcvc animated:YES];
}


- (void)addTweetContent:(DETweetComposeViewController *)tcvc
{
    NSString *tweetText = (self.tweets)[arc4random() % [self.tweets count]];
    [tcvc setInitialText:tweetText];
}


#pragma mark - Actions

- (IBAction)tweetUs:(id)sender
{    
    [self tweetUs];
}


- (IBAction)tweetThem:(id)sender {    
}


@end
