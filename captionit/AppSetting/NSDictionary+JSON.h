//
//  NSDictionary+JSON.h
//  SmoothPay2.0
//
//  Created by Alex on 11/12/15.
//  Copyright (c) 2015 BCL. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (JSON)

+ (nullable id) jsonFromString:(nullable NSString *)strJson;
+ (nullable id) jsonFromData:(nullable NSData *)data;

- (nullable NSString *) toJsonString;

- (nullable id) optObject:(nonnull NSString *)key;
- (nullable id) optObject:(nonnull NSString *)key default:(nullable id)defval;
- (nullable NSArray *) optArray:(nonnull NSString *)key;
- (nullable NSArray *) optArray:(nonnull NSString *)key default:(nullable NSArray *)defval;
- (NSInteger) optInt:(nonnull NSString *)key default:(NSInteger)defval;
- (BOOL) optBool:(nonnull NSString *)key default:(BOOL)defval;
- (double) optDouble:(nonnull NSString *)key default:(double)defval;
- (nullable NSString *) optString:(nonnull NSString *)key;
- (nullable NSString *) optString:(nonnull NSString *)key default:(nullable NSString *)defval;

@end
