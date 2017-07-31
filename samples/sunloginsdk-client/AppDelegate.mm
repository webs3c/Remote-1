//
//  AppDelegate.m
//  sunloginsdk-client
//
//  Created by  Oray on 1/10/17.
//  Copyright © 2017  Oray. All rights reserved.
//

#import "AppDelegate.h"
#include <slsdk/slsdk.h>
#include <string>
#import "HTTPServer.h"
#import "MyHTTPConnection.h"
#import "DDLog.h"
#import "DDTTYLogger.h"
#import "BrigeModel.h"
#import "MyWebSocket.h"
#import "NSObject+MJKeyValue.h"



NSString  *kreceveMsgNote = @"kreceveMsgNote";
@interface AppDelegate ()
{
    MyWebSocket *_websocket;
    unsigned long client_;//本地客户端的Id
    unsigned int last_desktop_session_;//最近创建的会话
}

/**
 显示状态的视图
 */
@property ( assign )IBOutlet NSTextView* message_list;


@property (nonatomic, retain) IBOutlet NSWindow *window;

- ( void )clientEvent: ( SLCLIENT_EVENT )event;
- ( void )remoteEvent: ( ESLSessionEvent )event;

/**
 保存连接的地址(服务器发过来)
 */
@property (copy) NSString *address;

/**
 hhly_packId(服务器发过来)
 */
@property (copy) NSString *hhly_packid;

/**
 授权序列号(服务器发过来)
 */
@property (copy) NSString *license;

/**
  创建会话后得到的参数（访客端自己生成）
 */
@property (copy) NSString *sessionName;

@end



void _client_callback( SLCLIENT client, SLCLIENT_EVENT event, unsigned long custom ) {
    dispatch_async( dispatch_get_main_queue(), ^{
        id objc = ( __bridge id )( void* )custom;
        AppDelegate* d = ( AppDelegate* )objc;
        [ d clientEvent: event ];
    });
}
void _remote_callback( SLSESSION session, ESLSessionEvent event, unsigned long custom ) {
    dispatch_async( dispatch_get_main_queue(), ^{
        id objc = ( __bridge id )( void* )custom;
        AppDelegate* d = ( AppDelegate* )objc;
        [ d remoteEvent: event ];
    });
}


@implementation AppDelegate
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    httpServer = [[HTTPServer alloc] init];
    [httpServer setConnectionClass:[MyHTTPConnection class]];
    [httpServer setType:@"_http._tcp."];
    [httpServer setPort:9999];
    
    NSString *webPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Web"];
    
    [httpServer setDocumentRoot:webPath];
    
    NSError *error;
    if(![httpServer start:&error])
    {
        NSLog(@"Error starting HTTP Server: %@", error);
    }
    
    //
    [_window orderOut:nil];
    //是否放到前台运行
    [ _window makeKeyAndOrderFront: self ];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receveMsg:) name:kreceveMsgNote object:nil];
    
}


- (void)applicationWillTerminate:(NSNotification *)aNotification
{
    SLUninitialize();
}


/**
 创建会话 或者 销毁会话
 */
- ( void )session_create_destroy: ( NSString* )session_name eType: ( ESLSessionType )eType  caption: ( NSString* )caption session: ( SLSESSION* ) session callback: ( SLSESSION_CALLBACK )callback
{
    if( [session_name length ] == 0 ) {
        //创建会话
        *session = SLCreateClientSession( client_, eType);
        if( ( *session ) == SLSESSION_INVAILD) {
            [ self append: [ NSString stringWithFormat: @"创建%@会话失败", caption ] ];
            [self sendNewsession:NO];
            return;
        }
        
        if( callback ) {
            //设置事件监听
            SLSESSION_CALLBACK_PROP prop;
            prop.pfnCallback = callback;
            prop.nCustom = (unsigned long)( __bridge_retained void* )self;
            SLSetClientSessionOpt( client_, *session, eSLSessionOpt_callback, (const char*)&prop, sizeof(prop));
        }
        //获取会话名称
        const char* sname = SLGetClientSessionName( client_, *session );
        
        
        _sessionName = [NSString stringWithUTF8String:sname];
        
        //通过websocket 发送参数
        [self sendNewsession:YES];
        [self append: [ NSString stringWithFormat: @"创建%@会话成功-%@", caption,_sessionName] ];

    } else {
        // release refenrence from callback
        SLSESSION_CALLBACK_PROP prop;
        if( SLGetClientSessionOpt( client_, *session, eSLSessionOpt_callback, ( char* )&prop, sizeof(prop)) ) {
            if( prop.nCustom ) {
                id objc = ( __bridge_transfer id )( void* )prop.nCustom;
                objc = nil;
            }
        }
        
        if( !SLDestroyClientSession( client_, *session ) ) {
            [ self append: [ NSString stringWithFormat: @"销毁%@会话失败", caption ] ];
            [self destroysession:NO];
            return;
        }
    
        [self append: [ NSString stringWithFormat: @"销毁%@会话成功", caption ] ];

        [self destroysession:YES];
        *session = SLSESSION_INVAILD;
    }
}



/**
 添加到视图上
 
 @param msg 信息
 */
- (void)append:(NSString*)msg{
    //    NSLog(@"%@",msg);
    NSAttributedString* attr = [ [ NSAttributedString alloc] initWithString: [ NSString stringWithFormat: @"%@\n",msg ] ];
    [ [ _message_list textStorage ] appendAttributedString: attr ];
    [ _message_list scrollRangeToVisible: NSMakeRange( [[_message_list string] length], 0 ) ];
}


/**
 本地连接服务器的事件
 */
- ( void )clientEvent: ( SLCLIENT_EVENT )event {
    switch( event ) {
        case SLCLIENT_EVENT_ONCONNECT:
            [self append: @"连接服务器成功!"];
            [self eventChange:SLCLIENT_EVENT_ONCONNECT];
            break;
        case SLCLIENT_EVENT_ONDISCONNECT:
            [self append: @"与服务器断开连接!"];
            [self eventChange:SLCLIENT_EVENT_ONDISCONNECT];
            break;
        case SLCLIENT_EVENT_ONLOGIN:
        {
            [self append: @"登录服务器成功!"];
            const char* s  = SLGetClientAddress( client_ );
            _address = [NSString stringWithUTF8String:s];
            [self eventChange:SLCLIENT_EVENT_ONLOGIN];
            break;
        }
        case SLCLIENT_EVENT_ONLOGINFAIL:
            [self sendLogin_openidJson:NO];
            [self append: @"登录服务器失败!"];
            [self eventChange:SLCLIENT_EVENT_ONLOGINFAIL];
            break;
    }
}

/**
 远程发过来的事件
 @param event 事件
 */
- ( void )remoteEvent: ( ESLSessionEvent )event
{
    switch (event) {
        case eSLSessionEvent_OnConnected:
        {
            [self append:@"连接成功～"];
            [self sendSessionEvt:event];
            
        }break;
        case eSLSessionEvent_OnDisconnected:
        {
            [self append:@"连接断开～"];
            [self sendSessionEvt:event];
        }break;
        case eSLSessionEvent_OnDisplayChanged:
        {
            [self append:@"OnDisplayChanged"];
            [self sendSessionEvt:event];
        }
    }
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
#pragma mark - 接受消息
- (void)receveMsg:(NSNotification *)noti{
    _websocket = noti.object;
    BrigeModel *model = _websocket.model;
    if (_websocket.model.id && _websocket.model.id.length > 0) {
        self.hhly_packid = _websocket.model.id;
    }
    NSString *selName = model.name;
    dispatch_async(dispatch_get_main_queue(), ^{
        //开始去登陆
        if ([selName isEqualToString:@"login_openid"]) {
            [self login_openid:model];
        }
        if([selName isEqualToString:@"login_license"]){
            [self loginLicense:model];
        }
        if ([selName isEqualToString:@"logout"]) {
            [self loginOut];
        }
        if ([selName isEqualToString:@"get_status"]){
            [self receveStatus:model];
        }
        if ([selName isEqualToString:@"newsession"]) {
            [self newsession];
        }
        if([selName isEqualToString:@"destroysession"])
        {
            [self loginOut];
        }
        if([selName isEqualToString:@"closeWin"])
        {
            //关闭窗口
            [self closeWin];
        }

        //说明关闭了
        if(_websocket == nil){
            [self loginOut];
        }
    });
}

/**
 登陆openId 的方式
 */
- (void)login_openid:(BrigeModel *)model{
    
    last_desktop_session_ = SLSESSION_INVAILD;
    
    NSString* open_id = model.data.openid;
    NSString* open_key = model.data.openkey;
    
    [ _window makeKeyAndOrderFront: self ];
    
    if( !SLInitialize() ) {
        [ self append: @"初始化环境失败." ];
        [self eventChange:SLCLIENT_EVENT_ONLOGINFAIL];
        return;
    }
    
    
    client_ = SLCreateClient();
    if( client_ == SLCLIENT_INVAILD ) {
        [ self append: @"创建向日葵客户端失败." ];
        [self eventChange:SLCLIENT_EVENT_ONLOGINFAIL];
        return;
    }
    
    
    if( !SLSetClientCallback( client_, _client_callback, ( unsigned long )( __bridge void* )self ) ) {

        [ self append: @"设置事件通知失败." ];
        [self eventChange:SLCLIENT_EVENT_ONLOGINFAIL];
        return;
    }
    
    if( !SLLoginWidthOpenID( client_, [ open_id UTF8String ], [ open_key UTF8String ] ) ) {
        [ self append: @"登录服务器失败." ];
        [self eventChange:SLCLIENT_EVENT_ONLOGINFAIL];
        return;
    }

    [ self append: @"openkey初始化客户端成功!" ];
    
    
    //第一步： 发送登陆服务器成功的消息给浏览器
    [self sendLogin_openidJson:NO];

}


/**
 通过license方式登录

 @param model 从浏览器发过来的数据模型
 */
- (void)loginLicense:(BrigeModel *)model{
    
    last_desktop_session_ = SLSESSION_INVAILD;
    self.license = @"SHA1:fpmpaagr;kyGkQ1spZBXbMyJdGUDR4Q7LIEc=";
    self.address = @"PHSRC://183.61.172.70:4118;PHSRC_HTTPS://183.61.172.70:443;";
    
    [ _window makeKeyAndOrderFront: self ];
    
    if( !SLInitialize() )
    {
        [ self append: @"初始化环境失败." ];
        [self eventChange:SLCLIENT_EVENT_ONLOGINFAIL];

        return;
    }
    
    client_ = SLCreateClient();
    if( client_ == SLCLIENT_INVAILD )
    {
        [ self append: @"创建向日葵客户端失败." ];
        [self eventChange:SLCLIENT_EVENT_ONLOGINFAIL];
        return;
    }
    
//    设置被控制端事件回调函数
    if( !SLSetClientCallback( client_, _client_callback, ( unsigned long )( __bridge void* )self ) ) {
        [ self append: @"设置事件通知失败." ];
        [self eventChange:SLCLIENT_EVENT_ONLOGINFAIL];

        return;
    }
//    被控制端登录服务器
    if(! SLClientLoginWithLicense(client_,[model.data.address UTF8String], [model.data.license UTF8String])){
          [ self append: @"登录服务器失败." ];
        [self eventChange:SLCLIENT_EVENT_ONLOGINFAIL];
        return;
    }
    
    [ self append: @"lisense方式初始化客户端成功!" ];
    
    //第一步： 发送登陆服务器成功的消息给浏览器
    [self sendLoginOnLicenseJson:NO];
    
    
}
- (void)closeWin
{
    NSLog(@"关闭窗口，结束程序");
    exit(0);

}
/**
 退出登录
 */
- (void)loginOut{
    
    [ self session_create_destroy: self.sessionName
                            eType: eSLSessionType_Desktop
                          caption: @"桌面"
                          session: &last_desktop_session_
                         callback: _remote_callback];
    
}

/**
 不知道？？
 */
- (void)receveStatus:(BrigeModel *)model{
    //检查是否登录
    BOOL login = SLClientIsOnLoginned(client_);
    
    
    NSDictionary *dic =@{
                         @"name":@"get_status",
                         @"code":@"0",
                         @"data":@{
                                 @"is_logginned":@(login),
                                 }
                         };
    
    //发送login_openid 信息
    [_websocket sendMessage:[dic JSONString]];
    
}

/**
 新会话
 */
- (void)newsession{
    [self session_create_destroy: @""
                            eType: eSLSessionType_Desktop
                          caption: @"桌面"
                          session: &last_desktop_session_
                        callback: _remote_callback ];
}

#pragma mark - 发送消息
- (void)startUp:(BOOL)error
{
    NSDictionary *dic =@{
                         @"name":@"startup",
                         @"code":error?@"1":@"0",
                         };
    
    //发送startup 信息
    [_websocket sendMessage:[dic JSONString]];
}
- (void)sendLogin_openidJson:(BOOL)error
{
    NSDictionary *dic =@{
                         @"name":@"login_openid",
                         @"code":error?@"1":@"0",
                         };
    
    //发送login_openid 信息
    [_websocket sendMessage:[dic JSONString]];
    
}
- (void)sendLoginOnLicenseJson:(BOOL)error
{
    NSDictionary *dic =@{
                         @"name":@"login_license",
                         @"code":error?@"1":@"0",
                         };
    
    //发送login_openid 信息
    [_websocket sendMessage:[dic JSONString]];
    
}

/**
 告诉浏览器主控端的连接参数
 */
- (void)sendNewsession:(BOOL) error{
    NSDictionary *dic =@{
                         @"name":@"newsession",
                         @"code":error?@"1":@"0",
                         @"data":@{
                                 @"sessionid":self.sessionName,
                                 @"address":self.address,
                                 @"sessionname":self.sessionName,
                                 }
                         };

    NSString *json = [dic JSONString];
    [_websocket sendMessage:json];
}


///**
// 销毁会话
// */
- (void)destroysession:(BOOL)error{
    
    NSDictionary *dic =@{
                         @"name":@"destroysession",
                         @"code":error?@"1":@"0",
                         };
    
    //发送destroysession 信息
    [_websocket sendMessage:[dic JSONString]];
    
}

//会话事件
- (void)sendSessionEvt:(ESLSessionEvent)event
{
    NSDictionary *dic =@{
                         @"name":@"sessionevt",
                         @"data":@{
                                 @"evt":@(event),
                                 }
                         };
    

    [_websocket sendMessage:[dic JSONString]];

}
/**
 发送环境变化的事件

 @param statu 0.连接成功、1.断开了、2.登陆成功了、 3.登陆失败
 */
- (void)eventChange:(SLCLIENT_EVENT)statu{
    
    NSDictionary *dic = @{
                          @"name":@"evnet",
                          @"data":@{
                                  @"evnet":@(statu)
                                  }
                          };
    
    [_websocket sendMessage:[dic JSONString]];
    
}
@end





