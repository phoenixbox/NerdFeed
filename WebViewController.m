//
//  WebViewController.m
//  NerdFeed
//
//  Created by Shane Rogers on 12/2/13.
//  Copyright (c) 2013 Shane Rogers. All rights reserved.
//

#import "WebViewController.h"

@implementation WebViewController

-(void)loadView
{
    // Create a webview as big as the screen
    CGRect screenFrame = [[UIScreen mainScreen]applicationFrame];
    UIWebView *wv = [[UIWebView alloc]initWithFrame:screenFrame];
    // Tell web view to scale web content to fit within bounds of webview
    [wv setScalesPageToFit:YES];
    
    [self setView:wv];
}

-(UIWebView *)webView
{
    return (UIWebView *)[self view];
}


@end
