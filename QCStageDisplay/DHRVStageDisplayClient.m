//
//  DHRVStageDisplayClient.m
//  QCStageDisplay
//
//  Created by Douglas Heriot on 25/12/12.
//  Copyright (c) 2012 Douglas Heriot. All rights reserved.
//

#import "DHRVStageDisplayClient.h"

#import "GCDAsyncSocket.h"

@interface DHRVStageDisplayClient() <GCDAsyncSocketDelegate>
@property (strong) GCDAsyncSocket *socket;
@property (strong) dispatch_queue_t queue;
@property (copy) NSDictionary *data;

+ (NSData *)delimiter;

- (void)read;
- (void)login;

@end

@implementation DHRVStageDisplayClient

- (id)init
{
	if(self = [super init])
	{
		self.queue = dispatch_queue_create("com.douglasheriot.qc.StageDisplay", DISPATCH_QUEUE_SERIAL);
		self.socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:self.queue];
		self.password = @"password";
	}
	return self;
}

- (BOOL)connectToHost:(NSString *)host port:(uint16_t)port
{
	NSError *error = nil;
	[self.socket connectToHost:host onPort:port error:&error];
	
	if(error)
	{
		NSLog(@"Error connecting to %@ on port %hu: %@", host, port, error);
		return NO;
	}
	
	[self login];
	[self read];
	
	return YES;
}

- (void)disconnect
{
	[self.socket disconnect];
}

- (void)login
{
	NSString *string = [NSString stringWithFormat:@"<StageDisplayLogin>%@</StageDisplayLogin>\r\n", self.password];
	
	[self.socket writeData:[string dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:1];
}

- (void)read
{
	[self.socket readDataToData:[DHRVStageDisplayClient delimiter] withTimeout:-1 tag:0];
}

+ (NSData *)delimiter
{
	static NSData *crlf;
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		crlf = [NSData dataWithBytes:"\r\n" length:2];
	});
	
	return crlf;
}

#pragma mark Socket Delegate

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
	NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	
	NSLog(@"Received data: %@", string);
	
	// Read again
	[self read];
}

@end
