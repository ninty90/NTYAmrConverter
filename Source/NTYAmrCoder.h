//
//  NTYAmrCoder.h
//  NTYAmrConverter
//
//  Created by little2s on 16/4/16.
//  Copyright © 2015年 Chainsea. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Coder for convert between .amr and .wav file
 */
@interface NTYAmrCoder : NSObject

/**
 *  Encode wav file to amr file
 *
 *  @param wavPath wav file path
 *  @param amrPath amr file path
 *
 *  @return YES for success, NO for failure
 */
+ (BOOL)encodeWavFile:(NSString *)wavPath toAmrFile:(NSString *)amrPath;

/**
 *  Decode arm file to wav file
 *
 *  @param amrPath amr file path
 *  @param wavPath wav file path
 *
 *  @return YES for success, NO for failure
 */
+ (BOOL)decodeAmrFile:(NSString *)amrPath toWavFile:(NSString *)wavPath;

/**
 *  Settings for audio recorder
 *
 *  @return dictionary with settings
 *          AVSampleRateKey : 8000
 *            AVFormatIDKey : kAudioFormatLinearPCM
 *   AVLinearPCMBitDepthKey : 16
 *    AVNumberOfChannelsKey : 1
 */
+ (NSDictionary *)audioRecorderSettings;

@end

NS_ASSUME_NONNULL_END