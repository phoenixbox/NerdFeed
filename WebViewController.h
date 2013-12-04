//
//  WebViewController.h
//  NerdFeed
//
//  Created by Shane Rogers on 12/2/13.
//  Copyright (c) 2013 Shane Rogers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ListViewController.h"

@interface WebViewController : UIViewController <ListViewControllerDelegate, UISplitViewControllerDelegate>

@property (nonatomic, readonly) UIWebView *webView;

@end
