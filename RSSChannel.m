//
//  RSSChannel.m
//  NerdFeed
//
//  Created by Shane Rogers on 12/1/13.
//  Copyright (c) 2013 Shane Rogers. All rights reserved.
//

#import "RSSChannel.h"
#import "RSSItem.h"

@implementation RSSChannel
@synthesize items, title, infoString, parentParserDelegate;

-(id)init
{
    self = [super init];
    
    if(self){
        // Create the container for the RSSItems that the channel has
        items = [[NSMutableArray alloc]init];
    }
    return self;
}

-(void)parser:(NSXMLParser *)parser
    didStartElement:(NSString *)elementName
       namespaceURI:(NSString *)namespaceURI
      qualifiedName:(NSString *)qualifiedName
         attributes:(NSDictionary *)attributeDict
{
    NSLog(@"\t%@ found a %@ element", self, elementName);
    
    if([elementName isEqual:@"title"]){
        currentString = [[NSMutableString alloc]init];
        [self setTitle:currentString];
    } else if ([elementName isEqual:@"description"]){
        currentString = [[NSMutableString alloc]init];
        [self setInfoString:currentString];
    } else if ([elementName isEqual:@"item"]){
        //When we find an item element - create an instance of RSSItem
        RSSItem *entry = [[RSSItem alloc] init];
        
        // Set the paren as ourselves so we can regain control of the parser
        [entry setParentParserDelegate:self];
        
        // Turn the parser to the RSSItem
        [parser setDelegate:entry];
        
        // Add the item to our array and release hold on it
        [items addObject:entry];
    }
}

-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)str
{
    [currentString appendString:str];
}
-(void)parser:(NSXMLParser *)parser
didEndElement:(NSString *)elementName
 namespaceURI:(NSString *)namespaceURI
qualifiedName:(NSString *)qName
{
    // If the parser was already in an element that we were collecting a string for - this would release hold of it and the permanent ivar keeps ownership
    // If we are not parsing such an element, currentString is nil already
    currentString = nil;
    
    // If the element that was ended was the channel, give up control to whom gave us control in the first place
    if([elementName isEqual:@"channel"]){
        [parser setDelegate:parentParserDelegate];
        [self trimItemTitles];
    }
}
- (void)trimItemTitles
{
    // Create a regular expression with the pattern: Author
    NSRegularExpression *reg =
    [[NSRegularExpression alloc] initWithPattern:@".* :: (.*) :: .*"
                                         options:0
                                           error:nil];
    // Loop through every title of the items in channel
    for(RSSItem *i in items) {
        NSString *itemTitle = [i title];
        
        // Find matches in the title string. The range
        // argument specifies how much of the title to search;
        // in this case, all of it.
        NSArray *matches = [reg matchesInString:itemTitle
                                        options:0
                                          range:NSMakeRange(0, [itemTitle length])];
        
        // If there was a match...
        if([matches count] > 0) {
            // Print the location of the match in the string and the string
            NSTextCheckingResult *result = [matches objectAtIndex:0];
            NSRange r = [result range];
            NSLog(@"Match at {%d, %d} for %@!", r.location, r.length, itemTitle);
            // One capture group, so two ranges, let's verify
            if([result numberOfRanges] == 2) {
                
                // Pull out the 2nd range, which will be the capture group
                NSRange r = [result rangeAtIndex:1];
                
                // Set the title of the item to the string within the capture group
                [i setTitle:[itemTitle substringWithRange:r]];
            }
        }
    }
}
@end