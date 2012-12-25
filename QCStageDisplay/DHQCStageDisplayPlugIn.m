//
//  QCStageDisplayPlugIn.m
//  QCStageDisplay
//
//  Created by Douglas Heriot on 25/12/12.
//  Copyright (c) 2012 Douglas Heriot. All rights reserved.
//

// It's highly recommended to use CGL macros instead of changing the current context for plug-ins that perform OpenGL rendering
#import <OpenGL/CGLMacro.h>

#import "DHQCStageDisplayPlugIn.h"
#import "DHRVStageDisplayClient.h"

#define	kQCPlugIn_Name				@"ProPresenter Stage Display"
#define	kQCPlugIn_Description		@"Connects to a ProPresenter with Remote Stage Display server enabled (officially used by the Stage Display app on iOS)"

@interface DHQCStageDisplayPlugIn() <DHRVStageDisplayClientDelegate>
@property (strong) DHRVStageDisplayClient *client;
@property BOOL didUpdateData;
@end

@implementation DHQCStageDisplayPlugIn

// Here you need to declare the input / output properties as dynamic as Quartz Composer will handle their implementation
//@dynamic inputFoo, outputBar;
@dynamic inputPort;
@dynamic inputPassword;
@dynamic inputHost;
@dynamic outputData;

+ (NSDictionary *)attributes
{
	// Return a dictionary of attributes describing the plug-in (QCPlugInAttributeNameKey, QCPlugInAttributeDescriptionKey...).
    return @{QCPlugInAttributeNameKey:kQCPlugIn_Name, QCPlugInAttributeDescriptionKey:kQCPlugIn_Description};
}

+ (NSDictionary *)attributesForPropertyPortWithKey:(NSString *)key
{
	// Specify the optional attributes for property based ports (QCPortAttributeNameKey, QCPortAttributeDefaultValueKey...).
	
	if([key isEqualToString:@"inputHost"])
	{
		return @{
		   QCPortAttributeNameKey: @"Host",
		   QCPortAttributeTypeKey: QCPortTypeString,
		   QCPortAttributeDefaultValueKey: @"localhost"};
	}
	else if([key isEqualToString:@"inputPort"])
	{
		return @{QCPortAttributeNameKey: @"Port",
		   QCPortAttributeTypeKey: QCPortTypeIndex,
		   QCPortAttributeMinimumValueKey: @0,
		   QCPortAttributeMaximumValueKey: @65536,
		   QCPortAttributeDefaultValueKey: @54321};
	}
	else if([key isEqualToString:@"inputPassword"])
	{
		return @{QCPortAttributeNameKey: @"Password",
		   QCPortAttributeTypeKey: QCPortTypeString,
		   QCPortAttributeDefaultValueKey: @"password"};
	}
	else if([key isEqualToString:@"outputData"])
	{
		return @{QCPortAttributeNameKey: @"Data",
		   QCPortAttributeTypeKey: QCPortTypeStructure};
	}
	
	
	return nil;
}

+ (QCPlugInExecutionMode)executionMode
{
	// Return the execution mode of the plug-in: kQCPlugInExecutionModeProvider, kQCPlugInExecutionModeProcessor, or kQCPlugInExecutionModeConsumer.
	return kQCPlugInExecutionModeProcessor;
}

+ (QCPlugInTimeMode)timeMode
{
	// Return the time dependency mode of the plug-in: kQCPlugInTimeModeNone, kQCPlugInTimeModeIdle or kQCPlugInTimeModeTimeBase.
	return kQCPlugInTimeModeIdle;
}

- (id)init
{
	self = [super init];
	if (self)
	{
		self.client = [[DHRVStageDisplayClient alloc] init];
		self.client.delegate = self;
		self.didUpdateData = NO;
	}
	
	return self;
}

- (void)stageDisplay:(DHRVStageDisplayClient *)client didRecieveData:(NSDictionary *)data
{
	self.didUpdateData = YES;
}

@end

@implementation DHQCStageDisplayPlugIn (Execution)

- (BOOL)startExecution:(id <QCPlugInContext>)context
{
	// Called by Quartz Composer when rendering of the composition starts: perform any required setup for the plug-in.
	// Return NO in case of fatal failure (this will prevent rendering of the composition to start).
	
	return YES;
}

- (void)enableExecution:(id <QCPlugInContext>)context
{
	// Called by Quartz Composer when the plug-in instance starts being used by Quartz Composer.
}

- (BOOL)execute:(id <QCPlugInContext>)context atTime:(NSTimeInterval)time withArguments:(NSDictionary *)arguments
{
	/*
	Called by Quartz Composer whenever the plug-in instance needs to execute.
	Only read from the plug-in inputs and produce a result (by writing to the plug-in outputs or rendering to the destination OpenGL context) within that method and nowhere else.
	Return NO in case of failure during the execution (this will prevent rendering of the current frame to complete).
	
	The OpenGL context for rendering can be accessed and defined for CGL macros using:
	CGLContextObj cgl_ctx = [context CGLContextObj];
	*/
	
	if(!self.client.connected)
		[self.client connectToHost:self.inputHost port:self.inputPort.integerValue];
	
	if(self.didUpdateData)
	{
		self.outputData = self.client.data;
		self.didUpdateData = NO;
	}
	
	return YES;
}

- (void)disableExecution:(id <QCPlugInContext>)context
{
	// Called by Quartz Composer when the plug-in instance stops being used by Quartz Composer.
}

- (void)stopExecution:(id <QCPlugInContext>)context
{
	// Called by Quartz Composer when rendering of the composition stops: perform any required cleanup for the plug-in.
	[self.client disconnect];
}

@end
