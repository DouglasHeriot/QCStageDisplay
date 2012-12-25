//
//  main.m
//  QCStageDisplayTestClient
//
//  Created by Douglas Heriot on 25/12/12.
//  Copyright (c) 2012 Douglas Heriot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DHRVStageDisplayClient.h"

@interface Test : NSObject  <DHRVStageDisplayClientDelegate>
@end

@implementation Test
- (void)stageDisplay:(DHRVStageDisplayClient *)client didRecieveData:(NSDictionary *)data
{
	NSLog(@"Recieved data: %@", data);
}
@end


int main(int argc, const char * argv[])
{
	@autoreleasepool
	{
		Test *test = [Test new];
		
		DHRVStageDisplayClient *client = [[DHRVStageDisplayClient alloc] init];
		client.delegate = test;
		[client connectToHost:@"localhost" port:54321];
		
		dispatch_main();
	}
    return 0;
}

