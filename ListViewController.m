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

@implementation ListViewController
@synthesize webViewController;
-(id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    
    if(self){
        [self fetchEntries];
    }
    return self;
}

-(void)parser:(NSXMLParser *)parser
didStartElement:(NSString *)elementName
   namespaceURI:(NSString *)namespaceURI
  qualifiedName:(NSString *)qName
     attributes:(NSDictionary *)attributeDict
{
    NSLog(@"%@ found a %@ element", self, elementName);
    if([elementName isEqual:@"channel"]){
        // If the parser finds a channel - create and store it in the channel ivar
        channel = [[RSSChannel alloc] init];
        
        // Give the channel a pointer back to ourselves later
        [channel setParentParserDelegate:self];
        
        // Set the parser's delegate to the channel object
        [parser setDelegate:channel];
    }
}

// Called successively as data is received
-(void)connection:(NSURLConnection *)conn didReceiveData:(NSData *)data
{
    // Add the piece of data to the data container instance variable
    // The data order is always correct
    [xmlData appendData:data];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)conn
{
    // Create a parser object with the data
    NSXMLParser *parser = [[NSXMLParser alloc]initWithData:xmlData];
     
    // Give it a delegate
    [parser setDelegate:self];
    
    // Start parsing
    [parser parse];
    
    // Release the xmlData
    xmlData = nil;
    
    // Release the connection
    connection = nil;
    
    // Reload the table
    [[self tableView]reloadData];
    WSLog(@"%@\n%@\n%@\n", channel, [channel title], [channel infoString]);
}
-(void)connection:(NSURLConnection *)conn didFailWithError:(NSError *)error
{
    // Release the connection object
    connection = nil;
    
    // Release the xmlData object
    xmlData = nil;
    
    // Get the error description
    NSString *errorString = [NSString stringWithFormat:@"Fetch Failed: %@", [error localizedDescription]];
    
    // Display the error in an AlertView
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error"
                                                 message:errorString
                                                delegate:nil
                                       cancelButtonTitle:@"OK"otherButtonTitles:nil];
    [av show];
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
    // Push the webViewController onto the navigation stack - auto creates the webViewController the first time through
    [[self navigationController]pushViewController:webViewController animated:YES];
    
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
    // Create an empty container to put the response in - assign it to our instance variable
    xmlData = [[NSMutableData alloc]init];
    
    // Construct a string URL to request data - concatenate strings over multiple lines
    NSURL *url = [NSURL URLWithString:
                  @"http://forums.bignerdranch.com/smartfeed.php?"
                  @"limit=7_DAY&sort_by=standard&feed_type=RSS2.0&feed_style=COMPACT"];
    // Or if want Apple's hot news feed
    // NSURL *url = [NSURL URLWithString:@"http://www.apple.com/pr/feeds/pr.rss"];
    
    //Convert the string URL to an NSURLRequest object
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    
    // Create a connection that will make the request - asssign it to the connection instance variable
    connection = [[NSURLConnection alloc] initWithRequest:req
                                                 delegate:self
                                         startImmediately:YES];
}
@end
