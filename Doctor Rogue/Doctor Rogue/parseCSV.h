//
//  parseCSV.h
//  Toddler Taxonomist
//
//  Created by Clay Heaton on 4/17/13.
//  Copyright (c) 2013 The Perihelion Group. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 * cCSVParse, a small CVS file parser
 *
 * © 2007-2009 Michael Stapelberg and contributors
 * http://michael.stapelberg.de/
 *
 * This source code is BSD-licensed, see LICENSE for the complete license.
 * http://rndm-snippets.blogspot.com/2011/08/xcode4-csv-parser-for-iphoneipad-ios.html
 * https://github.com/JanX2/cCSVParse
 */

#import <UIKit/UIKit.h>


@interface CSVParser:NSObject
-(id)init;

-(BOOL)openFile:(NSString*)fileName;
-(void)closeFile;

-(char)autodetectDelimiter;

-(NSString *)delimiterString;
-(NSString *)endOfLine;

+(NSArray *)supportedDelimiters;
+(NSArray *)supportedDelimiterLocalizedNames;

+(NSArray *)supportedLineEndings;
+(NSArray *)supportedLineEndingLocalizedNames;

-(NSMutableArray*)parseFile;
-(NSMutableArray *)parseData;
-(NSMutableArray *)parseData:(NSData *)data;

@property (copy) NSData *data;

@property (assign) char delimiter;
@property (assign) NSStringEncoding encoding;

@property (assign) size_t bufferSize;

@property (assign) BOOL verbose;

@end