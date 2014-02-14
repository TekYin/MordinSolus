//
// Created by Tek Yin Kwee on 12/10/13.
// Copyright (c) 2013 vBox. All rights reserved.
//


#import "ODSqlHandler2.h"
#import "LASqlBase.h"


@implementation ODSqlHandler2 {

}

+ (void)createDatabaseWithDbName:(NSString *)dbName {
    [[LASqlBase getSharedInstance] createDBWithName:dbName];
    NSArray *statements = [NSArray arrayWithObjects:
            @"CREATE TABLE IF NOT EXISTS `period` (\n"
                    "  startDate NUMERIC(10) PRIMARY KEY,\n"
                    "  endDate NUMERIC,\n"
                    "  UNIQUE(startDate) "
                    ");",
            @"CREATE TABLE IF NOT EXISTS `journal` (\n"
                    "  date NUMERIC(10) PRIMARY KEY ,\n"
                    "  flow NUMERIC(3) DEFAULT 0,\n"
                    "  spotting NUMERIC(1) DEFAULT 0,\n"
                    "  intimate NUMERIC(1) DEFAULT 0,\n"
                    "  mood NUMERIC(3) DEFAULT 0,\n"
                    "  weight NUMERIC(5) DEFAULT 0,\n"
                    "  temp NUMERIC(5) DEFAULT 0,\n"
                    "  ovulated NUMERIC(2) DEFAULT 0,\n"
                    "  cervicalMucus NUMERIC(2) DEFAULT 0,\n"
                    "  cervicalPosition NUMERIC(2) DEFAULT 0,\n"
                    "  cervicalFirmness NUMERIC(2) DEFAULT 0,\n"
                    "  ovulationKit NUMERIC(2) DEFAULT 0,\n"
                    "  numSymptoms NUMERIC(2) DEFAULT 0,\n"
                    "  ferning NUMERIC(2) DEFAULT 0,\n"
                    "  notes TEXT\n"
                    ");",
            @"CREATE TABLE IF NOT EXISTS `symptoms_type` (\n"
                    "  symptoms_id NUMERIC PRIMARY KEY,\n"
                    "  description TEXT\n"
                    ");",
            @"CREATE TABLE IF NOT EXISTS `symptoms` (\n"
                    "  date NUMERIC,\n"
                    "  symptoms_id NUMERIC,\n"
                    "  value NUMERIC(3) \n"
                    ");",
            @"CREATE TABLE IF NOT EXISTS `notifications` (\n"
                    "  id NUMERIC PRIMARY KEY,\n"
                    "  notificationText TEXT,\n"
                    "  notificationType NUMERIC,\n"
                    "  numDaysOffset NUMERIC,\n "
                    "  isEnabled NUMERIC,\n"
                    "  notificationHour NUMERIC,\n"
                    "  notificationMinute NUMERIC"
                    ");",
            nil];
    for (NSString *statement in statements) {
        [[LASqlBase getSharedInstance] runQuery:statement];
    }
}

+ (void)putNotificationWithId:(int)id Text:(NSString *)text type:(int)type offset:(int)offset enabled:(bool)enabled hour:(int)hour minute:(int)minute {
    NSMutableDictionary *data = [[LASqlBase getSharedInstance] selectSingleDataWithQuery:[NSString stringWithFormat:@"SELECT * FROM `notification` WHERE `id`= %i", id]];
    if (data != nil) {
        NSMutableString *query = [NSMutableString string];
        [query appendString:@"UPDATE `journal` SET"];

        NSMutableArray *setter = [NSMutableArray array];
        NSArray *keys = data.allKeys;
//        NSLog(@"update with keys: %@", keys);
        for (NSString *key in keys) {
            if (![@"id" isEqualToString:key]) {
                [setter addObject:[NSString stringWithFormat:@"`%@` = '%@'", key, [data objectForKey:key]]];
            }
        }
        [query appendString:[setter componentsJoinedByString:@","]];
        [query appendFormat:@" WHERE `id` = %@", [data objectForKey:@"id"]];
        [[LASqlBase getSharedInstance] runQuery:query];
    } else {

        NSMutableDictionary *newData = [NSMutableDictionary dictionary];
        [newData setObject:[NSNumber numberWithInt:id] forKey:@"id"];
        [newData setObject:text forKey:@"notificationText"];
        [newData setObject:[NSNumber numberWithInt:type] forKey:@"notificationType"];
        [newData setObject:[NSNumber numberWithInt:offset] forKey:@"numDaysOffset"];
        [newData setObject:enabled ? @"1" : @"0" forKey:@"isEnabled"];
        [newData setObject:[NSNumber numberWithInt:hour] forKey:@"notificationHour"];
        [newData setObject:[NSNumber numberWithInt:minute] forKey:@"notificationMinute"];

        [[LASqlBase getSharedInstance] insertToTable:@"journal" values:newData];
    }
}

+ (NSMutableArray *)getNotificationWithType:(int)type {
    return [[LASqlBase getSharedInstance] selectWithQuery:[NSString stringWithFormat:@"SELECT * FROM `notification` WHERE `type`=%i ORDER by `id` ASC", type]];
}

+ (void)resetData {
    [[LASqlBase getSharedInstance] runQuery:@"DELETE FROM `period`"];
    [[LASqlBase getSharedInstance] runQuery:@"DELETE FROM `journal`"];
    [[LASqlBase getSharedInstance] runQuery:@"DELETE FROM `symptoms`"];
    [[LASqlBase getSharedInstance] runQuery:@"DELETE FROM `symptoms_type`"];
    [[LASqlBase getSharedInstance] runQuery:@"DELETE FROM `notifications`"];

    [self defaultValues];
}

+ (void)defaultValues {
    NSArray *symptoms = [NSArray arrayWithObjects:
            @"Acne",
            @"Anxiety",
            @"Backache",
            @"Bloating",
            @"Breast tenderness",
            @"Chills",
            @"Constipation",
            @"Cramps",
            @"Cravings",
            @"Diarrhea",
            @"Dizziness",
            @"Fatigue",
            @"Headaches",
            @"Hot Flashes",
            @"Insomnia",
            @"Irritability",
            @"Migraine",
            @"Moody",
            @"Nausea",
            nil];
    for (int i = 0; i < symptoms.count; i++) {
        NSString *symptom = [symptoms objectAtIndex:i];
        NSMutableDictionary *values = [NSMutableDictionary dictionary];
        [values setObject:[NSNumber numberWithInt:i] forKey:@"symptoms_id"];
        [values setObject:symptom forKey:@"description"];
        [[LASqlBase getSharedInstance] insertToTable:@"symptoms_type" values:values];
    }

    [self putNotificationWithId:0 Text:[PreferenceHandler getFertilityNotificationText] type:0 offset:0 enabled:NO hour:0 minute:0];
    [self putNotificationWithId:1 Text:[PreferenceHandler getFertilityNotificationText] type:0 offset:-1 enabled:NO hour:0 minute:0];
    [self putNotificationWithId:2 Text:[PreferenceHandler getFertilityNotificationText] type:0 offset:-2 enabled:NO hour:0 minute:0];
    [self putNotificationWithId:3 Text:[PreferenceHandler getFertilityNotificationText] type:0 offset:-3 enabled:NO hour:0 minute:0];
    [self putNotificationWithId:4 Text:[PreferenceHandler getFertilityNotificationText] type:0 offset:-4 enabled:NO hour:0 minute:0];
    [self putNotificationWithId:4 Text:[PreferenceHandler getFertilityNotificationText] type:0 offset:-5 enabled:NO hour:0 minute:0];
    [self putNotificationWithId:5 Text:[PreferenceHandler getPeriodNotificationText] type:1 offset:0 enabled:NO hour:0 minute:0];
    [self putNotificationWithId:6 Text:[PreferenceHandler getPeriodNotificationText] type:1 offset:-1 enabled:NO hour:0 minute:0];
    [self putNotificationWithId:7 Text:[PreferenceHandler getPeriodNotificationText] type:1 offset:-2 enabled:NO hour:0 minute:0];
    [self putNotificationWithId:8 Text:[PreferenceHandler getPeriodNotificationText] type:1 offset:-3 enabled:NO hour:0 minute:0];
    [self putNotificationWithId:8 Text:[PreferenceHandler getPeriodNotificationText] type:1 offset:-4 enabled:NO hour:0 minute:0];
    [self putNotificationWithId:9 Text:[PreferenceHandler getPeriodNotificationText] type:1 offset:-5 enabled:NO hour:0 minute:0];
}

+ (void)setPeriodOnDate:(NSDate *)date length:(int)length {
    NSTimeInterval day = 1 * 24 * 60 * 60;
//    NSCalendar *calendar = [NSCalendar currentCalendar];
//    NSDateComponents *interval = [NSDateComponents new];
//    interval.day = length;
    length--;
    NSLog(@"day length: %i", length);
    NSTimeInterval startDate = [date timeIntervalSince1970];
//    NSTimeInterval endDate = [[calendar dateByAddingComponents:interval toDate:date options:0] timeIntervalSince1970];
    NSTimeInterval endDate = startDate + length * day;

    [self insertToPeriodWithStartDate:startDate endDate:endDate];
//    for (int i = 0; i < length; i++) {
//        interval.day = i;
//        NSTimeInterval entryDate = [[calendar dateByAddingComponents:interval toDate:date options:0] timeIntervalSince1970];
//        [self insertToJournalWithDate:entryDate];
//    }

}

+ (void)insertToPeriodWithStartDate:(NSTimeInterval)start endDate:(NSTimeInterval)end {
    NSMutableDictionary *values = [NSMutableDictionary dictionary];
    [values setObject:[NSString stringWithFormat:@"%.0f", start] forKey:@"startDate"];
    [values setObject:[NSString stringWithFormat:@"%.0f", end] forKey:@"endDate"];

    [[LASqlBase getSharedInstance] insertToTable:@"period" values:values];
}

+ (NSMutableDictionary *)getJournalsWithDate:(NSDate *)date {
    NSLog(@"get journal with date: %@", date);
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *interval = [NSDateComponents new];

    interval.day = -10;
    NSTimeInterval d1 = [[calendar dateByAddingComponents:interval toDate:date options:0] timeIntervalSince1970];
    interval.month = 1;
    interval.day = 10;
    NSTimeInterval d2 = [[calendar dateByAddingComponents:interval toDate:date options:0] timeIntervalSince1970];

    NSMutableArray *data = [[LASqlBase getSharedInstance] selectWithQuery:[NSString stringWithFormat:@"SELECT * FROM `journal` WHERE `date` BETWEEN %.0f AND %.0f ORDER BY `date` DESC;", d1, d2]];
    NSMutableDictionary *entry = [NSMutableDictionary dictionary];
    for (NSDictionary *d in data) {
        [entry setObject:d forKey:[NSString stringWithFormat:@"%@", [d objectForKey:@"date"]]];
    }
    return entry;
}

+ (NSMutableArray *)getFertilityDateFrom:(NSTimeInterval)startDate toInterval:(NSTimeInterval)endDate {
    NSMutableArray *data = [[LASqlBase getSharedInstance] selectWithQuery:[NSString stringWithFormat:@"SELECT * FROM `journal` WHERE `date` BETWEEN %.0f AND %.0f ORDER BY `date` DESC;", startDate, endDate]];
    NSMutableArray *entry = [NSMutableArray array];
    for (NSDictionary *d in data) {
        if ([d objectForKey:@"ovulated"] && ![@"0" isEqualToString:[d objectForKey:@"ovulated"]])
            [entry addObject:d];
    }
    return entry;
}

+ (NSMutableDictionary *)getSingleJournalWithDate:(NSDate *)date {
    NSLog(@"getSingleJournalWithDate")
    NSMutableArray *data = [[LASqlBase getSharedInstance] selectWithQuery:[NSString stringWithFormat:@"SELECT * FROM `journal` WHERE `date` = %@ ", [NSString stringWithFormat:@"%.0f", [date timeIntervalSince1970]]]];
    if (data.count > 0) {
        return [data lastObject];
    } else {
        NSMutableDictionary *empty = [NSMutableDictionary dictionary];
        [empty setObject:[NSNumber numberWithInt:(int) [date timeIntervalSince1970]] forKey:@"date"];
        return empty;
    }
}

+ (int)countJournalWithDate:(NSDate *)date {
    NSMutableArray *data = [[LASqlBase getSharedInstance] selectWithQuery:[NSString stringWithFormat:@"SELECT * FROM `journal` WHERE `date` = %@ ", [NSString stringWithFormat:@"%.0f", [date timeIntervalSince1970]]]];
    return data.count;
}

+ (NSMutableArray *)getMonthPeriodWithDate:(NSDate *)date {
//    NSLog(@"get journal with date: %@", date);
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *interval = [NSDateComponents new];

    interval.day = -10;
    NSTimeInterval d1 = [[calendar dateByAddingComponents:interval toDate:date options:0] timeIntervalSince1970];
    interval.month = 1;
    interval.day = 20;
    NSTimeInterval d2 = [[calendar dateByAddingComponents:interval toDate:date options:0] timeIntervalSince1970];

    NSMutableArray *data = [[LASqlBase getSharedInstance] selectWithQuery:[NSString stringWithFormat:@"SELECT * FROM `period` WHERE `startDate` BETWEEN %@ AND %@ ORDER BY `startDate` DESC", [NSString stringWithFormat:@"%.0f", d1], [NSString stringWithFormat:@"%.0f", d2]]];
//    NSLog(@"period data: %@", data);
    NSMutableArray *entry = [NSMutableArray array];
    for (NSDictionary *d in data) {
        [entry addObject:[NSString stringWithFormat:@"%@", [d objectForKey:@"startDate"]]];
    }
    return entry;
}

+ (int)getAverageCycleLength {
    NSMutableArray *periods = [[LASqlBase getSharedInstance] selectWithQuery:[NSString stringWithFormat:@"SELECT * FROM `period` ORDER BY `startDate` DESC LIMIT 0,%i", [PreferenceHandler getPeriodToAverage]]];
    int validPeriodLengthCount = 0;
    if (periods.count > 1 && [PreferenceHandler getIsUseAverage]) {
        int totalDay = 0;
        for (NSUInteger i = 1; i < periods.count; i++) {
            NSDictionary *lastPeriod = [periods objectAtIndex:i - 1];
            NSDictionary *period = [periods objectAtIndex:i];
            double ti1 = [[lastPeriod objectForKey:@"startDate"] doubleValue];
            double ti2 = [[period objectForKey:@"startDate"] doubleValue];
            int length = ABS([LAFunctions getDaysBetweenInterval:ti1 :ti2]);
            if (length < [PreferenceHandler getIgnoreCycleBeyond]) {
                validPeriodLengthCount++;
                totalDay += length;
            }
        }
        return totalDay / validPeriodLengthCount;
    }
    else {
        return [PreferenceHandler getDefaultCycleLength];
    }
}

+ (int)getAveragePeriodLength {
    NSMutableArray *periods = [[LASqlBase getSharedInstance] selectWithQuery:[NSString stringWithFormat:@"SELECT * FROM `period` ORDER BY `startDate` DESC LIMIT 0,%i", [PreferenceHandler getPeriodToAverage]]];
    if (periods.count > 0 && [PreferenceHandler getIsUseAverage]) {
        int totalDay = 0;
        for (NSUInteger i = 0; i < periods.count; i++) {
            NSDictionary *period = [periods objectAtIndex:i];
            double start = [[period objectForKey:@"startDate"] doubleValue];
            double end = [[period objectForKey:@"endDate"] doubleValue];
            int length = [LAFunctions getDaysBetweenInterval:start :end] + 1;
            NSLog(@"adding: %i", length);
            totalDay += ABS(length);
        }
        return (totalDay + periods.count - 1) / periods.count;
    }
    else {
        return [PreferenceHandler getDefaultPeriodLength];
    }
}

+ (NSArray *)getJournalWeights {
    NSMutableArray *data = [[LASqlBase getSharedInstance] selectWithQuery:[NSString stringWithFormat:@"SELECT `date`,`weight`,`temp` FROM `journal` WHERE `weight` <> '0' OR `temp` <> '0' ORDER BY `date` ASC "]]; // WHERE `date` BETWEEN %@ AND %@ ORDER BY `date` DESC;", [NSString stringWithFormat:@"%.0f", d1], [NSString stringWithFormat:@"%.0f", d2]]];
    return data;
}

+ (NSTimeInterval)getLastPeriod {
    NSMutableDictionary *data = [[LASqlBase getSharedInstance] selectSingleDataWithQuery:@"SELECT `startDate`, COUNT(`startDate`) as 'count' FROM `period` ORDER BY `startDate` DESC LIMIT 0,1"];
//    NSLog(@"last period data: %@", data);
    if (data.count > 0)
        return [[data objectForKey:@"startDate"] doubleValue];
    else
        return 0;
}

+ (NSTimeInterval)getFirstPeriod {
    NSMutableDictionary *data = [[LASqlBase getSharedInstance] selectSingleDataWithQuery:@"SELECT `startDate` FROM `period` ORDER BY `startDate` ASC LIMIT 0,1"];
//    NSLog(@"last period data: %@", data);
    if (data.count > 0)
        return [[data objectForKey:@"startDate"] doubleValue];
    else
        return 0;
}

+ (NSDictionary *)getPeriodRangeOnDate:(NSDate *)date {
    NSMutableDictionary *data = [[LASqlBase getSharedInstance] selectSingleDataWithQuery:[NSString stringWithFormat:@"SELECT * FROM `period` WHERE"
                                                                                                                            "`startDate` <= %.0f AND"
                                                                                                                            "`endDate` >= %.0f", [date timeIntervalSince1970], [date timeIntervalSince1970]]];
    if (data.count > 0)
        return data;
    else
        return nil;
}

+ (void)updateJournalFlow:(int)flow date:(NSDate *)date {
    NSMutableDictionary *journal = [self getSingleJournalWithDate:date];
    if (journal != nil) {
        [journal setObject:[NSString stringWithFormat:@"%i", flow] forKey:@"flow"];
        [self insertOrUpdateJournalWithNewJournal:journal];
    }
}

+ (void)insertOrUpdateJournalWithNewJournal:(NSMutableDictionary *)journal {
    int j = [self countJournalWithDate:[NSDate dateWithTimeIntervalSince1970:[[journal objectForKey:@"date"] intValue]]];
    if (j > 0) {
        NSMutableString *query = [NSMutableString string];
        [query appendString:@"UPDATE `journal` SET"];

        NSMutableArray *setter = [NSMutableArray array];
        NSArray *keys = journal.allKeys;
//        NSLog(@"update with keys: %@", keys);
        for (NSString *key in keys) {
            if (![@"date" isEqualToString:key]) {
                [setter addObject:[NSString stringWithFormat:@"`%@` = '%@'", key, [journal objectForKey:key]]];
            }
        }
        [query appendString:[setter componentsJoinedByString:@","]];
        [query appendFormat:@" WHERE `date` = %@", [journal objectForKey:@"date"]];
        [[LASqlBase getSharedInstance] runQuery:query];
    } else {
        [[LASqlBase getSharedInstance] insertToTable:@"journal" values:journal];
    }
}


+ (NSMutableArray *)getAllJournalsCount:(int)i {
    NSMutableArray *data = [[LASqlBase getSharedInstance] selectWithQuery:[NSString stringWithFormat:@"SELECT * FROM `journal` \n"
                                                                                                             "WHERE `flow` <> 0 \n"
                                                                                                             "OR `spotting` <> 0 \n"
                                                                                                             "OR `intimate` <> 0 \n"
                                                                                                             "OR `mood` <> 0 \n"
                                                                                                             "OR `weight` <> 0 \n"
                                                                                                             "OR `temp` <> 0 \n"
                                                                                                             "OR `ovulated` <> 0 \n"
                                                                                                             "OR `numSymptoms` <> 0 \n"
                                                                                                             "OR `notes` <> '' \n"
                                                                                                             "ORDER BY `date` DESC \n"
                                                                                                             "LIMIT 0,%i", i]];
    return data;
}

+ (NSMutableArray *)getAllSymptoms {
    NSMutableArray *data = [[LASqlBase getSharedInstance] selectWithQuery:[NSString stringWithFormat:@"SELECT * FROM `symptoms_type` ORDER BY `description` ASC"]];
    return data;
}

+ (NSMutableArray *)getAllSymptomsWithDate:(NSTimeInterval)date {
    NSMutableArray *data = [[LASqlBase getSharedInstance] selectWithQuery:[NSString stringWithFormat:
            @"SELECT `t`.*, `s`.`value`\n"
                    "FROM   `symptoms_type` as `t`\n"
                    "LEFT JOIN\n"
                    "(SELECT * FROM `symptoms` WHERE `date` = %.0f ) as `s`\n"
                    "ON `t`.`symptoms_id` = `s`.`symptoms_id`", date]];
    return data;
}

+ (void)removePeriodOnRange:(NSDictionary *)period {
    NSString *query = [NSString stringWithFormat:@"DELETE FROM `period` WHERE `startDate` = %@ AND `endDate` = %@;",
                                                 [period objectForKey:@"startDate"], [period objectForKey:@"endDate"]];
    [[LASqlBase getSharedInstance] runQuery:query];
}

+ (void)updatePeriodOnRange:(NSDictionary *)period endDate:(NSDate *)date {
    NSString *query = [NSString stringWithFormat:@"UPDATE `period` SET `endDate` = %.0f WHERE `startDate` = %@;",
                                                 [date timeIntervalSince1970], [period objectForKey:@"startDate"]];
    [[LASqlBase getSharedInstance] runQuery:query];
}

+ (NSUInteger)setSymptoms:(NSMutableArray *)symptoms forDate:(NSTimeInterval)date {

    NSUInteger symptomsCount = 0;

    [[LASqlBase getSharedInstance] runQuery:[NSString stringWithFormat:@"DELETE FROM `symptoms` WHERE `date` = %f", date]];
    for (NSMutableDictionary *symptom in symptoms) {
        if ([symptom objectForKey:@"value"] && (0 != [[symptom objectForKey:@"value"] intValue]) && ![@"" isEqualToString:[symptom objectForKey:@"value"]]) {
            [symptom removeObjectForKey:@"description"];
            [symptom setObject:[NSNumber numberWithDouble:date] forKey:@"date"];
            [[LASqlBase getSharedInstance] insertToTable:@"symptoms" values:symptom];
            symptomsCount++;
        }
    }

    return symptomsCount;
}

@end