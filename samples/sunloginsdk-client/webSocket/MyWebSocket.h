#import <Foundation/Foundation.h>
#import "WebSocket.h"
#import "BrigeModel.h"

@interface MyWebSocket : WebSocket

@property (nonatomic,strong) BrigeModel *model;
@end
