//
//  TestModel.m
//  TS_FMDBModel_master
//
//  Created by GDTS on 2017/9/28.
//  Copyright © 2017年 GDTS. All rights reserved.
//

#import "TestModel.h"

@implementation TestModel

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    
    NSLog(@"%@",key);
}

- (void)setValue:(id)value forKey:(NSString *)key{
    
    if ([key isEqualToString:@"integerAge"]) {
        self.integerAge = [value integerValue];
        return;
    }else if ([key isEqualToString:@"uIntegerAge"]){
        self.uIntegerAge = [value integerValue];
        return;
    }
    [super setValue:value forKey:key];
}

@end
