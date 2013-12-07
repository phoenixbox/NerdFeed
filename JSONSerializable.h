//
//  JSONSerializable.h
//  NerdFeed
//
//  Created by Shane Rogers on 12/7/13.
//  Copyright (c) 2013 Shane Rogers. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol JSONSerializable <NSObject>

-(void)readFromJSONDictionary:(NSDictionary *)d;

@end
