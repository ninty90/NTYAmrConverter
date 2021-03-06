//
//  NTYAmrCoderTests.m
//  NTYAmrConverter
//
//  Created by little2s on 16/4/16.
//  Copyright © 2016年 Chainsea. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <NTYAmrConverter/NTYAmrCoder.h>
#import <AVFoundation/AVFoundation.h>

@interface NTYAmrCoderTests : XCTestCase

@end

@implementation NTYAmrCoderTests

- (void)testAmrEncode {
    NSString *wavPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"test.wav" ofType:nil];
    
    NSFileManager *manager = [NSFileManager defaultManager];
    NSURL *documentURL = [[manager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
    NSString *amrPath = [documentURL URLByAppendingPathComponent:@"test_encoded.amr"].path;
    
    XCTAssertNotNil(wavPath);
    XCTAssertNotNil(amrPath);
    
    BOOL result = [NTYAmrCoder encodeWavFile:wavPath toAmrFile:amrPath];
    
    XCTAssert(result == YES);
}

- (void)testAmrDecode {
    NSString *amrPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"test.amr" ofType:nil];
    
    NSFileManager *manager = [NSFileManager defaultManager];
    NSURL *documentURL = [[manager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
    NSString *wavPath = [documentURL URLByAppendingPathComponent:@"test_decoded.wav"].path;
    
    XCTAssertNotNil(wavPath);
    XCTAssertNotNil(amrPath);
    
    BOOL result = [NTYAmrCoder decodeAmrFile:amrPath toWavFile:wavPath];
    
    XCTAssert(result == YES);
}

- (void)testRecorderSettings {
    NSDictionary *settings = [NTYAmrCoder audioRecorderSettings];
    
    XCTAssert([settings[AVSampleRateKey] isEqual: @(8000.0)]);
    XCTAssert([settings[AVFormatIDKey] isEqual: @(kAudioFormatLinearPCM)]);
    XCTAssert([settings[AVLinearPCMBitDepthKey] isEqual: @(16)]);
    XCTAssert([settings[AVNumberOfChannelsKey] isEqual: @(1)]);
}

@end
