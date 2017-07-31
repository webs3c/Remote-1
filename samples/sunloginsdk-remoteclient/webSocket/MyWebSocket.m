#import "MyWebSocket.h"
#import "HTTPLogging.h"
#import "MJExtension.h"
#import "BrigeModel.h"
#import "AppDelegate.h"
// Log levels: off, error, warn, info, verbose
// Other flags : trace
static const int httpLogLevel = HTTP_LOG_LEVEL_WARN | HTTP_LOG_FLAG_TRACE;


@implementation MyWebSocket

- (void)didOpen
{
	HTTPLogTrace();
	
	[super didOpen];
}

- (void)didReceiveMessage:(NSString *)msg
{
	
    //解析
    NSDictionary *dic = [msg JSONObject];
    NSLog(@"接受数据<-<-<-<-<-<-<-<-<-%@",dic);

    if (dic) {
        BrigeModel *msg = [BrigeModel objectWithKeyValues:dic];
        _model = msg;
        NSNotification *noti = [[NSNotification alloc] initWithName:kreceveMsgNote object:self userInfo:nil];
        [[NSNotificationCenter defaultCenter] postNotification:noti];
    }
}

- (void)didClose
{
	HTTPLogTrace();
    NSNotification *noti = [[NSNotification alloc] initWithName:kreceveMsgNote object:nil userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotification:noti];

	[super didClose];
}

@end
