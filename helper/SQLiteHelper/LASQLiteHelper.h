//
// Created by tekyinkwee on 7/23/13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>

typedef enum {
    LADbResponseFailed = -1,
    LADbResponseExist = 0,
    LADbResponseCreated = 1
} LADbResponse;

@interface LASQLiteHelper : NSObject{
    sqlite3 *database;
}
@property BOOL isDatabaseOpen;

@property(nonatomic) BOOL debugMode;

+ (LASQLiteHelper *)createDatabaseWithDbName:(NSString *)dbName Statements:(NSArray *)statements;

+ (LASQLiteHelper *)openDatabaseWithDbName:(NSString *)dbName;

- (id)initWithName:(NSString *)dbName;

- (bool)runQuery:(NSString *)query;

- (BOOL)insertToTable:(NSString *)tableName values:(NSDictionary *)values;

- (BOOL)deleteFromTable:(NSString *)table key:(NSString *)key value:(NSString *)value;

- (void)clearTable:(NSString *)table;

- (void)clearTables:(NSArray *)tables;

- (void)clearAllTables;

- (BOOL)checkForColumn:(NSString *)desiredColumn inTable:(NSString *)tableName;

- (NSMutableArray *)selectWithQuery:(NSString *)query;

- (NSMutableDictionary *)selectSingleDataWithQuery:(NSString *)query;

- (BOOL)updateTable:(NSString *)tableName withControlKey:(NSDictionary *)controlKey andElements:(NSDictionary *)elements;

- (void)close;
@end