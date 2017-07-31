//
//  BrigeDataModel.h
//  sunloginsdk-client
//
//  Created by 谭建中 on 2017/4/17.
//  Copyright © 2017年  Oray. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface BrigeDataModel : NSObject
@property (nonatomic,copy) NSString *openid;
@property (nonatomic,copy) NSString *openkey;
@property (nonatomic,copy) NSString *address;
@property (nonatomic,copy) NSString *license;
@property (nonatomic,copy) NSString *logout;
@property (nonatomic,copy) NSString *get_status;
@property (nonatomic,copy) NSString *session;
@property (nonatomic,copy) NSString *sessionid;

@end
