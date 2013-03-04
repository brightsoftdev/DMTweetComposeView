DETweetComposeViewController
============================

only composer UI, without twitter related.

## What is it?
DETweetComposeViewController is an iOS 4 compatible version of the TWTweetComposeView controller. Otherwise known as the Tweet Sheet.

## Why did we make it?
The iOS 5 TWTweetComposeViewController makes it really simple to integrate Twitter posting into you applications. However we still need to support iOS 4 in many of our applications. Having something that looks and acts like the built in Tweet Sheet allows us to have a consistent user interface across iOS versions.

## What does it look like?
![DETweetComposeViewController](https://github.com/downloads/doubleencore/DETweetComposeViewController/DETweetComposeViewController.png) ![TWTweetComposeViewController](https://github.com/downloads/doubleencore/DETweetComposeViewController/TWTweetComposeViewController.png)

As you can see they look very similar.  
  
## How do you use it?

1. Add all the files from the DETweetComposeViewController/DETweetComposeViewController folder to your project.
2. Use it almost just like you would a TWTweetComposeViewController

```
#import "DETweetComposeViewController.h"
...
DETweetComposeViewController *tcvc = [[[DETweetComposeViewController alloc] init] autorelease];
[tcvc addImage:[UIImage imageNamed:@"YawkeyBusinessDog.jpg"]];
[tcvc addURL:[NSURL URLWithString:@"http://www.DoubleEncore.com/"]];
[tcvc addURL:[NSURL URLWithString:@"http://www.apple.com/ios/features.html#twitter"]];
self.modalPresentationStyle = UIModalPresentationCurrentContext;
[self presentModalViewController:tcvc animated:YES];
```
