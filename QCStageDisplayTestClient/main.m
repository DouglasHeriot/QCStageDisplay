//
//  main.m
//  QCStageDisplayTestClient
//
//  Created by Douglas Heriot on 25/12/12.
//  Copyright (c) 2012 Douglas Heriot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DHRVStageDisplayClient.h"

int main(int argc, const char * argv[])
{
	@autoreleasepool
	{
		DHRVStageDisplayClient *client = [[DHRVStageDisplayClient alloc] init];
		[client connectToHost:@"localhost" port:54321];
		
		dispatch_main();
	}
    return 0;
}

