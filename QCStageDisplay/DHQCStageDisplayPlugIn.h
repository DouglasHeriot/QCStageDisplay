//
//  QCStageDisplayPlugIn.h
//  QCStageDisplay
//
//  Created by Douglas Heriot on 25/12/12.
//  Copyright (c) 2012 Douglas Heriot. All rights reserved.
//

#import <Quartz/Quartz.h>

@interface DHQCStageDisplayPlugIn : QCPlugIn

// Declare here the properties to be used as input and output ports for the plug-in e.g.
//@property double inputFoo;
//@property (copy) NSString* outputBar;

@property (copy) NSString *inputIP;
@property (copy) NSNumber *inputPort;
@property (copy) NSString *inputPassword;
@property (copy) NSDictionary *outputData;

@end
