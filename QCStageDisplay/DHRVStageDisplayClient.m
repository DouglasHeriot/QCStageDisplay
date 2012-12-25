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
	NSError *error = nil;
	NSXMLDocument *xml = [[NSXMLDocument alloc] initWithData:data options:0 error:&error];
	
//	if(error)
//		NSLog(@"Error parsing XML: %@", error);	
	
	if([xml.rootElement.name isEqualToString:@"StageDisplayData"])
	{
		for(NSXMLNode *child in xml.rootElement.children)
		{
			if([child.name isEqualToString:@"Fields"])
			{
				NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
				
				for(NSXMLNode *node in child.children)
				{
					if(node.kind == NSXMLElementKind)
					{
						NSXMLElement *field = (NSXMLElement *)node;
						NSXMLNode *identifierAttribute = [field attributeForName:@"identifier"];
						
						if(identifierAttribute)
						{
							// Yes, this is a <Field> tag, with an identifier attribute
							// Add this to the dictionary, and pull out all its other attribtues too
							NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
							
							for(NSXMLNode *attribute in field.attributes)
								[attributes setObject:attribute.stringValue forKey:attribute.name];
							
							[dictionary setObject:attributes forKey:identifierAttribute.stringValue];
						}
					}
				}
				
				self.data = dictionary;
				
				if([self.delegate respondsToSelector:@selector(stageDisplay:didRecieveData:)])
					[self.delegate stageDisplay:self didRecieveData:self.data];
				
				break;
			}
		}
	}
	
	// Read again
	[self read];
}

@end
