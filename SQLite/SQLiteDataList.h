//
//  SQLiteDataList.h
//  SQLite
//
//  Created by 李子海LEO on 5/6/16.
//  Copyright © 2016 李子海LEO. All rights reserved.
//

#import <Foundation/Foundation.h>
//此类专门用于存储数据

@interface SQLiteDataList : NSObject
@property (nonatomic) int sqlID;
@property (nonatomic, retain) NSString *sqlText;
@property (nonatomic, retain) NSString *sqlname;
@end
