//
//  AppDelegate.m
//  sunloginsdk-remoteclient
//
//  Created by  Oray on 1/11/17.
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



NSString *kreceveMsgNote = @"kreceveMsgNote";


@interface DesktopWindowController : NSWindowController
@end
@interface DesktopWindowController()
{
    AppDelegate* main_dlg_;//AppDelegate
    SLREMOTE remote_;//控制端
    SLSESSION session_;
    NSSize desktop_size_;
}

- ( id ) initWith: ( AppDelegate* ) d;
- ( BOOL )start: (NSString*) address sid: ( NSString* )sid;
- ( void )desktopDisplayChanged: ( id )sender;
- ( void )pluginConnected: (id)sender;
- ( void )pluginDisconnected: (id)sender;
@end
@interface AppDelegate ()
{
    MyWebSocket *_websocket;
    
    DesktopWindowController* desktop_;
}

/**
 保存连接的地址
 */
@property (copy) NSString *address;

/**
 session
 */
@property (copy) NSString *session;

/**
 packID 记录当前的id值
 */
@property (copy) NSString *hhly_packid;


@property (nonatomic, retain) IBOutlet NSWindow *window;
@property ( assign )IBOutlet NSTextView* message_list;

@end

@implementation AppDelegate
@synthesize message_list;


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    httpServer = [[HTTPServer alloc] init];
    [httpServer setConnectionClass:[MyHTTPConnection class]];
    [httpServer setType:@"_http._tcp."];
    [httpServer setPort:9999];
    
    NSString *webPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Web"];
    NSLog(@"Setting document root: %@", webPath);
    
    [httpServer setDocumentRoot:webPath];
    
    NSError *error;
    if(![httpServer start:&error])
    {
        NSLog(@"Error starting HTTP Server: %@", error);
    }
    
    //
    [ _window orderOut: nil ];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receveMsg:) name:kreceveMsgNote object:nil];
    
    if( !SLInitialize() ) {
        NSLog( @"Initialize SunloginClient failed." );
        return;
    }
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
    SLUninitialize();
}


- (void) append: ( NSString* ) msg {
    NSLog(@"%@",msg);
    NSAttributedString* attr = [ [ NSAttributedString alloc] initWithString: [ NSString stringWithFormat: @"%@\n",msg ] ];
    [ [ message_list textStorage ] appendAttributedString: attr ];
    [ message_list scrollRangeToVisible: NSMakeRange( [[message_list string] length], 0 ) ];
}

- ( void ) move_desktop_window: ( SLREMOTE )remote session: ( SLSESSION )session frame: ( NSRect )frame {
    //设置远程桌面窗口的大小
    SLSetDesktopSessionPos( remote, session, int( frame.origin.x ),  int( frame.origin.y ), int( frame.size.width ), int( frame.size.height ) );
}

- ( void ) show_desktop_window: ( SLREMOTE )remote session: ( SLSESSION )session {
    //Show desktop window
    SLSetDesktopSessionVisible( remote, session );
}

- ( void ) destroy_session: ( SLREMOTE )remote session: ( SLSESSION )session {
    desktop_ = nil;
    // 销毁一个会话
    SLDestroyRemoteSession( remote, session );
    //销毁一个控制端环境
    SLDestroyRemote( remote );
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
#pragma mark - 接受到消息
- (void)receveMsg:(NSNotification *)noti{
    _websocket = noti.object;
    BrigeModel *model = _websocket.model;
    NSString *selName = model.name;
    dispatch_async(dispatch_get_main_queue(), ^{
        //开始去远程连接
        //退出
        if ([selName isEqualToString:@"logout"]) {
            [self logout];
        }
        if ([selName isEqualToString:@"assist"]) {
            
            [self assist:model];
        }
        if ([selName isEqualToString:@"get_status"]) {
            [self receveStatus:model];
        }
        if([selName isEqualToString:@"closeWin"])
        {
            //关闭窗口
            [self closeWin];
        }
        //说明关闭了
        if(_websocket == nil)
        {
//                        [self loginOut];
        }
    });
}
/**
 不知道？？
 */
- (void)receveStatus:(BrigeModel *)model{
    
    NSDictionary *dic =@{
                         @"name":@"get_status",
                         @"code":@"0",
                         @"data":@{
                                 @"is_logginned":@(NO),
                                 }
                         };
    
    //发送login_openid 信息
    [_websocket sendMessage:[dic JSONString]];
    
}
/**
 远程协助
 
 @param model 参数
 */
- (void)assist:(BrigeModel *)model{
    if([self.session isEqualToString:model.data.session])
    {
        return;
    }
    self.address = model.data.address;
    self.session = model.data.session;
    NSLog( @"remote address(%@) session:(%@)", self.address, self.session );
    [ self append: @"正在连接远程桌面插件..." ];
    desktop_ = [ [DesktopWindowController alloc ] initWith: self ];
    if( ![ desktop_ start: self.address sid: self.session ] )
    {
        [ self append: @"启动远程桌面插件失败." ];
        //发送远程状态信息
        [self sendSessionEvt:NO];
    }
    else
    {
        [ self append: @"启动远程桌面插件成功！" ];
        //发送远程状态信息
        [self sendSessionEvt:YES];
    }
}

- (void)logout{
    [self append:@"对端已经退出远程协助！"];
    [self append:@""];
    
}

/**
 销毁会话
 
 @param model 参数
 */
- (void)destroy:(BrigeModel *)model
{
    //    [self destroy_session:remote_ session:session_];
}
- (void)closeWin
{
    NSLog(@"关闭窗口，结束程序");
    exit(0);
    
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
/**
 发送会话事件 状态
 @param reuslt 1 成功。2 失败
 */
- (void)sendSessionEvt:(BOOL)reuslt{
    NSDictionary *dic =@{
                         @"name":@"sessionevt",
                         @"data":@{
                                 @"evt":reuslt?@"1":@"2",
                                 @"id":self.session?:@"",
                                 }
                         };
    //发送sendSessionEvt 信息
    [_websocket sendMessage:[dic JSONString]];
}
- (void)sendLogoutOrClose
{
    NSDictionary *dic =@{
                         @"code":@"1",
                         @"name":@"logout",
                         };
    //发送login_openid 信息
    [_websocket sendMessage:[dic JSONString]];
//    exit(0);

//
}

@end

void desktopctl_callback( SLSESSION session, ESLSessionEvent event, unsigned long custom) {
    id objc = ( __bridge id )(void*)custom;
    DesktopWindowController* desktop = ( DesktopWindowController* )objc;
    switch( event ) {
        case eSLSessionEvent_OnDisplayChanged:
        {
            [desktop performSelectorOnMainThread: @selector( desktopDisplayChanged: ) withObject: desktop waitUntilDone: YES ];
            break;
        }
        case eSLSessionEvent_OnConnected:
        {
            [desktop performSelectorOnMainThread: @selector( pluginConnected: ) withObject: desktop waitUntilDone: YES ];
            break;
        }
            
        case eSLSessionEvent_OnDisconnected:
        {
            [desktop performSelectorOnMainThread: @selector( pluginDisconnected: ) withObject: desktop waitUntilDone: YES ];
            break;
        }
        default:
            break;
    }
}

@interface mynswindow : NSWindow

@end


@implementation mynswindow

-(void)dealloc {
    
}

@end


@implementation DesktopWindowController
void _remote_callback(SLREMOTE remote, SLSESSION session, SLREMOTE_EVENT event, unsigned long custom) {
    dispatch_async(dispatch_get_main_queue(), ^{
//        id objc = ( __bridge id )( void* )custom;
//        AppDelegate* d = ( AppDelegate* )objc;
        
    });
}


- ( id ) initWith: ( AppDelegate* ) d {
    // Create host window
    mynswindow* awindow = [ [ mynswindow alloc ]
                           initWithContentRect: NSMakeRect( 0, 0, 1024, 768 )
                           styleMask: NSWindowStyleMaskTitled|NSClosableWindowMask|NSResizableWindowMask
                           backing: NSBackingStoreBuffered
                           defer:NO ];
    self = [ super initWithWindow: awindow ];
    if( self ) {
        main_dlg_ = d;
        
        [ awindow setDelegate: (id)self ];
        [ awindow makeKeyAndOrderFront: nil ];
        [ awindow center ];
    }
    
    return self;
}

- (void)dealloc {
    
}

- ( BOOL )start: ( NSString* )address sid: ( NSString* )sid {
    //创建一个控制端环境
    remote_ = SLCreateRemote();
    
    //创建主控制端空会话(无连接)
    session_ = SLCreateRemoteEmptySession( remote_, eSLSessionType_Desktop );
    
    //设置主控制端事件回调函数
    BOOL callBack = SLSetRemoteCallback(remote_, _remote_callback, ( unsigned long )( __bridge void* )self );
    NSAssert(callBack, @"SLSetRemoteCallback error");
    if( session_ == SLSESSION_INVAILD ) {
        [ main_dlg_ append: @"创建远程桌面会话失败." ];
        return NO;
    }
    else
    {
        [ main_dlg_ append: @"创建远程桌面会话成功！" ];
        
        // 设置主控制端某个会话某个属性值
        if( !SLSetRemoteSessionOpt( remote_, session_,
                                   eSLSessionOpt_window, ( const char* )[ [ self window ] windowNumber], sizeof( NSInteger ) ) )
        {
            [ main_dlg_ append: @"绑定远程桌面显示窗口失败." ];
            return NO;
        }
        
        // Hide desktop window
        [ main_dlg_ move_desktop_window: remote_ session: session_ frame: NSMakeRect(1,1,1,1) ];
        
        // Set callback
        SLSESSION_CALLBACK_PROP prop;
        prop.pfnCallback = desktopctl_callback;
        prop.nCustom = (unsigned long) ( __bridge_retained void* )self;
        if( !SLSetRemoteSessionOpt( remote_, session_, eSLSessionOpt_callback, (const char*)&prop, sizeof(prop)) ) {
            [ main_dlg_ append: @"S设置远程桌面事件回调失败." ];
            return NO;
        }
        
        [ self setTitle: @"正在连接远程桌面..." ];
        // 连接主控端会话
        if( !SLConnectRemoteSession( remote_, session_, [ address UTF8String ], [ sid UTF8String ] ) ) {
            [ main_dlg_ append: @"连接远程桌面失败！" ];
            [ self setTitle: @"" ];
            return NO;
        }
    }
    return YES;
}

- (void)desktopDisplayChanged: (id)sender {
    [ self setTitle: @"正在远程控制桌面" ];
    NSRect frame = [ [ [ self window ] contentView ] bounds ];
    frame = [ [ self window ] convertRectToScreen: frame ];
    
    int width(0), height(0);
    if( SLGetDesktopSessionOriginSize( remote_, session_, &width, &height ) ) {
        NSLog(@"远程桌面大小宽度( %d ), 高度( %d )\n", width, height );
    }
    
    
    [ main_dlg_ show_desktop_window: remote_ session: session_ ];
    [ main_dlg_ move_desktop_window: remote_ session: session_ frame: frame ];
}

- ( void ) pluginConnected:(id)sender {
    [ self setTitle: @"准备显示远程桌面" ];
}

- ( void ) pluginDisconnected:(id)sender {
    [self setTitle: @"远程桌面已经断开" ];
    [main_dlg_ sendLogoutOrClose];
}

- ( void ) setTitle : ( NSString* ) text {
    [ [ self window ] setTitle: text ];
}


- (void) windowDidResize: ( NSNotification* )notification {
    if( main_dlg_ ) {
        NSRect frame = [ [ [ self window ] contentView ] bounds ];
        frame = [ [ self window ] convertRectToScreen: frame ];
        [ main_dlg_ move_desktop_window: remote_ session: session_ frame: frame ];
    }
}

- (void)windowWillClose:(NSNotification*) notification
{
    //NSLog( @"windowWillClose notification" );
    if( main_dlg_ ) {
        // remove reference from callback
        SLSESSION_CALLBACK_PROP prop;
        //获取主控制端某个会话某个属性值
        if( SLGetRemoteSessionOpt( remote_, session_, eSLSessionOpt_callback, ( char* )&prop, sizeof( prop ) ) ) {
            if( prop.nCustom ) {
                id objc = ( __bridge_transfer id )(void*)prop.nCustom;
                DesktopWindowController* desktop = ( DesktopWindowController* )objc;
                desktop = nil;
            }
        }
        [ main_dlg_ destroy_session: remote_ session: session_ ];
        
        //告诉浏览器关闭了远程
        [main_dlg_ sendLogoutOrClose];
    }
    
    [ [ self window ] setDelegate: nil ];
    
    
    
}


@end


