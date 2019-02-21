//
//  APT2JSON.m
//  Incidious
//
//  Created by The Ignition Team on 17/2/19.
//  Copyright © 2019 Ignition. All rights reserved.
//

#import "APT2JSON.h"
#include <AFNetworking/AFNetworking.h>
#include <ArchiveFile.h>

@implementation APT2JSON

- (NSString *)file_get_contents_cydia:(NSString *)url {
    __block NSString *response;
    
        AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
        [manager.requestSerializer setValue:@"iPhone10,3" forHTTPHeaderField:@"X-Machine"];
        [manager.requestSerializer setValue:@"ABCDEF1234567890ABCDEF1234567890ABCDEF12" forHTTPHeaderField:@"X-Unique-ID"];
        [manager.requestSerializer setValue:@"12.1.2" forHTTPHeaderField:@"X-Firmware"];
        [manager.requestSerializer setValue:@"Telesphoreo APT-HTTP/1.0.592" forHTTPHeaderField:@"User-Agent"];
    
        [manager GET:url parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        
            response = responseObject;
            
        } failure:^(NSURLSessionTask *operation, NSError *error) {
            NSLog(@"Error: %@", error);
        }];
    
    return response;
}

- (BOOL)download_as_cydia:(NSString *)url location:(NSString *)location {
    __block BOOL r = NO;
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    [manager.requestSerializer setValue:@"iPhone10,3" forHTTPHeaderField:@"X-Machine"];
    [manager.requestSerializer setValue:@"ABCDEF1234567890ABCDEF1234567890ABCDEF12" forHTTPHeaderField:@"X-Unique-ID"];
    [manager.requestSerializer setValue:@"12.1.2" forHTTPHeaderField:@"X-Firmware"];
    [manager.requestSerializer setValue:@"Telesphoreo APT-HTTP/1.0.592" forHTTPHeaderField:@"User-Agent"];
    
    NSURL *URL = [NSURL URLWithString:url];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        NSURL *tmpDirectory = [NSURL URLWithString:@"/tmp/"];
        return [tmpDirectory URLByAppendingPathComponent:location];
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        if (error) {
            r = NO;
        } else {
            r = YES;
        }
    }];
    [downloadTask resume];
    
    return r;
}

- (BOOL)startsWith:(NSString *)haystack needle:(NSString *)needle {
    if([haystack hasPrefix:needle]) {
        return YES;
    }
    return NO;
}

- (BOOL)endsWith:(NSString *)haystack needle:(NSString *)needle {
    if([haystack hasSuffix:needle]) {
        return YES;
    }
    return NO;
}

- (NSString *)exists:(NSString *)url {
    __block NSString *response;
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    [manager.requestSerializer setValue:@"iPhone10,3" forHTTPHeaderField:@"X-Machine"];
    [manager.requestSerializer setValue:@"ABCDEF1234567890ABCDEF1234567890ABCDEF12" forHTTPHeaderField:@"X-Unique-ID"];
    [manager.requestSerializer setValue:@"12.1.2" forHTTPHeaderField:@"X-Firmware"];
    [manager.requestSerializer setValue:@"Telesphoreo APT-HTTP/1.0.592" forHTTPHeaderField:@"User-Agent"];
    
    [manager GET:url parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        
        response = url;
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        response = @"NO";
    }];
    
    return response;
}

- (BOOL)strpos:(NSString *)haystack needle:(NSString *)needle {
    if ([haystack rangeOfString:needle].location == NSNotFound) {
        return NO;
    } else {
        return YES;
    }
}

- (NSMutableArray *)splitAt:(NSString *)string delimiter:(NSString *)delimiter {
    NSRange rangeOfDelimiter = [string rangeOfString:delimiter];
    NSString *key = rangeOfDelimiter.location == NSNotFound ? string : [string substringToIndex:rangeOfDelimiter.location];
    NSString *value = rangeOfDelimiter.location == NSNotFound ? nil :[string substringFromIndex:rangeOfDelimiter.location + 1];
    
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    [arr addObject:key];
    [arr addObject:value];
    
    return arr;
}

- (NSMutableArray *)packagesToArray:(NSString *)packages {
    NSMutableArray *packagesArray = [[packages componentsSeparatedByString: @"\n\n"] mutableCopy];
    
    for (int i = 0; i < [packagesArray count]; i++) {
        if ([packagesArray[i] isEqual: @""]) {
            [packagesArray removeObjectAtIndex:i];
        }
    }
    
    return packagesArray;
}

- (NSMutableArray *)splitPackages:(NSMutableArray *)packages url:(NSString *)url {
    NSString *prev = @"";
    
    for (int i = 0; i < [packages count]; i++) {
        NSMutableArray *a = [[NSMutableArray alloc] init];
        [[[packages objectAtIndex:i] componentsSeparatedByString:@"\n"] mutableCopy];
        NSMutableArray *arr = [[NSMutableArray alloc] init];
        for (int ii = 0; ii < [a count]; ii++) {
            NSString *str = [a objectAtIndex:ii];
            NSMutableArray *arr_ = [self splitAt:str delimiter:@":"];
            if (arr_ == false && ![prev isEqual: @""] && ii != 0 && ![str isEqual: @""]) {
                [arr setValue:[NSString stringWithFormat:@"%@\n%@", [arr valueForKey:prev], str] forKey:prev];
            }
            if (arr_ != false) {
                prev = [arr_ objectAtIndex:0];
                NSString *keyName = [[[arr_ objectAtIndex:0] lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
                NSString *keyValue = [[arr_ objectAtIndex:1] stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
                
                if ([keyName isEqual:@"filename"] && [keyValue rangeOfString:@"://"].location == NSNotFound) {
                    keyValue = [NSString stringWithFormat:@"%@/%@", url, keyValue];
                } else if ([keyName isEqual:@"filename"] && [keyValue rangeOfString:@"//"].location != NSNotFound) {
                    keyValue = [NSString stringWithFormat:@"http:%@", keyValue];
                }
                [arr setValue:keyValue forKey:keyName];
            }
        }
        [packages setObject:arr atIndexedSubscript:i];
    }
    
    return packages;
}

- (NSMutableArray *)splitAt_a:(NSString *)haystack needle:(NSString *)needle {
    if ([haystack rangeOfString:needle].location == NO) {
        NSMutableArray *arr = [[NSMutableArray alloc] init];
        [arr setObject:@"NO" atIndexedSubscript:0];
        return [arr objectAtIndex:0];
    }
    
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    int index = 0;
    
    NSMutableArray *haystackArray = [NSMutableArray array];
    for (int i = 0; i < [haystack length]; i++) {
        NSString *ch = [haystack substringWithRange:NSMakeRange(i, 1)];
        [haystackArray addObject:ch];
    }
    
    for (int i = 0; i < haystack.length; i++) {
        if ([[haystackArray objectAtIndex:i] isEqual:needle]) {
            index++;
        } else {
            [arr setObject:[haystackArray objectAtIndex:i] atIndexedSubscript:index];
        }
    }
    
    return arr;
}

- (NSMutableArray *)splitReleaseToArray:(NSString *)release {
    NSMutableArray *arr = [[release componentsSeparatedByString:@"\n"] mutableCopy];
    
    return arr;
}

- (NSMutableArray *)splitRelease:(NSMutableArray *)release {
    NSMutableArray *release_ = [[NSMutableArray alloc] init];
    NSString *prev = @"";
    
    for (int i = 0; i < [release count]; i++) {
        NSString *add = [release objectAtIndex:i];
        NSString *str = [NSString stringWithFormat:@"%@", add];
        NSMutableArray *arr_ = [self splitAt:str delimiter:@":"];
        
        if (arr_ != false) {
            [release_ setValue:[arr_[1] stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]] forKey:[arr_[0] stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]]];
            prev = [arr_[0] stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        } else if (![str isEqual: @""]) {
            [release_ setValue:[NSString stringWithFormat:@"\n%@", str] forKey:prev];
            [release_ setValue:[NSString stringWithFormat:@"%@", [[release_ valueForKey:prev] stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]]] forKey:prev];
        }
        
        for (NSString *str in release_) {
            if ([str rangeOfString:@"\n"].location != NSNotFound) {
                NSMutableArray *strArray = [self splitAt_a:str needle:@"\n"];
                for (int i = 0; i < [strArray count]; i++) {
                    [strArray setObject:[[strArray objectAtIndex:i] stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]] atIndexedSubscript:i];
                }
            }
        }
    }
    
    return release_;
}

- (BOOL)vp:(NSString *)str {
    if (str != NO) {
        if ([self endsWith:[str lowercaseString] needle:[@"/Packages" lowercaseString]] || [self endsWith:[str lowercaseString] needle:[@"/Packages.gz" lowercaseString]] || [self endsWith:[str lowercaseString] needle:[@"/Packages.bz2" lowercaseString]]) {
            return YES;
        } else {
            return NO;
        }
    }
    return NO;
}

- (BOOL)vr:(NSString *)str {
    if (str != NO && [self endsWith:[str lowercaseString] needle:[@"/Release" lowercaseString]]) {
        return YES;
    }
    return NO;
}

- (NSString *)randomStringWithLength:(int)len {
    
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    
    for (int i=0; i<len; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random_uniform([letters length])]];
    }
    
    return randomString;
}

-(void)createDirectory:(NSString *)directoryName atFilePath:(NSString *)filePath {
    NSString *filePathAndDirectory = [filePath stringByAppendingPathComponent:directoryName];
    NSError *error;
    
    if (![[NSFileManager defaultManager] createDirectoryAtPath:filePathAndDirectory withIntermediateDirectories:NO attributes:nil error:&error]) {
        NSLog(@"Create directory error: %@", error);
    } else {
        [[NSFileManager defaultManager] setAttributes:@{NSFilePosixPermissions: @0777} ofItemAtPath:filePathAndDirectory error:&error];
    }
}

- (BOOL)doesFileExist:(NSString *)filePath {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:filePath]){
        return YES;
    } else {
        return NO;
    }
}

- (NSString *)readFile:(NSString *)filePath {
    NSError *error;
    NSString *fileContents = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
    
    if (error) {
        NSLog(@"Error reading file: %@", error.localizedDescription);
        return @"Error";
    }
    
    return fileContents;
}

- (NSString *)preg_replace:(NSString *)pattern string:(NSString *)string replacement:(NSString *)replacement {
//    NSCharacterSet *doNotWant = [NSCharacterSet characterSetWithCharactersInString:pattern];
//    string = [[string componentsSeparatedByCharactersInSet: doNotWant] componentsJoinedByString: @""];
//    return string;
//
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
    NSString *modifiedString = [regex stringByReplacingMatchesInString:string options:0 range:NSMakeRange(0, [string length]) withTemplate:replacement];
    return modifiedString;
}

- (NSString *)dirname:(NSString *)path {
    NSString *dirName = [path stringByDeletingLastPathComponent];
    return dirName;
}

- (NSMutableArray *)packages:(NSString *)url {
    NSMutableArray *packages;
    
    BOOL found = NO;
    
    NSString *lowerURL = [url lowercaseString];
    
    NSMutableArray *knownPackageFiles = [[NSMutableArray alloc] init];
    [knownPackageFiles addObject:@"/Packages"];
    [knownPackageFiles addObject:@"/Packages.gz"];
    [knownPackageFiles addObject:@"/Packages.bz2"];
    [knownPackageFiles addObject:@"/dists/stable/main/binary-iphoneos-arm/Packages"];
    [knownPackageFiles addObject:@"/dists/stable/main/binary-iphoneos-arm/Packages.gz"];
    [knownPackageFiles addObject:@"/dists/stable/main/binary-iphoneos-arm/Packages.bz2"];
    
    if ([self vp:lowerURL]) {
        NSString *packagesFile = url;
        
        NSString *e = [self exists:packagesFile];
        if ([self vp:e]) {
            found = YES;
        }
    }
    
    if (!found) {
        NSString *packagesFile = [NSString stringWithFormat:@"%@%@", url, knownPackageFiles[0]];
        
        NSString *e = [self exists:packagesFile];
        
        if ([self vp:e]) {
            found = YES;
            url = packagesFile;
            lowerURL = [packagesFile lowercaseString];
        }
    }
    
    if (!found) {
        NSString *packagesFile = [NSString stringWithFormat:@"%@%@", url, knownPackageFiles[1]];
        
        NSString *e = [self exists:packagesFile];
        
        if ([self vp:e]) {
            found = YES;
            url = packagesFile;
            lowerURL = [packagesFile lowercaseString];
        }
    }
    
    if (!found) {
        NSString *packagesFile = [NSString stringWithFormat:@"%@%@", url, knownPackageFiles[2]];
        
        NSString *e = [self exists:packagesFile];
        
        if ([self vp:e]) {
            found = YES;
            url = packagesFile;
            lowerURL = [packagesFile lowercaseString];
        }
    }
    
    if (!found) {
        NSString *packagesFile = [NSString stringWithFormat:@"%@%@", url, knownPackageFiles[3]];
        
        NSString *e = [self exists:packagesFile];
        
        if ([self vp:e]) {
            found = YES;
            url = packagesFile;
            lowerURL = [packagesFile lowercaseString];
        }
    }
    
    if (!found) {
        NSString *packagesFile = [NSString stringWithFormat:@"%@%@", url, knownPackageFiles[4]];
        
        NSString *e = [self exists:packagesFile];
        
        if ([self vp:e]) {
            found = YES;
            url = packagesFile;
            lowerURL = [packagesFile lowercaseString];
        }
    }
    
    if (!found) {
        NSString *packagesFile = [NSString stringWithFormat:@"%@%@", url, knownPackageFiles[5]];
        
        NSString *e = [self exists:packagesFile];
        
        if ([self vp:e]) {
            found = YES;
            url = packagesFile;
            lowerURL = [packagesFile lowercaseString];
        }
    }
    
    __block NSString *file = @"";
    
    if ([self endsWith:lowerURL needle:@"packages.bz2"]) {
        // Packages.bz2 extract using libarchive!
        NSString *random = [self randomStringWithLength:40];
        
        if ([self download_as_cydia:url location:[NSString stringWithFormat:@"%@.bz2", random]]) {
            // YAY it downloaded
            NSPipe *pipe = [NSPipe pipe];
            if (pipe == nil) {
                NSLog(@"Unable to make a pipe!");
            } else {
                NSString *bz2Path = [NSString stringWithFormat:@"/tmp/%@.bz2", random];
                ArchiveFile *bz2Extractor = [ArchiveFile archiveWithFile:bz2Path];
                
                if (bz2Extractor == nil) {
                    NSLog(@"Failed at bz2 extraction.");
                } else {
                    
                    NSLog(@"Extracting %@", bz2Path);
                    dispatch_queue_t extractionQueue = dispatch_queue_create(NULL, NULL);
                    dispatch_async(extractionQueue, ^{
                        [self createDirectory:random atFilePath:@"/tmp/"];
                        [bz2Extractor extractToPath:[NSString stringWithFormat:@"/tmp/%@", random]];
                        if ([self doesFileExist:[NSString stringWithFormat:@"/tmp/%@/Packages", random]]) {
                            file = [self readFile:[NSString stringWithFormat:@"/tmp/%@/Packages", random]];
                        }
                    });
                }
            }
        } else {
            
        }
    } else if ([self endsWith:lowerURL needle:@"packages.gz"]) {
        // Packages.gz extract using libarchive!
        NSString *random = [self randomStringWithLength:40];
        
        if ([self download_as_cydia:url location:[NSString stringWithFormat:@"%@.gz", random]]) {
            // YAY it downloaded
            NSPipe *pipe = [NSPipe pipe];
            if (pipe == nil) {
                NSLog(@"Unable to make a pipe!");
            } else {
                NSString *gzPath = [NSString stringWithFormat:@"/tmp/%@.gz", random];
                ArchiveFile *gzExtractor = [ArchiveFile archiveWithFile:gzPath];
                
                if (gzExtractor == nil) {
                    NSLog(@"Failed at gz extraction.");
                } else {
                    
                    NSLog(@"Extracting %@", gzPath);
                    dispatch_queue_t extractionQueue = dispatch_queue_create(NULL, NULL);
                    dispatch_async(extractionQueue, ^{
                        [self createDirectory:random atFilePath:@"/tmp/"];
                        [gzExtractor extractToPath:[NSString stringWithFormat:@"/tmp/%@", random]];
                        if ([self doesFileExist:[NSString stringWithFormat:@"/tmp/%@/Packages", random]]) {
                            file = [self readFile:[NSString stringWithFormat:@"/tmp/%@/Packages", random]];
                        }
                    });
                }
            }
        } else {
            // Oh Shit
        }
    } else if ([self endsWith:lowerURL needle:@"packages"]) {
        // Packages pre-extracted <3 this repo!
        NSString *random = [self randomStringWithLength:40];
        
        if ([self download_as_cydia:url location:[NSString stringWithFormat:@"%@.pkgs", random]]) {
            // YAY it downloaded
            NSPipe *pipe = [NSPipe pipe];
            if (pipe == nil) {
                NSLog(@"Unable to make a pipe!");
            } else {
                if ([self doesFileExist:[NSString stringWithFormat:@"/tmp/%@.pkgs", random]]) {
                    file = [self readFile:[NSString stringWithFormat:@"/tmp/%@.pkgs", random]];
                }
            }
        }
    }
    
    file = [self preg_replace:@"[\x00-\x08\x10\x0B\x0C\x0E-\x19\x7F]|[\x00-\x7F][\x80-\xBF]+|([\xC0\xC1]|[\xF0-\xFF])[\x80-\xBF]*|[\xC2-\xDF]((?![\x80-\xBF])|[\x80-\xBF]{2,})|[\xE0-\xEF](([\x80-\xBF](?![\x80-\xBF]))|(?![\x80-\xBF]{2})|[\x80-\xBF]{3,})" string:file replacement:@"?"];
    
    file = [self preg_replace:@"\xE0[\x80-\x9F][\x80-\xBF]|\xED[\xA0-\xBF][\x80-\xBF]" string:file replacement:@"?"];
    
    packages = [self packagesToArray:file];
    packages = [self splitPackages:packages url:[self dirname:url]];
    
    return packages;
}

- (NSString *)repoIcon:(NSString *)url {
    if ([url isEqual:@"http://repo.packix.com"] || [url isEqual:@"https://repo.packix.com"] || [url isEqual:@"http://repo.packix.com/"] || [url isEqual:@"https://repo.packix.com/"]) {
        return @"https://pbs.twimg.com/profile_images/1046836237192040449/54RYzohk_400x400.jpg";
    }
    
    NSString *lowerurl = [url lowercaseString];
    
    BOOL found = NO;
    
    NSMutableArray *knownRepoIcons = [[NSMutableArray alloc] init];
    [knownRepoIcons addObject:@"/CydiaIcon.png"];
    [knownRepoIcons addObject:@"/CydiaIcon.jpg"];
    [knownRepoIcons addObject:@"/CydiaIcon.bmp"];
    [knownRepoIcons addObject:@"/CydiaIcon.gif"];
    [knownRepoIcons addObject:@"/dists/stable/CydiaIcon.png"];
    [knownRepoIcons addObject:@"/dists/stable/CydiaIcon.png"];
    [knownRepoIcons addObject:@"/dists/stable/CydiaIcon.bmp"];
    [knownRepoIcons addObject:@"/dists/stable/CydiaIcon.gif"];
    [knownRepoIcons addObject:@"/CydiaIcon2.png"];
    [knownRepoIcons addObject:@"/CydiaIcon2.jpg"];
    [knownRepoIcons addObject:@"/CydiaIcon2.bmp"];
    [knownRepoIcons addObject:@"/CydiaIcon2.gif"];
    [knownRepoIcons addObject:@"/dists/stable/CydiaIcon2.png"];
    [knownRepoIcons addObject:@"/dists/stable/CydiaIcon2.png"];
    [knownRepoIcons addObject:@"/dists/stable/CydiaIcon2.bmp"];
    [knownRepoIcons addObject:@"/dists/stable/CydiaIcon2.gif"];
    
    if ([self exists:url]) {
        for (NSString *iconPath in knownRepoIcons) {
            NSString *iconFile = [NSString stringWithFormat:@"%@%@", url, iconPath];
            
            NSString *e = [self exists:iconFile];
            
            if ([e isEqual:iconPath]) {
                found = YES;
                url = iconFile;
                lowerurl = [iconFile lowercaseString];
                break;
            }
        }
    }
    
    if (!found) {
        url = @"https://ignition.fun/InsidiousIcon.png";
    }
    
    return url;
}

- (NSMutableArray *)release:(NSString *)url {
    NSString *lowerurl = [url lowercaseString];
    BOOL found = NO;
    NSMutableArray *release = [[NSMutableArray alloc] init];
    NSString *file = @"";
    
    NSMutableArray *knownReleases = [[NSMutableArray alloc] init];
    [knownReleases addObject:@"/Release"];
    [knownReleases addObject:@"/dists/stable/Release"];
    
    if ([self exists:url]) {
        for (NSString *releasePath in knownReleases) {
            NSString *releaseFile = [NSString stringWithFormat:@"%@%@", url, releasePath];
            
            NSString *e = [self exists:releaseFile];
            
            if ([self vr:e]) {
                found = YES;
                url = releaseFile;
                lowerurl = [releaseFile lowercaseString];
                break;
            }
        }
    }
    
    if (found && [self endsWith:lowerurl needle:@"/release"]) {
        NSString *content = [self file_get_contents_cydia:url];
        if (content == NULL) {
            // Did the file like just get deleted? Tf?
        } else {
            file = content;
        }
    }
    
    file = [self preg_replace:@"[\x00-\x08\x10\x0B\x0C\x0E-\x19\x7F]|[\x00-\x7F][\x80-\xBF]+|([\xC0\xC1]|[\xF0-\xFF])[\x80-\xBF]*|[\xC2-\xDF]((?![\x80-\xBF])|[\x80-\xBF]{2,})|[\xE0-\xEF](([\x80-\xBF](?![\x80-\xBF]))|(?![\x80-\xBF]{2})|[\x80-\xBF]{3,})" string:file replacement:@"?"];
    
    file = [self preg_replace:@"\xE0[\x80-\x9F][\x80-\xBF]|\xED[\xA0-\xBF][\x80-\xBF]" string:file replacement:@"?"];
    
    release = [self splitReleaseToArray:file];
    release = [self splitRelease:release];
    [release setValue:[self repoIcon:url] forKey:@"Icon"];
    return release;
}

- (NSMutableArray *)msort:(NSMutableArray *)array key:(NSString *)key {
    NSString *sort_flags = @"SORT_REGULAR";
    if ([array count] > 0) {
        if ([key length] == 0) {
            NSMutableArray *mapping = [[NSMutableArray alloc] init];
            
            for (id key in array) {
                id value = [array valueForKey:key];
                NSString *sort_key = @"";
                if (![key isKindOfClass:[NSMutableArray class]]) {
                    sort_key = [NSString stringWithFormat:@"%@%@", sort_key, [value valueForKey:key]];
                } else {
                    // @TODO This should be fixed, now it will be sorted as string
                    for (id key_key in key) {
                        sort_key = [NSString stringWithFormat:@"%@%@", sort_key, [value valueForKey:key_key]];
                    }
                    sort_flags = @"SORT_STRING";
                }
                [mapping setValue:key forKey:sort_key];
            }
            
            // Finish function. Here's the PHP in case someone wants to do it. This function is defunct anyways
            /*
                asort($mapping, $sort_flags);
                $sorted = array();
                foreach ($mapping as $k => $v) {
                    $sorted[] = $array[$k];
                }
                return $sorted;
            */
        }
    }
    
    return array;
}

- (NSString *)convertRepo:(NSString *)url {
    NSMutableArray *pkgarr = [[NSMutableArray alloc] init];
    
    NSMutableArray *json = [[NSMutableArray alloc] init];
    
    NSMutableArray *_p = [[NSMutableArray alloc] init];
    NSMutableArray *p = [self packages:url];
    if (![p isKindOfClass:[NSString class]]) {
        [_p setObject:p atIndexedSubscript:0];
    } else {
        // Die...
    }
    
    NSMutableArray *packages = [[NSMutableArray alloc] init];
    
    for (id package_key in _p) {
        id package = [_p valueForKey:package_key];
        if ([packages valueForKey:[package valueForKey:@"package"]]) {
            [[[packages valueForKey:[package valueForKey:@"package"]] valueForKey:@"versions"] addObject:[package valueForKey:@"version"]];
            NSMutableArray *debArray = [[NSMutableArray alloc] init];
            [debArray setValue:[NSString stringWithFormat:@"%@/%@", url, [package valueForKey:@"filename"]] forKey:[package valueForKey:@"version"]];
            [debArray setValue:[package valueForKey:@"version"] forKey:@"version"];
            [debArray setValue:[NSString stringWithFormat:@"%@/%@", url, [package valueForKey:@"filename"]] forKey:@"deb"];
            [[[packages valueForKey:[package valueForKey:@"package"]] valueForKey:@"debs"] addObject:debArray];
        } else {
            NSMutableArray *pkg = [[NSMutableArray alloc] init];
            for (id p_key in package) {
                id p = [p_key valueForKey:package];
                if ([p_key isEqual:@"version"]) {
                    [pkg setValue:[[NSMutableArray alloc] init] forKey:@"versions"];
                    [pkg setValue:[[NSMutableArray alloc] init] forKey:@"debs"];
                    
                    [[pkg valueForKey:@"versions"] addObject:[package valueForKey:@"version"]];
                    
                    NSMutableArray *debArray = [[NSMutableArray alloc] init];
                    [debArray setValue:[NSString stringWithFormat:@"%@/%@", url, [package valueForKey:@"filename"]] forKey:[package valueForKey:@"version"]];
                    [debArray setValue:[package valueForKey:@"version"] forKey:@"version"];
                    [debArray setValue:[NSString stringWithFormat:@"%@/%@", url, [package valueForKey:@"filename"]] forKey:@"deb"];
                    [[pkg valueForKey:@"debs"] addObject:debArray];
                    
                } else {
                    [pkg setValue:p forKey:p_key];
                }
            }
            [pkg setValue:url forKey:@"repoURL"];
            [packages setValue:pkg forKey:[package valueForKey:@"package"]];
        }
    }
    
    NSMutableArray *pkg2 = [[NSMutableArray alloc] init];
    for (id package_key in packages) {
        id package = [packages valueForKey:package_key];
        [pkg2 addObject:package];
    }
    
    [json setValue:pkg2 forKey:@"Packages"];
    pkgarr = packages;
    
    NSMutableArray *_r = [[NSMutableArray alloc] init];
    NSMutableArray *r = [self release:url];
    if (![r isKindOfClass:[NSString class]]) {
        [r setValue:url forKey:@"OriginalURL"];
        [_r setObject:r atIndexedSubscript:0];
        [json setValue:_r forKey:@"Release"];
    } else {
        // Die...
    }
    
    NSError *error;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:json options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    return jsonString;
}

@end
