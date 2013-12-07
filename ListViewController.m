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
    void(^completionBlock)(RSSChannel *obj, NSError *err)= ^(RSSChannel *obj, NSError *err){
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
    if(rssType == ListViewControllerRSSTypeBNR){
        [[BNRFeedStore sharedStore] fetchRSSFeedWithCompletion:completionBlock];
    } else if (rssType == ListViewControllerRSSTypeApple){
        [[BNRFeedStore sharedStore] fetchTopSongs:20 withCompletion:completionBlock];
    }
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)io
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        return YES;
    return io == UIInterfaceOrientationLandscapeLeft;
}
@end
