//
//  SQLiteService.h
//  SQLite
//
//  Created by 李子海LEO on 5/6/16.
//  Copyright © 2016 李子海LEO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>
#import "SQLiteDataList.h"

#define LEOFileName  @"data.db"
@class SQLiteService;

@interface SQLiteService : NSObject

@property(nonatomic,assign)sqlite3 *dataBase;


-(BOOL) createTestList:(sqlite3 *)db;//创建数据库

-(BOOL) insertTestList:(SQLiteDataList *)insertList;//插入数据

-(BOOL) updateTestList:(SQLiteDataList *)updateList;//更新数据

-(NSMutableArray*)getTestList;//获取全部数据

- (BOOL) deleteTestList:(SQLiteDataList *)deletList;//删除数据

-(NSMutableArray *)searchTestList:(NSString *)searchString andSource:(NSString *)where;//查询数据库，searchID为要查询数据的ID，返回数据为查询到的数据
@end
