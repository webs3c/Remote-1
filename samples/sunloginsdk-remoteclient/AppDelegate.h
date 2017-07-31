//
//  AppDelegate.h
//  sunloginsdk-remoteclient
//
//  Created by  Oray on 1/11/17.
//  Copyright © 2017  Oray. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class HTTPServer;
@interface AppDelegate : NSObject <NSApplicationDelegate>
{
    HTTPServer *httpServer;
}


extern NSString *kreceveMsgNote;
@end

