//
//  SQLiteService.m
//  SQLite
//
//  Created by 李子海LEO on 5/6/16.
//  Copyright © 2016 李子海LEO. All rights reserved.
//

#import "SQLiteService.h"

static NSString *tableName;
@implementation SQLiteService
-(instancetype)init
{
    return self;
}
-(NSString *)dataFilePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSLog(@"%@",documentsDirectory);
//可以定义成任何类型的文件，也可以不定义成.db文件，任何格式都行，定义成.sb文件都行，达到了很好的数据隐秘性
    return [documentsDirectory stringByAppendingPathComponent:@"data.db"];
}
#pragma mark - 是否能创建并打开数据库
-(BOOL)openDB
{
    NSString *path = [self dataFilePath];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    BOOL isFind = [fileManager fileExistsAtPath:path];
    
    if (isFind) {
        NSLog(@"数据库已经存在");
        //打开数据库，这里的[path UTF8String]是将NSString转换为C字符串，因为SQLite3是采用可移植的C(而不是oc)编写的，它不知道什么是NSString.
        if (sqlite3_open([path UTF8String],&_dataBase) != SQLITE_OK) {
            
            //如果数据库打开失败，那么关闭数据库
            sqlite3_close(self.dataBase);
            
            NSLog(@"ERROR:数据库打开失败");
            
            return NO;
        }
        //创建一个新的表
        [self createTestList:self.dataBase];
        
        return YES;
    }
        //如果发现数据库不存在则利用sqlite3_open创建数据库（上面已经提到过），与上面相同，路径要转换为C字符串
    if (sqlite3_open([path UTF8String],&_dataBase) == SQLITE_OK) {
        
        //创建一个新的表
        [self createTestList:self.dataBase];
        
        return YES;
    }else {
        //如果创建并打开数据库失败则关闭数据库
        sqlite3_close(self.dataBase);
        
        NSLog(@"ERROR:数据库打开失败");
        
        return NO;
    }
    return NO;
}

#pragma mark -创建表
/** chuangjian*/
-(BOOL)createTestList:(sqlite3 *)db
{
    //sql语句－－创建表
    // testID是列名，int 是数据类型，testValue是列名，text是数据类型，是字符串类型
    char *sql = "create table if not exists testTable(ID INTEGER PRIMARY KEY AUTOINCREMENT, testID int,testValue text,testName text)";
    
    sqlite3_stmt *statement;
    
    //使用sqlite3_prepare_v2接口访问数据库,sqlite3_prepare_v2 接口把一条SQL语句解析到statement结构里去. 是当前比较好的的一种方法
    
    //第一个参数跟前面一样，是个sqlite3 * 类型变量，
    //第二个参数是一个 sql 语句。
    //第三个参数我写的是-1，这个参数含义是前面 sql 语句的长度。如果小于0，sqlite会自动计算它的长度（把sql语句当成以\0结尾的字符串）。
    //第四个参数是sqlite3_stmt 的指针的指针。解析以后的sql语句就放在这个结构里。
    //第五个参数是错误信息提示，一般不用,为nil就可以了。
    //如果这个函数执行成功（返回值是 SQLITE_OK 且 statement 不为NULL ），那么下面就可以开始插入二进制数据。
    
    NSInteger sqlReturn = sqlite3_prepare_v2(_dataBase,sql,-1,&statement,nil);
    
    //判断sql语句解析是否出错，如果出错的话程序直接返回
    if (sqlReturn != SQLITE_OK) {
        NSLog(@"ERROR:创建表出错");
    }
    
    //执行sql语句
    int success = sqlite3_step(statement);
    
    //释放sqlite3——stmt
    sqlite3_finalize(statement);
    
    if (success != SQLITE_OK) {

        return NO;
    }

    return YES;
}
-(BOOL)insertTestList:(SQLiteDataList *)insertList
{
    //先判断数据库是否打开
    if ([self openDB]) {
        sqlite3_stmt *statement;
        
        //数据库成功打开
   
        ////这个 sql 语句特别之处在于 values 里面有个? 号。在sqlite3_prepare函数里，?号表示一个未定的值，它的值等下才插入。
        static char *sql = "INSERT INTO testTable(testID, testValue,testName) VALUES(?, ?, ?)";
        
        int success2 = sqlite3_prepare_v2(_dataBase,sql,-1,&statement,NULL);
        
        if (success2 != SQLITE_OK) {
            NSLog(@"ERROR:插入数据到数据库失败");
            
            //关闭数据库
            sqlite3_close(_dataBase);
            
            return NO;
        }
        //这里的数字1，2，3代表上面的第几个问号，这里将三个值绑定到三个绑定变量

        sqlite3_bind_int(statement,1,insertList.sqlID);
        
        sqlite3_bind_text(statement,2,[insertList.sqlText UTF8String],-1,SQLITE_TRANSIENT);
        
        sqlite3_bind_text(statement,3,[insertList.sqlname UTF8String],-1,SQLITE_TRANSIENT);
        
          //执行插入语句
        success2 = sqlite3_step(statement);
        
          //释放statement  为什么需要释放
        sqlite3_finalize(statement);
        
        //如果插入失败
        if (success2 == SQLITE_ERROR) {
            NSLog(@"REEOR:插入数据到数据库失败");
            
             //关闭数据库
            sqlite3_close(_dataBase);
            
            return NO;
        }
       //关闭数据库
        sqlite3_close(_dataBase);
        
        return YES;
    }
    return NO;
}
#pragma mark - 获取数据
-(NSMutableArray *)getTestList
{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:10];
    
    //判断数据库是否打开
    if ([self openDB]) {
        sqlite3_stmt *statement = nil;
        
        //执行获取数据的sql语句
        //从testTable这个表中获取 testID, testValue ,testName，若获取全部的话可以用*代替testID, testValue ,testName。
        char *sql = "SELECT testID, testValue ,testName FROM testTable";
        
        if (sqlite3_prepare_v2(_dataBase, sql, -1, &statement, NULL) != SQLITE_OK) {
            NSLog(@"ERROR:获取数据失败");
            return nil;
        }else {
#warning 注意点1
        //查询结果集中一条一条的遍历所有的记录，这里的数字对应的是列值,注意这里的列值，跟上面sqlite3_bind_text绑定的列值不一样！一定要分开，不然会crash，只有这一处的列号不同，注意！
            while (sqlite3_step(statement) == SQLITE_ROW) {
                
                SQLiteDataList *dataList = [[SQLiteDataList alloc]init];
                
                dataList.sqlID = sqlite3_column_int(statement,0);
                
                char *strText = (char *)sqlite3_column_text(statement,1);
                
                dataList.sqlText = [NSString stringWithUTF8String:strText];
                
                char *strName = (char *)sqlite3_column_text(statement,1);
                
                dataList.sqlname = [NSString stringWithUTF8String:strName];
                
                [array addObject:dataList];
            }
            sqlite3_finalize(statement);
            
            sqlite3_close(_dataBase);
        }
    }
    return [array copy];
}
#pragma mark - 更新数据
-(BOOL)updateTestList:(SQLiteDataList *)updateList
{
    if ([self openDB]) {
        //这相当一个容器，放转化OK的sql语句
        sqlite3_stmt *statement;
        //组织sql语句
        //and 用在where的条件语句 ／  SET语句各字段用逗号
        char *sql = "update testTable set testID = ? , testValue = ? WHERE testName = ?";
        
        //将SQL语句放入到sqlite3——stmt中
        int success = sqlite3_prepare_v2(_dataBase, sql, -1, &statement, NULL);
        
        if (success != SQLITE_OK) {
            
            NSLog(@"ERROR:跟新数据库数据失败");
            
            sqlite3_close(_dataBase);
            
            return NO;
        }
        //这里的数字1，2，3代表第几个问号。这里只有1个问号，这是一个相对比较简单的数据库操作，真正的项目中会远远比这个复杂
        //绑定text类型的数据库数据
         sqlite3_bind_text(statement, 3, [updateList.sqlname UTF8String], -1, SQLITE_TRANSIENT);
        
        sqlite3_bind_text(statement, 2, [updateList.sqlText UTF8String], -1, SQLITE_TRANSIENT);
        
        sqlite3_bind_int(statement, 1, updateList.sqlID);
        
        //执行SQL语句。这里是更新数据库
        success = sqlite3_step(statement);
        
        //    //释放statement
        sqlite3_finalize(statement);
        
        //如果更新失败
        if (success == SQLITE_ERROR) {
            NSLog(@"更新数据库数据失败");
            
            //关闭数据库
            sqlite3_close(_dataBase);
            
            return NO;
        }
        //如果更新数据库成功，也需要关闭数据库
        sqlite3_close(_dataBase);
        
        return YES;
    }
    return NO;
}
#pragma mark - 删除数据
-(BOOL)deleteTestList:(SQLiteDataList *)deletList
{
    
    if ([self openDB]) {
        sqlite3_stmt *statement;
        
        //组织sql语句
        //and 用在where的条件语句 ／  更新多个值用  ，隔开
        static char *sql = "delete from testTable  where testID = ? and testValue = ? and testName = ?";
        
        //把sql语句放入到 sqlite3_stmt *statement中
        int success = sqlite3_prepare_v2(_dataBase, sql, -1, &statement, NULL);
        
        if (success != SQLITE_OK) {
            NSLog(@"删除数据库数据失败");
            
            sqlite3_close(_dataBase);
            
            return NO;
        }
        //这里的数字1，2，3代表第几个问号。这里只有1个问号，这是一个相对比较简单的数据库操作，真正的项目中会远远比这个复杂
        sqlite3_bind_int(statement, 1, deletList.sqlID);
        sqlite3_bind_text(statement, 2, [deletList.sqlText UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 3, [deletList.sqlname UTF8String], -1, SQLITE_TRANSIENT);
        
        //执行sql语句，这里是更新数据库
        success = sqlite3_step(statement);
        
        //释放statement
        sqlite3_finalize(statement);
        
        //如果执行失败
        if (success == SQLITE_ERROR) {
            NSLog(@"删除数据库数据失败");
            
            //关闭数据库
            sqlite3_close(_dataBase);
            
            return NO;
        }
        
        //执行成功后依然也要关闭数据库
        sqlite3_close(_dataBase);
        
        return YES;
    }
    return NO;
}
#pragma mark - 查询数据
-(NSMutableArray *)searchTestList:(NSString *)searchString andSource:(NSString *)where
{

    NSMutableArray *array = [NSMutableArray arrayWithCapacity:10];
    
    //判断数据库是否打开
    if ([self openDB]) {
        
        sqlite3_stmt *statement = nil;
        
        //执行sql语句
        //char *sql = "SELECT * FROM testTable WHERE testName like ?";//这里用like代替=可以执行模糊查找，原来是"SELECT * FROM testTable WHERE testName = ?"
        NSString *querySQL = [NSString stringWithFormat:@"SELECT * from testTable where  \"%@\" like \"%@\"",where,searchString];
        
        const char *sql = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(_dataBase, sql, -1, &statement, NULL)) {
            
            NSLog(@"准备查找数据失败");
            
            return nil;
        }else {
            //SQLiteDataList *dataList = [[SQLiteDataList alloc]init];
            
             sqlite3_bind_text(statement, 3, [searchString UTF8String], -1, SQLITE_TRANSIENT);
            
             //查询结果集中一条一条的遍历所有的记录，这里的数字对应的是列值。
            while (sqlite3_step(statement) == SQLITE_ROW) {
                
                SQLiteDataList *dataList = [[SQLiteDataList alloc]init];
                
                dataList.sqlID   = sqlite3_column_int(statement,1);
                char* strText   = (char*)sqlite3_column_text(statement, 2);
                dataList.sqlText = [NSString stringWithUTF8String:strText];
                char *strName = (char*)sqlite3_column_text(statement, 3);
                dataList.sqlname = [NSString stringWithUTF8String:strName];
                
                [array addObject:dataList];
            }
        
        }
        sqlite3_finalize(statement);
        sqlite3_close(_dataBase);
    }
    
    return [array copy];
}
@end
