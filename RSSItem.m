//
//  RSSItem.m
//  NerdFeed
//
//  Created by Shane Rogers on 12/1/13.
//  Copyright (c) 2013 Shane Rogers. All rights reserved.
//

#import "RSSItem.h"

@implementation RSSItem

@synthesize title, link, parentParserDelegate, publicationDate;

-(void)parser:(NSXMLParser *)parser
    didStartElement:(NSString *)elementName
       namespaceURI:(NSString *)namespaceURI
      qualifiedName:(NSString *)qualifiedName
         attributes:(NSDictionary *)attributeDict
{
    NSLog(@"\t\t%@ found a XXX %@ element", self, elementName);

    if([elementName isEqual:@"title"]){
        currentString = [[NSMutableString alloc]init];
        [self setTitle:currentString];
    } else if ([elementName isEqual:@"link"]){
        currentString = [[NSMutableString alloc]init];
        [self setLink:currentString];
    } else if ([elementName isEqualToString:@"pubDate"]){
        // Create the string but not assigned to the ivar yet!
        currentString = [[NSMutableString alloc]init];
    } else if ([elementName isEqualToString:@"description"]){
        currentString = [[NSMutableString alloc]init];
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
    // If the pubDate ends, use a date formatter to turn it into an NSDate
    if ([elementName isEqualToString:@"pubDate"]) {
        static NSDateFormatter *dateFormatter = nil;
        if (!dateFormatter) {
            dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss z"];
        }
        [self setPublicationDate:[dateFormatter dateFromString:currentString]];
    }
    currentString = nil;
    
    if([elementName isEqual:@"item"]||[elementName isEqual:@"entry"]){
        [parser setDelegate:parentParserDelegate];
    }
        
}
- (void)readFromJSONDictionary:(NSDictionary *)d
{
    // Name of the song
    [self setTitle:[[d objectForKey:@"title"] objectForKey:@"label"]];
    
    // Link to the
    NSArray *links = [d objectForKey:@"link"];
    if ([links count] > 1) {
        NSDictionary *sampleDict = [[links objectAtIndex:1]
                                    objectForKey:@"attributes"];
        // The href of an attribute object is the URL for the sample audio file
        [self setLink:[sampleDict objectForKey:@"href"]];
    }
    // Album Collection Name
    NSString *collection = [[[d objectForKey:@"im:collection" ] objectForKey:@"im:name"] objectForKey:@"label"];
    [self setCollection:collection];
    
    // Album Image Art
    NSArray *imageLinks = [d objectForKey:@"im:image"];
    if ([imageLinks count] > 1){
        NSURL *imageURL = [[links objectAtIndex:0] objectForKey:@"label"];
        [self setImage:imageURL];
    }
    // Song Price
    NSString *price = [[d objectForKey:@"im:price"] objectForKey:@"label"];
    [self setPrice:price];
}
-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:title forKey:@"title"];
    [aCoder encodeObject:link forKey:@"link"];
    [aCoder encodeObject:_collection forKey:@"collection"];
    [aCoder encodeObject:_price forKey:@"price"];
    [aCoder encodeObject:publicationDate forKey:@"publicationDate"];
}
-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if(self){
        [self setTitle:[aDecoder decodeObjectForKey:@"title"]];
        [self setLink:[aDecoder decodeObjectForKey:@"link"]];
        [self setCollection:[aDecoder decodeObjectForKey:@"collection"]];
        [self setPrice:[aDecoder decodeObjectForKey:@"price"]];
        [self setPublicationDate:[aDecoder decodeObjectForKey:@"publicationDate"]];
    }
    return self;
}
- (BOOL)isEqual:(id)object
{
    // Make sure we are comparing an RSSItem!
    if (![object isKindOfClass:[RSSItem class]])
        return NO;
    // Now only return YES if the links are equal.
    return [[self link] isEqual:[object link]];
}
@end