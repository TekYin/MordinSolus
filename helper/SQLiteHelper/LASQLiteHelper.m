//
// Created by tekyinkwee on 7/23/13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "LASQLiteHelper.h"
#import <sqlite3.h>


@implementation LASQLiteHelper {

}

+ (LASQLiteHelper *)createDatabaseWithDbName:(NSString *)dbName Statements:(NSArray *)statements {
    LASQLiteHelper *helper = [[LASQLiteHelper alloc] initWithName:dbName];
    if (helper) {
        for (NSString *statement in statements) {
            if ([helper runQuery:statement]) {
                NSLog(@"Query: '%@'", statement);
            }
            else {
                NSLog(@"failed: %@", statement);
            }
        }
    }
    return helper;
}

+ (LASQLiteHelper *)openDatabaseWithDbName:(NSString *)dbName {
    return [[LASQLiteHelper alloc] initWithName:dbName];
}

- (id)initWithName:(NSString *)dbName {
    self = [super init];
    NSString *docsDir;
    NSArray *dirPaths;

    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = dirPaths[0];
    NSString *path = [[NSString alloc] initWithString:[docsDir stringByAppendingPathComponent:dbName]];

    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSLog(@"DB Exist, opening current db");
    } else {
        NSLog(@"Creating new DB");
    }

    const char *dbPath = [path UTF8String];
    if (sqlite3_open(dbPath, &database) == SQLITE_OK) {
        _isDatabaseOpen = YES;
        return self;
    } else {
        return nil;
    }
}


- (bool)runQuery:(NSString *)query {
    if (self.debugMode)
    NSLog(@"db: %@, query: %@", _isDatabaseOpen ? @"Y" : @"N", query);
    if (_isDatabaseOpen) {
        char *errMsg;

        const char *sql_stmt = [query UTF8String];
        BOOL result = sqlite3_exec(database, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK;
        if (self.debugMode) {
            if (errMsg) {
                NSLog(@"query error: %s", errMsg);
            } else {
                NSLog(@"%i row affected", sqlite3_changes(database));
            }
        }

        return result ? false : true;
    } else {
        if (self.debugMode)
        NSLog(@"Db is closed");
        return false;
    }
}

- (BOOL)insertToTable:(NSString *)tableName values:(NSDictionary *)values {
    NSLog(@"Inserting table to %@", tableName);
    NSMutableString *query = [[NSMutableString alloc] initWithFormat:@"INSERT INTO %@ ( `", tableName];

    int keyCount = 0;
    for (NSObject *key in [values allKeys]) {
        NSString *keyString = [NSString stringWithFormat:@"%@", key];

        if (keyCount != 0)
            [query appendString:@"` , `"];

        [query appendString:keyString];

        keyCount++;
    }

    [query appendString:@"` ) VALUES ( '"];

    int valueCount = 0;
    for (NSObject *value in [values allValues]) {
        NSString *valueString = [NSString stringWithFormat:@"%@", value];

        if (valueCount != 0)
            [query appendString:@"' , '"];

        [query appendString:[valueString stringByReplacingOccurrencesOfString:@"'" withString:@""]];
        valueCount++;
    }

    [query appendString:@"' )"];

    return [self runQuery:query];
}

- (BOOL)deleteFromTable:(NSString *)table key:(NSString *)key value:(NSString *)value {
    NSMutableString *query = [[NSMutableString alloc] initWithFormat:@"DELETE FROM %@ WHERE `%@` = '%@' ", table, key, value];

    return [self runQuery:query];
}

- (void)clearTable:(NSString *)table {
    NSString *query = [NSString stringWithFormat:@"DELETE FROM %@", table];

    [self runQuery:query];
}

- (void)clearTables:(NSArray *)tables {
    for (NSString *table in tables) {
        NSString *query = [NSString stringWithFormat:@"DELETE FROM %@", table];
        [self runQuery:query];
    }
}

- (void)clearAllTables {
    NSArray *tables = [self selectWithQuery:@"SELECT name FROM sqlite_master WHERE type = 'table'"];
    [self clearTables:tables];
}

- (BOOL)checkForColumn:(NSString *)desiredColumn inTable:(NSString *)tableName {

    const char *sql = [[NSString stringWithFormat:@"PRAGMA table_info(%@)", tableName] cStringUsingEncoding:NSUTF8StringEncoding];
    sqlite3_stmt *stmt;

    if (sqlite3_prepare_v2(database, sql, -1, &stmt, NULL) != SQLITE_OK) {
        return NO;
    }

    while (sqlite3_step(stmt) == SQLITE_ROW) {

        NSString *fieldName = @((char *) sqlite3_column_text(stmt, 1));
        if ([desiredColumn isEqualToString:fieldName])
            return YES;
    }

    return NO;
}

- (NSMutableArray *)selectWithQuery:(NSString *)query {
    if (self.debugMode)
    NSLog(@"QUERY SELECT: %@", query);
    sqlite3_stmt *statement;

    sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil);
    int columnCount = sqlite3_column_count(statement);

    NSMutableArray *result = [[NSMutableArray alloc] init];


    while (sqlite3_step(statement) == SQLITE_ROW) {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        for (int column = 0; column < columnCount; ++column) {
            char *nameData = (char *) sqlite3_column_name(statement, column);
            if (nameData != nil) {
                NSString *nameString = [[NSString alloc] initWithUTF8String:nameData];

                char *contentData = (char *) sqlite3_column_text(statement, column);
                if (contentData != nil) {
                    NSString *contentString = [[NSString alloc] initWithUTF8String:contentData];

                    dict[nameString] = contentString;
                }
                else {
                    dict[nameString] = @"";
                }
            }

        }

        [result addObject:dict];

    }

    return result;
}

- (NSMutableDictionary *)selectSingleDataWithQuery:(NSString *)query {
    sqlite3_stmt *statement;

    sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil);
    int columnCount = sqlite3_column_count(statement);


    while (sqlite3_step(statement) == SQLITE_ROW) {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        for (int column = 0; column < columnCount; ++column) {
            char *nameData = (char *) sqlite3_column_name(statement, column);
            if (nameData != nil) {
                NSString *nameString = [[NSString alloc] initWithUTF8String:nameData];

                char *contentData = (char *) sqlite3_column_text(statement, column);
                if (contentData != nil) {
                    NSString *contentString = [[NSString alloc] initWithUTF8String:contentData];

                    dict[nameString] = contentString;
                }
                else {
                    dict[nameString] = @"";
                }
            }

        }

        return dict;
    }

    return nil;
}

- (BOOL)updateTable:(NSString *)tableName withControlKey:(NSDictionary *)controlKey andElements:(NSDictionary *)elements {
    NSMutableString *query = [[NSMutableString alloc] initWithFormat:@"UPDATE %@ SET ", tableName];

    int keyCount = 0;
    for (NSObject *key in [elements allKeys]) {
        NSString *keyString = [NSString stringWithFormat:@"%@", key];

        if (keyCount != 0)
            [query appendString:@" , "];

        NSString *valueString;
        NSObject *keyValue = elements[keyString];
        if ([keyValue isKindOfClass:[NSNumber class]]) {
            valueString = [NSString stringWithFormat:@"%@", keyValue];
        }
        else {
            valueString = [NSString stringWithFormat:@"'%@'", keyValue];
        }


        [query appendString:[NSString stringWithFormat:@"%@ = %@", keyString, valueString]];

        keyCount++;
    }

    keyCount = 0;
    if (controlKey.count > 0) {
        [query appendString:@" WHERE "];

        for (NSObject *key in controlKey.allKeys) {
            if (keyCount != 0)
                [query appendString:@" AND "];

            NSString *valueString;
            NSObject *keyValue = controlKey[key];
            if ([keyValue isKindOfClass:[NSNumber class]]) {
                valueString = [NSString stringWithFormat:@"%@", keyValue];
            }
            else {
                valueString = [NSString stringWithFormat:@"`%@`", keyValue];
            }


            NSString *keyString = [NSString stringWithFormat:@"`%@`", key];

            [query appendFormat:@"%@ = %@", keyString, valueString];

        }
    }

    return [self runQuery:query];
}


- (void)close {
    if (_isDatabaseOpen) {
        sqlite3_close(database);
        _isDatabaseOpen = NO;
    }
}

@end