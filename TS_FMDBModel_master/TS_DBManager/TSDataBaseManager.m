//
//  TSDataBaseManager.m
//  TS_FMDBModel_master
//
//  Created by GDTS on 2017/9/28.
//  Copyright © 2017年 GDTS. All rights reserved.
//

#import "TSDataBaseManager.h"
#import "FMDB.h"
#import <objc/runtime.h>
#define DATABASE_NAME        @"TSdb.sqlite"                //数据库名字

@implementation TSDataBaseManager {
    FMDatabase *_dataBase;
}

+ (TSDataBaseManager *)sharedInstance
{
    static dispatch_once_t once;
    static TSDataBaseManager * __singleton__;
    dispatch_once( &once, ^{ __singleton__ = [[[self class] alloc] init]; } );
    return __singleton__;
}


- (instancetype)init {
    
    self = [super init];
    if (self) {
        
        NSString *dbPath = [NSString stringWithFormat:@"%@/Documents/%@",NSHomeDirectory(),DATABASE_NAME];
        _dataBase = [[FMDatabase alloc] initWithPath:dbPath];
    }
    return self;
}

- (NSDictionary *)saveTablePrimary{
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(TS_saveDBTablePrimary)]) {
        return [self.delegate TS_saveDBTablePrimary];
    }else{
        NSAssert(NO, @"数据库获取主键失败，请实现代理“TS_saveDBTablePrimary”");
    }
    
    return @{};
}


#pragma mark - 动态创建db

- (void)registerClass:(Class)aClass{
    
    if ([_dataBase open]) {
        
        NSArray *allNames = [self allPropertyNames:aClass];
        NSString *str = [allNames componentsJoinedByString:@","];
        NSString *allPropertyNames = [NSString stringWithFormat:@"%@",str];//,ID INTEGER PRIMARY KEY AUTOINCREMENT
        
        NSString *className = NSStringFromClass(aClass);
        
        NSString *createTableStr = [NSString stringWithFormat:@"create table if not exists %@(%@)",className,allPropertyNames];
        
        NSLog(@"%@",createTableStr);
        
        BOOL createOK = [_dataBase executeUpdate:createTableStr];
        if (createOK) {
            NSLog(@"%@", [NSString stringWithFormat:@"%@数据库创建成功",className]);
        }else {
            NSLog(@"%@", [NSString stringWithFormat:@"%@数据库创建失败",className]);
        }
        
        [_dataBase close];
    }
}


- (BOOL)isExist:(id)model {
    
    NSDictionary *primaryDict = [self saveTablePrimary];
    NSString *className = NSStringFromClass([model class]);
    id primary = primaryDict[className];
    
    NSArray *array = [self allPropertyNames:[model class]];
    BOOL havePrimary = [array containsObject:primary];
    NSAssert(havePrimary == YES, @"代理中设置的主键字段，不包含在model的属性中");
    
    NSString *value = [self getValueForModel:model Property:primary];
    NSString *sqlStr = [NSString stringWithFormat:@"select * from %@ where %@=?",className,primary];
    FMResultSet *set = [_dataBase executeQuery:sqlStr,value];
    
    if ([set next]) { // 如果数据库 表里面存在
        
        NSLog(@"该model存在");
        return YES;
    }else {
        NSLog(@"该model不存在");
        
        return NO;
    }
}


- (BOOL)save:(id)model {
    
    NSDictionary *primaryDict = [self saveTablePrimary];
    NSString *className = NSStringFromClass([model class]);
    NSString *primary = primaryDict[className];
    
    NSDictionary *propertyDict = [self fetchThePropertyNameAndPropertyDictWithModel:model];
    
    if ([_dataBase open]) {
        
        BOOL isExist = [self isExist:model];
        if (!isExist) {
            
            NSString *sqlStr = [self createInsertSqlTabel:className valueDictionry:propertyDict];
            //            NSLog(@"%@",sqlStr);
            BOOL res =  [_dataBase executeUpdate:sqlStr withParameterDictionary:propertyDict];
            if (!res) {
                NSLog(@"向表中插入数据失败");
                [_dataBase close];
                return NO;
                
            } else {
                NSLog(@"向表中插入数据成功");
                [_dataBase close];
                return YES;
            }
            
        }else{
            
            NSString *sqlStr = [self createUpdateSqlTable:className valueDict:propertyDict primary:primary];
            NSLog(@"%@",sqlStr);
            BOOL res = [_dataBase executeUpdate:sqlStr withParameterDictionary:propertyDict];
            if (!res) {
                NSLog(@"更新表中数据失败");
                [_dataBase close];
                return NO;
            } else {
                NSLog(@"更新表中数据成功");
                [_dataBase close];
                return YES;
            }
        }
        
    }else{
        return NO;
    }
}

- (BOOL)deleteModel:(id)model{
    
    if ([_dataBase open]) {
        
        BOOL isExist = [self isExist:model];
        if (isExist) {
            
            NSDictionary *primaryDict = [self saveTablePrimary];
            NSString *className = NSStringFromClass([model class]);
            NSString *primary = primaryDict[className];
            NSString *value = [self getValueForModel:model Property:primary];
            NSString *sqlStr = [NSString stringWithFormat:@"delete from %@ where %@=?",className,primary];
            
            if ([_dataBase executeUpdate:sqlStr,value]) {
                [_dataBase close];
                return YES;
            }
            [_dataBase close];
            return NO;
            
        }else{
            [_dataBase close];
            return NO;
        }
        
    }else{
        return NO;
    }
}

- (BOOL)deleteClass:(Class)aClass{
    
    if ([_dataBase open]) {
        
        NSString *sqlstr = [NSString stringWithFormat:@"DELETE FROM %@", NSStringFromClass(aClass)];
        if (![_dataBase executeUpdate:sqlstr])
        {
            [_dataBase close];
            return NO;
        }
        [_dataBase close];
        return YES;
    }else{
        return NO;
    }
}


- (id)fetchModel:(Class)aClass value:(NSString *)value{
    
    if ([_dataBase open]) {
        
        NSDictionary *primaryDict = [self saveTablePrimary];
        NSString *className = NSStringFromClass(aClass);
        NSString *primary = primaryDict[className];
        
        NSString *sqlstr = [NSString stringWithFormat:@"select * from %@ where %@=?", NSStringFromClass(aClass),primary];
        
        FMResultSet *set = [_dataBase executeQuery:sqlstr,value];//
        if ([set next]) { // 如果数据库 表里面存在
            NSDictionary *dict = [set resultDictionary];
            id model = [[aClass alloc] init];
            [model setValuesForKeysWithDictionary:dict];
            
            [_dataBase close];
            return model;
            
        } else {
            return [[aClass alloc] init];
        }
    } else {
        NSLog(@"链接patientSQL失败");
        return [[aClass alloc] init];
    }
}


- (NSMutableArray *)fetchAll:(Class)aClass
{
    
    if ([_dataBase open]) {
        NSString *sqlStr = [NSString stringWithFormat:@"select * from %@",NSStringFromClass(aClass)];
        FMResultSet *set = [_dataBase executeQuery:sqlStr];
        NSMutableArray *dataArray = [NSMutableArray array];
        while ([set next]) {
            
            //            NSMutableDictionary *mDict = [NSMutableDictionary dictionary];
            //            NSArray *allNames = [self allPropertyNames:aClass];
            //            for (NSString *key in allNames) {
            //                NSString *value = [set stringForColumn:key];
            //                [mDict setObject:value forKey:key];
            //            }
            NSDictionary *mDict = [set resultDictionary];
            id model = [[aClass alloc] init];
            [model setValuesForKeysWithDictionary:mDict];
            
            [dataArray addObject:model];
        }
        [_dataBase close];
        return dataArray;
    }else{
        
        NSLog(@"Error fetch All PUSHMESSAGE Becasue sql close");
        return [NSMutableArray array];
    }
    
}



#pragma mark - Tools
///通过运行时获取当前对象的所有属性的名称，以数组的形式返回
- (NSArray *) allPropertyNames:(Class)Class{
    ///存储所有的属性名称
    NSMutableArray *allNames = [[NSMutableArray alloc] init];
    ///存储属性的个数
    unsigned int propertyCount = 0;
    ///通过运行时获取当前类的属性
    objc_property_t *propertys = class_copyPropertyList(Class, &propertyCount);
    //把属性放到数组中
    for (int i = 0; i < propertyCount; i ++) {
        ///取出第一个属性
        objc_property_t property = propertys[i];
        const char * propertyName = property_getName(property);
        [allNames addObject:[NSString stringWithUTF8String:propertyName]];
    }
    ///释放
    free(propertys);
    return allNames;
}

//model  -> 字典.
- (NSMutableDictionary *) fetchThePropertyNameAndPropertyDictWithModel:(id)model{
    
    NSMutableDictionary *mDict = [NSMutableDictionary dictionary];
    //获取实体类的属性名
    NSArray *array = [self allPropertyNames:[model class]];
    for (int i = 0; i < array.count; i ++) {
        id value = [self getValueForModel:model Property:array[i]];
        
        [mDict setObject:value forKey:array[i]];
    }
    NSLog(@"%@", mDict);
    return mDict;
}

//通过key 获取model的value
- (NSString *)getValueForModel:(id)model Property:(NSString *)propertyName{
    
    id value = [model valueForKey:propertyName];
    if (value) {
        return value;
    }else{
        return @"";
    }
}


#pragma mark -- 创建动态插入语句

//创建动态插入语句
- (NSString *)createInsertSqlTabel:(NSString *)table
                    valueDictionry:(NSDictionary *)values {
    // 取出所有数据的key的集合
    NSArray *keyArr = [values allKeys];
    // 构造插入语句key
    NSString *keyStr = [keyArr componentsJoinedByString:@", "];
    // 构造插入语句value
    NSString *valueStr = [keyArr componentsJoinedByString:@", :"];
    NSString *valueStr2 = [@":" stringByAppendingString:valueStr];
    // 组成sql插入语句
    NSString *sqlStr = [NSString stringWithFormat:@"insert into %@(%@) values(%@)",table,keyStr,valueStr2];
    return sqlStr;
}

//生成更新语句
- (NSString *)createUpdateSqlTable:(NSString *)table valueDict:(NSDictionary *)values primary:(NSString *)primary{
    
    NSArray *keyArr = [values allKeys];
    
    NSMutableArray *keyValueArr = [NSMutableArray array];
    NSString *primaryKeyValueStr;
    
    for (NSString *key in keyArr) {
        
        NSString *keyValue = [NSString stringWithFormat:@" %@ = :%@",key,key];
        
        if ([key isEqualToString:primary]) {
            primaryKeyValueStr = [NSString stringWithFormat:@"%@ = '%@'",key,values[key]];
        }
        [keyValueArr addObject:keyValue];
    }
    NSString *keyValueStr = [keyValueArr componentsJoinedByString:@","];
    
    return [NSString stringWithFormat:@"UPDATE %@ SET %@ WHERE %@",table,keyValueStr,primaryKeyValueStr];
}




@end





