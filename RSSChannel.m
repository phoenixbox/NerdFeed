//
//  RSSChannel.m
//  NerdFeed
//
//  Created by Shane Rogers on 12/1/13.
//  Copyright (c) 2013 Shane Rogers. All rights reserved.
//

#import "RSSChannel.h"

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
    }
}

-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)str
{
    [currentString appendString:str];
}
-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    // If the parser was already in an element that we were collecting a string for - this would release hold of it and the permanent ivar keeps ownership
    // If we are not parsing such an element, currentString is nil already
    currentString = nil;
    
    // If the element that was ended was the channel, give up control to whom gave us control in the first place
    if([elementName isEqual:@"channel"]){
        [parser setDelegate:parentParserDelegate];
    }
}
@end
