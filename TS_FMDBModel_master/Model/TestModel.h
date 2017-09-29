//
//  TestModel.h
//  TS_FMDBModel_master
//
//  Created by GDTS on 2017/9/28.
//  Copyright © 2017年 GDTS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TestModel : NSObject

@property (copy, nonatomic) NSString *alert;
@property (nonatomic,assign) long primaryKey;
@property (nonatomic,assign) NSInteger integerAge;
@property (nonatomic,assign) NSUInteger uIntegerAge;

@end
