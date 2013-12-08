//
//  ListViewController.m
//  NerdFeed
//
//  Created by Shane Rogers on 12/1/13.
//  Copyright (c) 2013 Shane Rogers. All rights reserved.
//

#import "ListViewController.h"
#import "RSSChannel.h"
#import "RSSItem.h"
#import "WSLog.h"
#import "WebViewController.h"
#import "ChannelViewController.h"
#import "BNRFeedStore.h"

@implementation ListViewController
@synthesize webViewController;

-(id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    
    if(self){
        UIBarButtonItem *bbi = [[UIBarButtonItem alloc]initWithTitle:@"Info"
                                                               style:UIBarButtonItemStyleBordered
                                                              target:self
                                                              action:@selector(showInfo:)];
        
        [[self navigationItem] setRightBarButtonItem:bbi];
        
        UISegmentedControl *rssTypeControl =
        [[UISegmentedControl alloc] initWithItems:
         [NSArray arrayWithObjects:@"FAQ's", @"Songs", nil]];
        [rssTypeControl setSelectedSegmentIndex:0];
        [rssTypeControl addTarget:self
                           action:@selector(changeType:)
                 forControlEvents:UIControlEventValueChanged];
        [[self navigationItem] setTitleView:rssTypeControl];
        
        [self fetchEntries];
    }
    return self;
}

- (void)changeType:(id)sender
{
    rssType = [sender selectedSegmentIndex];
    [self fetchEntries];
}

- (void)showInfo:(id)sender
{
    // Create the channel view controller
    ChannelViewController *channelViewController = [[ChannelViewController alloc]
                                                    initWithStyle:UITableViewStyleGrouped];
    if ([self splitViewController]) {
        UINavigationController *nvc = [[UINavigationController alloc]
                                       initWithRootViewController:channelViewController];
        // Create an array with our nav controller and this new VC's nav controller
        NSArray *vcs = [NSArray arrayWithObjects:[self navigationController],
                        nvc, nil];
        // Grab a pointer to the split view controller and reset its view controllers array.
        [[self splitViewController] setViewControllers:vcs];
        // Make detail view controller the delegate of the split view controller
        [[self splitViewController] setDelegate:channelViewController];
        // If a row has been selected, deselect it so that a row is not selected when viewing the info
        NSIndexPath *selectedRow = [[self tableView] indexPathForSelectedRow];
        if (selectedRow) {
            [[self tableView] deselectRowAtIndexPath:selectedRow animated:YES];
        }
    } else {
        [[self navigationController] pushViewController:channelViewController
                                               animated:YES];
    }
    // Give the VC the channel object through the protocol message
    [channelViewController listViewController:self handleObject:channel];
}


// ! Table view data source methods !
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[channel items] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView
                             dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:@"UITableViewCell"];
    }
    RSSItem *item = [[channel items] objectAtIndex:[indexPath row]];
    [[cell textLabel] setText:[item title]];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(![self splitViewController]){
        // Push the webViewController onto the navigation stack - auto creates the webViewController the first time through
        [[self navigationController] pushViewController:webViewController animated:YES];
    } else {
        // Create a new nav controller as the last was destroyed
        UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:webViewController];
        
        NSArray *vcs = [NSArray arrayWithObjects:[self navigationController], nav, nil];
        
        [[self splitViewController]setViewControllers:vcs];
        
        [[self splitViewController] setDelegate:webViewController];
        
    }
    
    // Grab the selected RSSItem from the channels items
    RSSItem *entry = [[channel items]objectAtIndex:[indexPath row]];
    
    // Construct the URL with the link string attribute of the item
    NSURL *url = [NSURL URLWithString:[entry link]];
    
    // Create a NSURLRequest object with the URL
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    
    // Load the request into the web view
    [[webViewController webView]loadRequest:req];
    
    // Set the title of the webViewController's navigation item
    [[webViewController navigationItem]setTitle:[entry title]];
}

-(void)fetchEntries
{
    // Target the segmented control in the title view
    UIView *currentTitleView = [[self navigationItem] titleView];
    
    // Create an activity indicator and start it spinning in the nav bar
    UIActivityIndicatorView *aiView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [[self navigationItem] setTitleView:aiView];
    [aiView startAnimating];
    
    
    void(^completionBlock)(RSSChannel *obj, NSError *err)= ^(RSSChannel *obj, NSError *err){
        // After any request - replace the spinner with the segmented control
        [[self navigationItem] setTitleView:currentTitleView];
        if(!err){
            channel = obj;
            [[self tableView]reloadData];
        } else {
            NSString *errorString = [NSString stringWithFormat:@"Fetch failed: %@", [err localizedDescription]];
            
            UIAlertView *av = [[UIAlertView alloc]initWithTitle:@"Error"
                                                        message:errorString
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
            [av show];
        }
    };
    
    // Initiate the request based on RSSType
    if (rssType == ListViewControllerRSSTypeBNR) {
        channel = [[BNRFeedStore sharedStore] fetchRSSFeedWithCompletion: ^(RSSChannel *obj, NSError *err) {
            // Replace the activity indicator.
            [[self navigationItem] setTitleView:currentTitleView];
            if (!err) {
                // How many items are there currently?
                int currentItemCount = [[channel items] count];
                // Set our channel to the merged one
                channel = obj;
                // How many items are there now?
                int newItemCount = [[channel items] count];
                // For each new item, insert a new row. The data source
                // will take care of the rest.
                int itemDelta = newItemCount - currentItemCount;
                if (itemDelta > 0) {
                    NSMutableArray *rows = [NSMutableArray array];
                    for (int i = 0; i < itemDelta; i++) {
                        NSIndexPath *ip = [NSIndexPath indexPathForRow:i inSection:0];
                        [rows addObject:ip];
                        }
                    [[self tableView] insertRowsAtIndexPaths:rows withRowAnimation:UITableViewRowAnimationTop];
                }
            }
        }];
    
        [[self tableView] reloadData];
    } else if (rssType == ListViewControllerRSSTypeApple)
        [[BNRFeedStore sharedStore] fetchTopSongs:10 withCompletion:completionBlock];
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)io
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        return YES;
    return io == UIInterfaceOrientationLandscapeLeft;
}
@end
