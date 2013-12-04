//
//  WebViewController.m
//  NerdFeed
//
//  Created by Shane Rogers on 12/2/13.
//  Copyright (c) 2013 Shane Rogers. All rights reserved.
//

#import "WebViewController.h"
#import "RSSItem.h"

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
-(void)listViewController:(ListViewController *)lvc handleObject:(id)object
{
    // Cast the passed object to RSSItem
    RSSItem *entry = object;
    
    // Make sure that we are getting an RSSItem
    if(![entry isKindOfClass:[RSSItem class]]){
        return;
    }
    
    // Grab the info from the item and push to the right view
    NSURL *url = [NSURL URLWithString:[entry link]];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    [[self webView] loadRequest:req];
    
    [[self navigationItem] setTitle:[entry title]];
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)io
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        return YES;
    return io == UIInterfaceOrientationLandscapeLeft;
}
-(UIWebView *)webView
{
    return (UIWebView *)[self view];
}
-(void)splitViewController:(UISplitViewController *)svc
    willHideViewController:(UIViewController *)aViewController
         withBarButtonItem:(UIBarButtonItem *)barButtonItem
      forPopoverController:(UIPopoverController *)pc
{
    // Give the bar button item a title so that it appears
    [barButtonItem setTitle:@"List"];
    
    // Insert the bar button item to the left of nav item
    [[self navigationItem]setLeftBarButtonItem:barButtonItem];
}
-(void)splitViewController:(UISplitViewController *)svc
    willShowViewController:(UIViewController *)aViewController
 invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    if(barButtonItem==[[self navigationItem] leftBarButtonItem]){
        [[self navigationItem] setLeftBarButtonItem:nil];
    }
}
@end
