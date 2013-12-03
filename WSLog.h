//
//  WSLog.h
//  NerdFeed
//
//  Created by Shane Rogers on 12/2/13.
//  Copyright (c) 2013 Shane Rogers. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WSLog : NSObject
#define WSLog(...) NSLog(__VA_ARGS__)
// Turn off custom logs
// #define WSLog(...) do {} while(0)
@end
