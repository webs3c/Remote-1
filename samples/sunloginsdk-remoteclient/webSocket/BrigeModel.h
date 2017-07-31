//
//  BrigeModel.h
//  sunloginsdk-client
//
//  Created by 谭建中 on 2017/4/17.
//  Copyright © 2017年  Oray. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BrigeDataModel.h"
@interface BrigeModel : NSObject
@property (nonatomic,copy) NSString *id;
@property (nonatomic,copy) NSString *name;
@property (nonatomic,strong) BrigeDataModel *data;

@end
