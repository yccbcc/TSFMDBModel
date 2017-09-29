# TSFMDBModel
### 介绍：
基于FMDB实现数据库的数据存储。创建、增、删、改、查只需一句代码。

### 技术点：
封装FMDB，并结合runTime相关技术，实现数据的动态存储。

### 导入
导入FMDB库 和 TSDataBaseManager文件夹
最好把TSDataBaseManager.h 放入pch文件中，方便全局调用
```
#import "TSDataBaseManager.h"
```

### How To Use（使用）
1.设置主键（model的某一个字段。用代理设置）
2.注册表
3.完成增删改查等。
PS：
1.如果 Model 中 的属性 有为NSInteger/NSUInteger 类型 需要做 *** 特殊 *** 处理 请看 TestModel.m 中处理过程
2.创建表时:使用Model为表名，model所有属性为字段名。



#### 1. 在AppDelegate实现代理 TSDataBaseManagerDelegate
利用model实现数据存储，每个model的model类名作为表名，在这个代理设置表的主键
```
[TSDataBaseManager sharedInstance].delegate = self;

//设置数据库主键(每个表都要设置主键且不能重复，通过主键可以查找删除表中model数据等操作),每注册一个表都需要设置主键（可以为NSString，int等类型，例子中 表“TestModel"的主键则为@"primaryKey"）
- (NSDictionary *)TS_saveDBTablePrimary{
      return @{
                  @"TestModel":@"primaryKey"
              };
}
```
#### 2. 注册表
表不存在则创建，表存在则不会创建新的。表名为model类的类名（例子中表名为"TestModel"）。可以再App启动时（比如在Appdelegate）集中调用一次，或者每次在使用哪个表前都调用一次。
```
[[TSDataBaseManager sharedInstance] registerClass:[TestModel class]];
```

#### 3. 保存数据到表中
传入需要保存的model即可保存到数据库。通过主键判断该model数据在表中是否存在（主键一致即为存在），如果存在则更新数据，如果不存在则插入到表中。
```
//- (BOOL)save:(id)model;
//return 返回保存成功失败。
[[TSDataBaseManager sharedInstance] save:model];
```

#### 4.获取
通过传入model的主键获取表中存储的model数据
PS：如果 Model 中 的属性 有为NSInteger/NSUInteger 类型 需要做特殊处理 请看 GDPushMessageModel.m 中处理过程。主键为什么类型则传入的主键value必须为什么类型

```
//- (id)fetchModel:(Class)aClass value:(NSString *)value;

TestModel *model = [[TSDataBaseManager sharedInstance] fetchModel:[TestModel class] value:@([_getModelTf.text longLongValue])];
```

#### 5. 删除
通过传入model的主键删除model表中存储的model数据
```
- (BOOL)deleteModel:(id)model;

[[TSDataBaseManager sharedInstance] deleteModel:model];
```

#### 6.删除所有数据
通过传入model的类名删除model表中存储的所有model数据
```
[[TSDataBaseManager sharedInstance] deleteClass:[TestModel class]];
```

#### 7. 获取所有数据
通过model的类名，获取model表中所有的数据，并返回一个数组
表不存在则创建，表存在则不会创建新的。表名为model类的类名（例子中表名为"TestModel"）
```
NSArray *all = [[TSDataBaseManager sharedInstance] fetchAll:[TestModel class]];
```

### 优势与弊端
优势：一句话创建表，一句话增删改查。无论多少个表使用此类一起管理，无需多余代码。

弊端：如果表创建后model的字段改变了，再操作数据库则会出现bug，需要卸载App重新安装。不过在实际应用过程中，应该先想好数据库的字段等信息，不会也随意改动。



