//
//  ViewController.m
//  SQLite
//
//  Created by 李子海LEO on 5/6/16.
//  Copyright © 2016 李子海LEO. All rights reserved.
//

#warning  1.创建 删除 更新 查找 获取 语句需要手动在SQLiteService.m文件中更改

#import "ViewController.h"
#import "SQLiteService.h"
#import "SQLiteDataList.h"

enum oprateType{
    
    INSERTDATA = 0,
    CHANGEDATA = 1,
    
};

@interface ViewController ()
@property(nonatomic,strong)SQLiteService *sqlSer;
@property(nonatomic,strong)SQLiteDataList *sqlDataList;
@property(nonatomic,assign)enum oprateType type;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    SQLiteService *sqlSer = [[SQLiteService alloc]init];
    
    SQLiteDataList *sqlDataList =[[SQLiteDataList alloc]init];
    
    self.sqlDataList = sqlDataList;
    
    self.sqlSer = sqlSer;
}

- (IBAction)insertData:(id)sender
{
    if (_type == 0) {
        //插入数据

        self.sqlDataList.sqlID = 19;
        
        self.sqlDataList.sqlname =@"lizizihai";
        
        self.sqlDataList.sqlText =@"man";
        
        //调用封装好的数据库插入函数
        if ([self.sqlSer insertTestList:self.sqlDataList]) {
            
            NSLog(@"插入成功");
            
            NSLog(@"%@",[NSBundle mainBundle].bundlePath);
        }else {
            NSLog(@"插入失败");
        }
    }
}

- (IBAction)changeData:(id)sender
{
    SQLiteDataList *sqlDataList =[[SQLiteDataList alloc]init];
    
    sqlDataList.sqlID = 18;
    sqlDataList.sqlname = @"leo";
    sqlDataList.sqlText = @"good";
    
    //调用封装好的更新数据库来更新数据
    if ([self.sqlSer updateTestList:sqlDataList]) {
        NSLog(@"数据更新成功");
    }else {
        NSLog(@"数据更新失败");
    }
}

- (IBAction)removeData:(id)sender
{
    [self.sqlSer deleteTestList:self.sqlDataList];
    
    [UIImage imageNamed:@"wer"];
}

- (IBAction)searchData:(id)sender
{
    NSLog(@"%@", [self.sqlSer searchTestList:@"lizizihai" andSource:@"testName"]);
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    NSLog(@"%@",[self.sqlSer getTestList]);
}
-(void)didReceiveMemoryWarning{

}
@end
