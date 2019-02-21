//
//  APT2JSON.h
//  Incidious
//
//  Created by The Ignition Team on 17/2/19.
//  Copyright © 2019 Ignition. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface APT2JSON : NSObject
- (NSString *)file_get_contents_cydia:(NSString *)url;
- (BOOL)download_as_cydia:(NSString *)url location:(NSString *)location;
- (BOOL)startsWith:(NSString *)haystack needle:(NSString *)needle;
- (BOOL)endsWith:(NSString *)haystack needle:(NSString *)needle;
- (NSString *)exists:(NSString *)url;
- (BOOL)strpos:(NSString *)haystack needle:(NSString *)needle;
- (NSMutableArray *)splitAt:(NSString *)string delimiter:(NSString *)delimiter;
- (NSMutableArray *)packagesToArray:(NSString *)packages;
- (NSMutableArray *)splitPackages:(NSMutableArray *)packages url:(NSString *)url;
- (NSMutableArray *)splitAt_a:(NSString *)haystack needle:(NSString *)needle;
- (NSMutableArray *)splitReleaseToArray:(NSString *)release;
- (NSMutableArray *)splitRelease:(NSMutableArray *)release;
- (BOOL)vp:(NSString *)str;
- (BOOL)vr:(NSString *)str;
- (NSString *)randomStringWithLength:(int)len;
-(void)createDirectory:(NSString *)directoryName atFilePath:(NSString *)filePath;
- (BOOL)doesFileExist:(NSString *)filePath;
- (NSString *)readFile:(NSString *)filePath;
- (NSString *)preg_replace:(NSString *)pattern string:(NSString *)string replacement:(NSString *)replacement;
- (NSString *)dirname:(NSString *)path;
- (NSMutableArray *)packages:(NSString *)url;
- (NSString *)repoIcon:(NSString *)url;
- (NSMutableArray *)release:(NSString *)url;
- (NSMutableArray *)msort:(NSMutableArray *)array key:(NSString *)key;
- (NSString *)convertRepo:(NSString *)url;
@end

NS_ASSUME_NONNULL_END
