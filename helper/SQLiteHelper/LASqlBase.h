//
// Created by Tek Yin Kwee on 12/11/13.
// Copyright (c) 2013 vBox. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <sqlite3.h>


@interface LASqlBase : NSObject {
    NSString *databasePath;
}
+ (LASqlBase *)getSharedInstance;

- (BOOL)createDBWithName:(NSString *)dbName;

- (bool)runQuery:(NSString *)query;

- (NSMutableArray *)selectWithQuery:(NSString *)query;

- (BOOL)updateTable:(NSString *)table values:(NSMutableDictionary *)values where:(NSString *)field :(NSString *)value;

- (BOOL)insertToTable:(NSString *)tableName values:(NSDictionary *)values;

- (NSMutableDictionary *)selectSingleDataWithQuery:(NSString *)query;

- (void)clearTable:(NSString *)table;

- (int)GetRowCountWithQuery:(NSString *)query;
@end