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
#import "DetailCell.h"

enum {
    kCustomCellTitleLabel = 1000
};

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
-(void)viewDidLoad
{
    [super viewDidLoad];
    if(rssType == ListViewControllerRSSTypeBNR){
        UINib *nib = [UINib nibWithNibName:@"DetailCell" bundle:nil];
        
        [[self tableView] registerNib:nib forCellReuseIdentifier:@"DetailCell"];
    }
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
    RSSItem *item = [[channel items] objectAtIndex:[indexPath row]];
    
    if(rssType == ListViewControllerRSSTypeBNR){
        NSLog(@"Type is: BNR");
        
        static NSString *cellIdentifier = @"cellIdentifier";
        
        static const int kLabel = 1010; // constant for the label tag
        static const int kImage = 1020; // constant for the imageView tag
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if (cell == nil) {
            
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            
            CGRect myImageFrame = CGRectMake(10, 10, 50, 25);
            UIImageView *myImageView = [[UIImageView alloc] initWithFrame:myImageFrame];
            myImageView.tag = kLabel;
            [cell.contentView addSubview:myImageView];
            
            UILabel *myLabel = [[UILabel alloc] init];
            myLabel.frame = CGRectMake(75, 10, 200, 25);
            myLabel.tag = kImage;
            [cell.contentView addSubview:myLabel];
        }
        
        UIImageView *myImageView = (UIImageView *)[cell viewWithTag:kLabel];
        [myImageView setImage:[UIImage imageNamed:@"cellimage.png"]];
        UILabel *myLabel = (UILabel *)[cell viewWithTag:kImage];
        myLabel.text = [item title];
        
        
        if([[BNRFeedStore sharedStore] hasItemBeenRead:item]){
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        } else {
            [cell setAccessoryType:UITableViewCellAccessoryNone];
        }
        
        return cell;
    } else {
        NSLog(@"Type is: Apple");
        // Dequeue the Detail Cell
        DetailCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DetailCell"];
        // Configure the Detail Cell
        [[cell titleLabel] setText:[item title]];
        [[cell collectionLabel] setText:[item collection]];
        [[cell priceLabel] setText:[item price]];
        
        [[cell imageView] setImage:[UIImage imageNamed:@"collection_image.jpg"]];
        
        if([[BNRFeedStore sharedStore] hasItemBeenRead:item]){
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        } else {
            [cell setAccessoryType:UITableViewCellAccessoryNone];
        }
        
        return cell;
    };
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
    
    [[BNRFeedStore sharedStore]markItemAsRead:entry];
    
    // Add checkmark to the row
    [[[self tableView]cellForRowAtIndexPath:indexPath]setAccessoryType:UITableViewCellAccessoryCheckmark];
    
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
