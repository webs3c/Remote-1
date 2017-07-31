//
//  AppDelegate.h
//  sunloginsdk-client
//
//  Created by  Oray on 1/10/17.
//  Copyright © 2017  Oray. All rights reserved.
//

#import <Cocoa/Cocoa.h>
extern NSString  *kreceveMsgNote;
@class HTTPServer;
@interface AppDelegate : NSObject <NSApplicationDelegate>
{
    HTTPServer *httpServer;
}

@end

