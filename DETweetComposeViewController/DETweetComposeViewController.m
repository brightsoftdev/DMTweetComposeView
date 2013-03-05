    //
    //  DETweetComposeViewController.m
    //  DETweeter
    //
    //  Copyright (c) 2011-2012 Double Encore, Inc. All rights reserved.
    //
    //  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
    //  Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
    //  Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer 
    //  in the documentation and/or other materials provided with the distribution. Neither the name of the Double Encore Inc. nor the names of its 
    //  contributors may be used to endorse or promote products derived from this software without specific prior written permission.
    //  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, 
    //  THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS 
    //  BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE 
    //  GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT 
    //  LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
    //

#import "DETweetComposeViewController.h"
#import "DETweetSheetCardView.h"
#import "DETweetTextView.h"
#import "DETweetGradientView.h"
#import "UIDevice+DETweetComposeViewController.h"
#import <QuartzCore/QuartzCore.h>


@interface DETweetComposeViewController ()
@property (nonatomic, copy) NSString *text;
@property (nonatomic) UIStatusBarStyle previousStatusBarStyle;
@property (nonatomic, unsafe_unretained) UIViewController *fromViewController;
@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) DETweetGradientView *gradientView;
@property (nonatomic, strong) UIPickerView *accountPickerView;
@end


@implementation DETweetComposeViewController
enum {
    DETweetComposeViewControllerNoAccountsAlert = 1,
    DETweetComposeViewControllerCannotSendAlert
};

NSInteger const DETweetMaxLength = 140;
NSInteger const DETweetURLLength = 20;  // https://dev.twitter.com/docs/tco-url-wrapper
NSInteger const DETweetMaxImages = 1;  // We'll get this dynamically later, but not today.
static NSString * const DETweetLastAccountIdentifier = @"DETweetLastAccountIdentifier";

#define degreesToRadians(x) (M_PI * x / 180.0f)



- (UIImage *) captureScreen {
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    CGRect rect = [keyWindow bounds];
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (![[UIApplication sharedApplication] isStatusBarHidden]) {
        CGFloat statusBarOffset = -20.0f;
        if ( UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication]statusBarOrientation]))
        {
            CGContextTranslateCTM(context,statusBarOffset, 0.0f);

        }else
        {
            CGContextTranslateCTM(context, 0.0f, statusBarOffset);
        }
    }
    
    [keyWindow.layer renderInContext:context];   
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImageOrientation imageOrientation;
    switch ([UIApplication sharedApplication].statusBarOrientation) {
        case UIInterfaceOrientationLandscapeLeft:
            imageOrientation = UIImageOrientationRight;
            break;
        case UIInterfaceOrientationLandscapeRight:
            imageOrientation = UIImageOrientationLeft;
            break;
        case UIInterfaceOrientationPortrait:
            imageOrientation = UIImageOrientationUp;
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            imageOrientation = UIImageOrientationDown;
            break;
        default:
            break;
    }
    
    UIImage *outputImage = [[UIImage alloc] initWithCGImage: image.CGImage
                                                      scale: 1.0
                                                orientation: imageOrientation];
    return outputImage;
}

#pragma mark - Setup & Teardown


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

#pragma mark - Superclass Overrides

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    self.textViewContainer.backgroundColor = [UIColor clearColor];
    self.textView.backgroundColor = [UIColor clearColor];
    
    if ([UIDevice de_isIOS5]) {
        self.fromViewController = self.presentingViewController;
        self.textView.keyboardType = UIKeyboardTypeTwitter;
    }
    else {
        self.fromViewController = self.parentViewController;
    }
    
    self.textView.text = self.text;
    [self.textView becomeFirstResponder];
    
    [self updateCharacterCount];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

        // Take a snapshot of the current view, and make that our background after our view animates into place.
        // This only works if our orientation is the same as the presenting view.
        // If they don't match, just display the gray background.
    if (self.interfaceOrientation == self.fromViewController.interfaceOrientation) {
        UIImage *backgroundImage = [self captureScreen];
        self.backgroundImageView = [[UIImageView alloc] initWithImage:backgroundImage];
    }
    else {
        self.backgroundImageView = [[UIImageView alloc] initWithFrame:self.fromViewController.view.bounds];
    }
    self.backgroundImageView.autoresizingMask = UIViewAutoresizingNone;
    self.backgroundImageView.alpha = 0.0f;
    self.backgroundImageView.backgroundColor = [UIColor lightGrayColor];
    [self.view insertSubview:self.backgroundImageView atIndex:0];
    
        // Now let's fade in a gradient view over the presenting view.
    self.gradientView = [[DETweetGradientView alloc] initWithFrame:[UIApplication sharedApplication].keyWindow.bounds];
    self.gradientView.autoresizingMask = UIViewAutoresizingNone;
    self.gradientView.transform = self.fromViewController.view.transform;
    self.gradientView.alpha = 0.0f;
    self.gradientView.center = [UIApplication sharedApplication].keyWindow.center;
    [self.fromViewController.view addSubview:self.gradientView];
    [UIView animateWithDuration:0.3f
                     animations:^ {
                         self.gradientView.alpha = 1.0f;
                     }];    
    
    self.previousStatusBarStyle = [UIApplication sharedApplication].statusBarStyle;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:YES]; 
    
    [self updateFramesForOrientation:self.interfaceOrientation];
    
    
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.backgroundImageView.alpha = 1.0f;
    //self.backgroundImageView.frame = [self.view convertRect:self.backgroundImageView.frame fromView:[UIApplication sharedApplication].keyWindow];
    [self.view insertSubview:self.gradientView aboveSubview:self.backgroundImageView];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    UIView *presentingView = [UIDevice de_isIOS5] ? self.fromViewController.view : self.parentViewController.view;
    [presentingView addSubview:self.gradientView];
    
    [self.backgroundImageView removeFromSuperview];
    self.backgroundImageView = nil;
    
    [UIView animateWithDuration:0.3f
                     animations:^ {
                         self.gradientView.alpha = 0.0f;
                     }
                     completion:^(BOOL finished) {
                         [self.gradientView removeFromSuperview];
                     }];
    
    [[UIApplication sharedApplication] setStatusBarStyle:self.previousStatusBarStyle animated:YES];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([self.parentViewController respondsToSelector:@selector(shouldAutorotateToInterfaceOrientation:)]) {
        return [self.parentViewController shouldAutorotateToInterfaceOrientation:interfaceOrientation];
    }
    
    if ([UIDevice de_isPhone]) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    }

    return YES;  // Default for iPad.
}


- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
    [self updateFramesForOrientation:interfaceOrientation];
    self.accountPickerView.alpha = 0.0f;
    
        // Our fake background won't rotate properly. Just hide it.
    if (interfaceOrientation == self.presentedViewController.interfaceOrientation) {
        self.backgroundImageView.alpha = 1.0f;
    }
    else {
        self.backgroundImageView.alpha = 0.0f;
    }
}


- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self.accountPickerView removeFromSuperview];
    self.accountPickerView = nil;  // Easier to recreate it next time rather than resize it.
}


#pragma mark - Public

- (BOOL)setInitialText:(NSString *)initialText
{
    if ([self isPresented]) {
        return NO;
    }
    
    if (([self charactersAvailable] - (NSInteger)[initialText length]) < 0) {
        return NO;
    }
    
    self.text = initialText;  // Keep a copy in case the view isn't loaded yet.
    self.textView.text = self.text;
    
    return YES;
}



#pragma mark - Private

- (void)updateFramesForOrientation:(UIInterfaceOrientation)interfaceOrientation
{    
    CGFloat buttonHorizontalMargin = 8.0f;
    CGFloat cardWidth, cardTop, cardHeight, cardHeaderLineTop, buttonTop;
    UIImage *cancelButtonImage, *sendButtonImage;
    CGFloat titleLabelFontSize, titleLabelTop;
    CGFloat characterCountLeft, characterCountTop;
    
    if ([UIDevice de_isPhone]) {
        cardWidth = CGRectGetWidth(self.view.bounds) - 10.0f;
        if (UIInterfaceOrientationIsPortrait(interfaceOrientation)) {
            cardTop = 25.0f;
            cardHeight = 189.0f;
            buttonTop = 7.0f;
            cancelButtonImage = [[UIImage imageNamed:@"DETweetCancelButtonPortrait"] stretchableImageWithLeftCapWidth:4 topCapHeight:0];
            sendButtonImage = [[UIImage imageNamed:@"DETweetSendButtonPortrait"] stretchableImageWithLeftCapWidth:4 topCapHeight:0];
            cardHeaderLineTop = 41.0f;
            titleLabelFontSize = 20.0f;
            titleLabelTop = 9.0f;
        }
        else {
            cardTop = -1.0f;
            cardHeight = 150.0f;
            buttonTop = 6.0f;
            cancelButtonImage = [[UIImage imageNamed:@"DETweetCancelButtonLandscape"] stretchableImageWithLeftCapWidth:4 topCapHeight:0];
            sendButtonImage = [[UIImage imageNamed:@"DETweetSendButtonLandscape"] stretchableImageWithLeftCapWidth:4 topCapHeight:0];
            cardHeaderLineTop = 32.0f;
            titleLabelFontSize = 17.0f;
            titleLabelTop = 5.0f;
        }
    }
    else {  // iPad. Similar to iPhone portrait.
        cardWidth = 543.0f;
        cardHeight = 189.0f;
        buttonTop = 7.0f;
        cancelButtonImage = [[UIImage imageNamed:@"DETweetCancelButtonPortrait"] stretchableImageWithLeftCapWidth:4 topCapHeight:0];
        sendButtonImage = [[UIImage imageNamed:@"DETweetSendButtonPortrait"] stretchableImageWithLeftCapWidth:4 topCapHeight:0];
        cardHeaderLineTop = 41.0f;
        titleLabelFontSize = 20.0f;
        titleLabelTop = 9.0f;
        if (UIInterfaceOrientationIsPortrait(interfaceOrientation)) {
            cardTop = 280.0f;
        }
        else {
            cardTop = 110.0f;
        }
    }
    
    CGFloat cardLeft = trunc((CGRectGetWidth(self.view.bounds) - cardWidth) / 2);
    self.cardView.frame = CGRectMake(cardLeft, cardTop, cardWidth, cardHeight);
    
    self.titleLabel.font = [UIFont boldSystemFontOfSize:titleLabelFontSize];
    self.titleLabel.frame = CGRectMake(0.0f, titleLabelTop, cardWidth, self.titleLabel.frame.size.height);
    
    [self.cancelButton setBackgroundImage:cancelButtonImage forState:UIControlStateNormal];
    self.cancelButton.frame = CGRectMake(buttonHorizontalMargin, buttonTop, self.cancelButton.frame.size.width, cancelButtonImage.size.height);
    
    [self.sendButton setBackgroundImage:sendButtonImage forState:UIControlStateNormal];
    self.sendButton.frame = CGRectMake(self.cardView.bounds.size.width - buttonHorizontalMargin - self.sendButton.frame.size.width, buttonTop, self.sendButton.frame.size.width, sendButtonImage.size.height);
    
    self.cardHeaderLineView.frame = CGRectMake(0.0f, cardHeaderLineTop, self.cardView.bounds.size.width, self.cardHeaderLineView.frame.size.height);
    
    CGFloat textWidth = CGRectGetWidth(self.cardView.bounds);
    
    CGFloat textTop = CGRectGetMaxY(self.cardHeaderLineView.frame) - 1.0f;
    CGFloat textHeight = self.cardView.bounds.size.height - textTop - 30.0f;
    self.textViewContainer.frame = CGRectMake(0.0f, textTop, self.cardView.bounds.size.width, textHeight);
    self.textView.frame = CGRectMake(0.0f, 0.0f, textWidth, self.textViewContainer.frame.size.height);
    self.textView.scrollIndicatorInsets = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, -(self.cardView.bounds.size.width - textWidth - 1.0f));
    
    characterCountLeft = CGRectGetWidth(self.cardView.frame) - CGRectGetWidth(self.characterCountLabel.frame) - 12.0f;
    characterCountTop = CGRectGetHeight(self.cardView.frame) - CGRectGetHeight(self.characterCountLabel.frame) - 8.0f;

    self.characterCountLabel.frame = CGRectMake(characterCountLeft, characterCountTop, self.characterCountLabel.frame.size.width, self.characterCountLabel.frame.size.height);
    
    self.gradientView.frame = self.gradientView.superview.bounds;
}


- (BOOL)isPresented
{
    return [self isViewLoaded];
}


- (NSInteger)charactersAvailable
{
    NSInteger available = DETweetMaxLength;
    available -= [self.textView.text length];
    
    if ( (available < DETweetMaxLength) && ([self.textView.text length] == 0) ) {
        available += 1;  // The space we added for the first URL isn't needed.
    }
    
    return available;
}


- (void)updateCharacterCount
{
    NSInteger available = [self charactersAvailable];
    
    self.characterCountLabel.text = [NSString stringWithFormat:@"%d", available];
    
    if (available >= 0) {
        self.characterCountLabel.textColor = [UIColor grayColor];
        self.sendButton.enabled = (available != DETweetMaxLength);  // At least one character is required.
    }
    else {
        self.characterCountLabel.textColor = [UIColor colorWithRed:0.64f green:0.32f blue:0.32f alpha:1.0f];
        self.sendButton.enabled = NO;
    }
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView
{
    [self updateCharacterCount];
}



#pragma mark - Actions

- (IBAction)send
{
    self.sendButton.enabled = NO;
    
//    NSString *tweet = self.textView.text;
}


- (IBAction)cancel
{
    [self dismissModalViewControllerAnimated:YES];
}

@end
