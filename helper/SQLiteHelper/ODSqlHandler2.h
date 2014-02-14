//
// Created by Tek Yin Kwee on 12/10/13.
// Copyright (c) 2013 vBox. All rights reserved.
//


#import <Foundation/Foundation.h>


@interface ODSqlHandler2 : NSObject

+ (void)createDatabaseWithDbName:(NSString *)dbName;

+ (void)putNotificationWithId:(int)id1 Text:(NSString *)text type:(int)type offset:(int)offset enabled:(bool)enabled hour:(int)hour minute:(int)minute;

+ (NSMutableArray *)getNotificationWithType:(int)type;

+ (void)resetData;

+ (void)defaultValues;

+ (void)setPeriodOnDate:(NSDate *)date length:(int)length;

+ (NSMutableDictionary *)getJournalsWithDate:(NSDate *)date;

+ (NSMutableDictionary *)getSingleJournalWithDate:(NSDate *)date;

+ (NSMutableArray *)getMonthPeriodWithDate:(NSDate *)date;

+ (int)getAverageCycleLength;

+ (int)getAveragePeriodLength;

+ (NSArray *)getJournalWeights;

+ (double)getLastPeriod;

+ (NSTimeInterval)getFirstPeriod;

+ (NSDictionary *)getPeriodRangeOnDate:(NSDate *)date;

+ (void)updateJournalFlow:(int)flow date:(NSDate *)date;

+ (void)insertOrUpdateJournalWithNewJournal:(NSMutableDictionary *)journal;

+ (NSMutableArray *)getAllJournalsCount:(int)i;

+ (NSMutableArray *)getAllSymptoms;

+ (NSMutableArray *)getAllSymptomsWithDate:(NSTimeInterval)date;

+ (void)removePeriodOnRange:(NSDictionary *)period;

+ (void)updatePeriodOnRange:(NSDictionary *)period endDate:(NSDate *)date;

+ (NSUInteger)setSymptoms:(NSMutableArray *)symptoms forDate:(NSTimeInterval)date;

+ (NSMutableArray *)getFertilityDateFrom:(NSTimeInterval)startDate toInterval:(NSTimeInterval)endDate;

@end