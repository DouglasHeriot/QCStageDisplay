//
//  DHRVStageDisplayClient.h
//  QCStageDisplay
//
//  Created by Douglas Heriot on 25/12/12.
//  Copyright (c) 2012 Douglas Heriot. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DHRVStageDisplayClient : NSObject
@property (readonly, copy) NSDictionary *data;
@property (copy) NSString *password;

- (BOOL)connectToHost:(NSString *)host port:(uint16_t)port;
- (void)disconnect;

@end
