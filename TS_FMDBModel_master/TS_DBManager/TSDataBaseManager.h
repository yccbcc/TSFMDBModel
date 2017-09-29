//
//  TSDataBaseManager.h
//  TS_FMDBModel_master
//
//  Created by GDTS on 2017/9/28.
//  Copyright © 2017年 GDTS. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TSDataBaseManagerDelegate <NSObject>

- (NSDictionary *)TS_saveDBTablePrimary;

@end

@interface TSDataBaseManager : NSObject

+ (TSDataBaseManager *)sharedInstance;


@property (nonatomic,weak) id<TSDataBaseManagerDelegate> delegate;

//技术点:  运行时: 获取属性名,属性值.    FMDB:语句的生成.

/**使用
 1.使用Model为表名，model所有属性为字段名。
 2.设置主键（model的某一个字段。用代理设置）
 3.注册表
 4.完成增删改查等。
 PS：如果 Model 中 的属性 有为NSInteger/NSUInteger 类型 需要做特殊处理 请看 GDPushMessageModel.m 中处理过程
 */

//优势：一句话创建表，一句话增删改查。无论多少个表使用此类一起管理。

//弊端：每次需要存储的model字段必须要一致，不一致会崩溃（每次model更新字段后，表中的字段没有变，导致找不到对应字段），需要卸载app重新安装。


//创建表
- (void)registerClass:(Class)aClass;

//判断是否存在
- (BOOL)isExist:(id)model;
//保存
- (BOOL)save:(id)model;
//删除MOdel
- (BOOL)deleteModel:(id)model ;
//删除所有
- (BOOL)deleteClass:(Class)aClass;

//如果 Model 中 的属性 有为NSInteger/NSUInteger 类型 需要做特殊处理 请看 GDPushMessageModel.m 中处理过程

//获取model //如果 主键 为number  请传 NSNumber类型
- (id)fetchModel:(Class)aClass value:(NSString *)value;
//获取所有数据
- (NSMutableArray *)fetchAll:(Class)aClass;


@end
