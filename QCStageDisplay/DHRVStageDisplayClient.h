//
//  DHRVStageDisplayClient.h
//  QCStageDisplay
//
//  Created by Douglas Heriot on 25/12/12.
//  Copyright (c) 2012 Douglas Heriot. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DHRVStageDisplayClient;

@protocol DHRVStageDisplayClientDelegate <NSObject>
@required
// May be called on a private thread
- (void)stageDisplay:(DHRVStageDisplayClient *)client didRecieveData:(NSDictionary *)data;
@end


@interface DHRVStageDisplayClient : NSObject
@property (readonly, copy) NSDictionary *data;
@property (copy) NSString *password;
@property (weak) id<DHRVStageDisplayClientDelegate> delegate;

- (BOOL)connectToHost:(NSString *)host port:(uint16_t)port;
- (void)disconnect;

@end
