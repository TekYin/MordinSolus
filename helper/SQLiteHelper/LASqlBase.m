//
// Created by Tek Yin Kwee on 12/11/13.
// Copyright (c) 2013 vBox. All rights reserved.
//


#import "LASqlBase.h"


@implementation LASqlBase {

}
static LASqlBase *sharedInstance = nil;
static sqlite3 *database = nil;
static sqlite3_stmt *statement = nil;

+ (LASqlBase *)getSharedInstance {
    if (!sharedInstance) {
        sharedInstance = (LASqlBase *) [[super allocWithZone:NULL] init];
    }
    return sharedInstance;
}

- (BOOL)createDBWithName:(NSString *)dbName {
    NSString *docsDir;
    NSArray *dirPaths;

    // Get the documents directory
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = dirPaths[0];

    // Build the path to the database file
    databasePath = [[NSString alloc] initWithString:[docsDir stringByAppendingPathComponent:dbName]];

    NSFileManager *fileMgr = [NSFileManager defaultManager];
    if (![fileMgr fileExistsAtPath:databasePath]) {
        const char *dbPath = [databasePath UTF8String];
        if (sqlite3_open(dbPath, &database) == SQLITE_OK) {
            sqlite3_close(database);
            NSLog(@"Database created");
            return YES;
        }
        else {
            NSLog(@"Failed to open/create database");
            return NO;
        }
    } else {
        NSLog(@"Database is exist");
        return YES;
    }
}


- (bool)runQuery:(NSString *)query {
    NSLog(@"run query: %@", query);
    const char *dbPath = [databasePath UTF8String];
    if (sqlite3_open(dbPath, &database) == SQLITE_OK) {
        NSString *insertSQL = query;
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(database, insert_stmt, -1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE) {
            sqlite3_reset(statement);
            NSLog(@"%i row affected", sqlite3_changes(database));
            return YES;
        }
        else {
            sqlite3_reset(statement);
            NSLog(@"error: %s\n", sqlite3_errmsg(database));
            return NO;
        }
    }
    return NO;
}

- (NSMutableArray *)selectWithQuery:(NSString *)query {
    const char *dbPath = [databasePath UTF8String];
    NSMutableArray *result = nil;

    if (sqlite3_open(dbPath, &database) == SQLITE_OK) {
        NSString *querySQL = query;

        NSMutableArray *resultArray = [[NSMutableArray alloc] init];
        if (sqlite3_prepare_v2(database, [querySQL UTF8String], -1, &statement, NULL) == SQLITE_OK) {
            int columnCount = sqlite3_column_count(statement);
            result = [[NSMutableArray alloc] init];

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
        }
    }
    sqlite3_reset(statement);
    return result;
}

- (BOOL)updateTable:(NSString *)table values:(NSMutableDictionary *)values where:(NSString *)field :(NSString *)value {
    NSMutableString *query = [NSMutableString string];
    [query appendFormat:@"UPDATE `%@` SET ", table];

    NSMutableArray *setter = [NSMutableArray array];
    NSArray *keys = values.allKeys;
//        NSLog(@"update with keys: %@", keys);
    for (NSString *key in keys) {
        [setter addObject:[NSString stringWithFormat:@" `%@` = '%@' ", key, [values objectForKey:key]]];
    }
    [query appendString:[setter componentsJoinedByString:@","]];
    [query appendFormat:@" WHERE `%@` = %@ ", field, value];
    [[LASqlBase getSharedInstance] runQuery:query];
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

- (NSMutableDictionary *)selectSingleDataWithQuery:(NSString *)query {
    NSMutableArray *data = [self selectWithQuery:query];
    if ([data count] > 0)
        return [data objectAtIndex:0];
    else
        return nil;
}

- (void)clearTable:(NSString *)table {
    NSString *query = [NSString stringWithFormat:@"DELETE FROM %@", table];
    [self runQuery:query];
}

- (int)GetRowCountWithQuery:(NSString *)query {
    return [[self selectWithQuery:query] count];
}
@end