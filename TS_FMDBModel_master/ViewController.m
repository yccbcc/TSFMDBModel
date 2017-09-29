//
//  ViewController.m
//  TS_FMDBModel_master
//
//  Created by GDTS on 2017/9/28.
//  Copyright © 2017年 GDTS. All rights reserved.
//

#import "ViewController.h"
#import "TestModel.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *primaryTf;
@property (weak, nonatomic) IBOutlet UITextField *alertTf;
@property (weak, nonatomic) IBOutlet UITextField *interAgeTf;
@property (weak, nonatomic) IBOutlet UITextField *uInterAgeTf;

@property (weak, nonatomic) IBOutlet UITextField *deleteModelTf;
@property (weak, nonatomic) IBOutlet UITextField *getModelTf;

@property (weak, nonatomic) IBOutlet UITextView *showGetModelView;
@property (weak, nonatomic) IBOutlet UITextView *showAllDataView;


@end

@implementation ViewController
{
    NSString *_fileName;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
#pragma mark - 表注册（每次使用表之前都要调用，或者在appdegate中统一调用一次）
    
    [[TSDataBaseManager sharedInstance] registerClass:[TestModel class]];
    
    //获取表中所有数据并进行展示
    [self fetchAll];
    
    //数据库
    //    [self db];
}

#pragma mark - 数据库 的 增删改查

//向表中插入model
- (IBAction)saveDB:(id)sender {
    
    TestModel *model = [[TestModel alloc] init];
    model.primaryKey = [self.primaryTf.text longLongValue];
    model.alert = _alertTf.text;
    model.integerAge = [self.interAgeTf.text longLongValue];
    model.uIntegerAge = [self.uInterAgeTf.text longLongValue];
    
    [[TSDataBaseManager sharedInstance] save:model];
    
    [self fetchAll];
}

//通过主键获取Model
- (IBAction)getModel:(id)sender {
    
    TestModel *model = [[TSDataBaseManager sharedInstance] fetchModel:[TestModel class] value:@([_getModelTf.text longLongValue])];
    
    _showGetModelView.text = [NSString stringWithFormat:@"获取数据展示:%ld %@ %ld %lu\n",model.primaryKey,model.alert,(long)model.integerAge,(unsigned long)model.uIntegerAge];
}



//通过model的主键删除 表中存储的model
- (IBAction)deleteModel:(id)sender {
    TestModel *model = [[TestModel alloc] init];
    model.primaryKey =  [_deleteModelTf.text intValue];
    [[TSDataBaseManager sharedInstance] deleteModel:model];
    
    [self fetchAll];
}


//删除表中所有数据
- (IBAction)DeleteAll:(id)sender {
    
    [[TSDataBaseManager sharedInstance] deleteClass:[TestModel class]];
    
    [self fetchAll];
}


//获取表中所有数据并展示
- (void)fetchAll{
    _showAllDataView.text = @"";
    NSArray *all = [[TSDataBaseManager sharedInstance] fetchAll:[TestModel class]];
    
    for (TestModel *model in all) {
        
        _showAllDataView.text = [NSString stringWithFormat:@"获取数据展示:%ld %@ %ld %lu\n %@",model.primaryKey,model.alert,(long)model.integerAge,(unsigned long)model.uIntegerAge,_showAllDataView.text];
    }
}

#pragma mark - 数据库
//- (void)db{
//
//    for (int i = 0; i < 10; i++) {
//
//        TestModel *model = [[TestModel alloc] init];
//        model.alert = @"这是alert";
//        model.primaryKey = 10000+i;
//
//        [[TSDataBaseManager sharedInstance] save:model];
//    }
//
//    TestModel *model = [[TestModel alloc] init];
//    model.primaryKey = 10005;
//
//    [[TSDataBaseManager sharedInstance] deleteModel:model];
//
//    [[TSDataBaseManager sharedInstance] deleteClass:[TestModel class]];
//
//    NSArray *all = [[TSDataBaseManager sharedInstance] fetchAll:[TestModel class]];
//    for (TestModel *model in all) {
//        NSLog(@"%ld,%@",model.primaryKey,model.alert);
//    }
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
