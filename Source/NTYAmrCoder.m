//
//  NTYAmrCoder.m
//  NTYAmrConverter
//
//  Created by little2s on 16/4/16.
//  Copyright © 2015年 Chainsea. All rights reserved.
//

#import "NTYAmrCoder.h"
#import <AVFoundation/AVFoundation.h>
#import "interf_enc.h"
#import "interf_dec.h"

#define IGNORE_SIZEOF_WARNINGS(Stuff) \
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wsizeof-array-argument\"") \
_Pragma("clang diagnostic ignored \"-Wsizeof-pointer-memaccess\"") \
Stuff; \
_Pragma("clang diagnostic pop") \
} while (0)

#define AMR_MAGIC_NUMBER "#!AMR\n"

#define PCM_FRAME_SIZE 160 // 8khz 8000*0.02=160
#define MAX_AMR_FRAME_SIZE 32
#define AMR_FRAME_COUNT_PER_SECOND 50

#pragma mark - Defines

typedef struct
{
    char chChunkID[4];
    int nChunkSize;
}_NTYXChunkHeader;

typedef struct
{
    short nFormatTag;
    short nChannels;
    int nSamplesPerSec;
    int nAvgBytesPerSec;
    short nBlockAlign;
    short nBitsPerSample;
}_NTYWaveFormat;

typedef struct
{
    short nFormatTag;
    short nChannels;
    int nSamplesPerSec;
    int nAvgBytesPerSec;
    short nBlockAlign;
    short nBitsPerSample;
    short nExSize;
}_NTYWaveFormatX;

typedef struct
{
    char chRiffID[4];
    int nRiffSize;
    char chRiffFormat[4];
}_NTYRiffHeader;

typedef struct
{
    char chFmtID[4];
    int nFmtSize;
    _NTYWaveFormat wf;
}_NTYFmtBlock;

int _NTYAMREncodeMode[] = {4750, 5150, 5900, 6700, 7400, 7950, 10200, 12200};

#pragma mark - Encode wav to amr

void _NTYSkipToPCMAudioData(FILE* fpwave)
{
    _NTYRiffHeader riff;
    _NTYFmtBlock fmt;
    _NTYXChunkHeader chunk;
    _NTYWaveFormatX wfx;
    int bDataBlock = 0;
    
    // read riff
    fread(&riff, 1, sizeof(_NTYRiffHeader), fpwave);
    
    // read chunk
    fread(&chunk, 1, sizeof(_NTYXChunkHeader), fpwave);
    if (chunk.nChunkSize > 16)
    {
        fread(&wfx, 1, sizeof(_NTYWaveFormatX), fpwave);
    }
    else
    {
        memcpy(fmt.chFmtID, chunk.chChunkID, 4);
        fmt.nFmtSize = chunk.nChunkSize;
        fread(&fmt.wf, 1, sizeof(_NTYWaveFormat), fpwave);
    }
    
    // data
    while (!bDataBlock)
    {
        fread(&chunk, 1, sizeof(_NTYXChunkHeader), fpwave);
        if (!memcmp(chunk.chChunkID, "data", 4))
        {
            bDataBlock = 1;
            break;
        }
        // skip if not data block
        fseek(fpwave, chunk.nChunkSize, SEEK_CUR);
    }
}

// Return frame size if success
int _NTYReadPCMFrame(short speech[], FILE* fpwave, int nChannels, int nBitsPerSample)
{
    int nRead = 0;
    int x = 0, y = 0;
    
    unsigned char  pcmFrame_8b1[PCM_FRAME_SIZE];
    unsigned char  pcmFrame_8b2[PCM_FRAME_SIZE<<1];
    unsigned short pcmFrame_16b1[PCM_FRAME_SIZE];
    unsigned short pcmFrame_16b2[PCM_FRAME_SIZE<<1];
    
    if (nBitsPerSample == 8 && nChannels == 1)
    {
        nRead = (int)fread(pcmFrame_8b1, (nBitsPerSample/8), PCM_FRAME_SIZE*nChannels, fpwave);
        
        for (x = 0; x < PCM_FRAME_SIZE; x++)
        {
            speech[x] =(short)((short)pcmFrame_8b1[x] << 7);
        }
    }
    else {
        if (nBitsPerSample == 8 && nChannels == 2)
        {
            nRead = (int)fread(pcmFrame_8b2, (nBitsPerSample/8), PCM_FRAME_SIZE*nChannels, fpwave);
            for (x = 0, y = 0; y < PCM_FRAME_SIZE; y++, x += 2)
            {
                speech[y] =(short)((short)pcmFrame_8b2[x+0] << 7);
            }
        }
        else {
            if (nBitsPerSample==16 && nChannels==1)
            {
                nRead = (int)fread(pcmFrame_16b1, (nBitsPerSample/8), PCM_FRAME_SIZE*nChannels, fpwave);
                for (x = 0; x < PCM_FRAME_SIZE; x++)
                {
                    speech[x] = (short)pcmFrame_16b1[x+0];
                }
            }
            else {
                if (nBitsPerSample == 16 && nChannels == 2)
                {
                    nRead = (int)fread(pcmFrame_16b2, (nBitsPerSample/8), PCM_FRAME_SIZE*nChannels, fpwave);
                    for (x = 0, y = 0; y<PCM_FRAME_SIZE; y++, x += 2)
                    {
                        speech[y] = (short)((int)((int)pcmFrame_16b2[x+0] + (int)pcmFrame_16b2[x+1])) >> 1;
                    }
                }
            }
        }
    }
    
    // not full frame
    if (nRead < PCM_FRAME_SIZE*nChannels) {
        return 0;
    }
    
    return nRead;
}

int _NTYEncodeWAVEFileToAMRFile(const char* pchWAVEFilename, const char* pchAMRFileName, int nChannels, int nBitsPerSample)
{
    FILE* fpwave;
    FILE* fpamr;
    
    // input speech vector
    short speech[160];
    
    // counters
    int byte_counter, frames = 0, bytes = 0;
    
    // pointer to encoder state structure
    void *enstate;
    
    // requested mode
    enum Mode req_mode = MR122;
    int dtx = 0;
    
    // bitstream filetype
    unsigned char amrFrame[MAX_AMR_FRAME_SIZE];
    
    fpwave = fopen(pchWAVEFilename, "rb");
    if (fpwave == NULL)
    {
        return 0;
    }
    
    fpamr = fopen(pchAMRFileName, "wb");
    if (fpamr == NULL)
    {
        fclose(fpwave);
        return 0;
    }
    
    // write magic number to indicate single channel AMR file storage format
    bytes = (int)fwrite(AMR_MAGIC_NUMBER, sizeof(char), strlen(AMR_MAGIC_NUMBER), fpamr);
    
    // skip to pcm audio data
    _NTYSkipToPCMAudioData(fpwave);
    
    enstate = Encoder_Interface_init(dtx);
    
    while(1)
    {
        // read one pcm frame
        if (!_NTYReadPCMFrame(speech, fpwave, nChannels, nBitsPerSample))
        {
            break;
        }
        
        frames++;
        
        // call encoder
        byte_counter = Encoder_Interface_Encode(enstate, req_mode, speech, amrFrame, 0);
        
        bytes += byte_counter;
        fwrite(amrFrame, sizeof (unsigned char), byte_counter, fpamr);
    }
    
    Encoder_Interface_exit(enstate);
    
    fclose(fpamr);
    fclose(fpwave);
    
    return frames;
}

#pragma mark - Decode arm to wav

void _NTYWriteWAVEFileHeader(FILE* fpwave, int nFrame)
{
    char tag[10] = "";
    
    _NTYRiffHeader riff;
    strcpy(tag, "RIFF");
    memcpy(riff.chRiffID, tag, 4);
    
    riff.nRiffSize = 4 + sizeof(_NTYXChunkHeader) + sizeof(_NTYWaveFormatX)
    + sizeof(_NTYXChunkHeader) + nFrame * 160 * sizeof(short);
    
    strcpy(tag, "WAVE");
    memcpy(riff.chRiffFormat, tag, 4);
    fwrite(&riff, 1, sizeof(_NTYRiffHeader), fpwave);
    
    _NTYXChunkHeader chunk;
    _NTYWaveFormatX wfx;
    strcpy(tag, "fmt ");
    memcpy(chunk.chChunkID, tag, 4);
    chunk.nChunkSize = sizeof(_NTYWaveFormatX);
    fwrite(&chunk, 1, sizeof(_NTYXChunkHeader), fpwave);
    memset(&wfx, 0, sizeof(_NTYWaveFormatX));
    wfx.nFormatTag = 1;
    wfx.nChannels = 1;
    wfx.nSamplesPerSec = 8000;
    wfx.nAvgBytesPerSec = 16000;
    wfx.nBlockAlign = 2;
    wfx.nBitsPerSample = 16;
    fwrite(&wfx, 1, sizeof(_NTYWaveFormatX), fpwave);
    
    strcpy(tag, "data");
    memcpy(chunk.chChunkID, tag, 4);
    chunk.nChunkSize = nFrame*160*sizeof(short);
    fwrite(&chunk, 1, sizeof(_NTYXChunkHeader), fpwave);
}

const int _NTYRound(const double x)
{
    return ((int)(x + 0.5));
}

int _NTYCalculateAMRFrameSize(unsigned char frameHeader)
{
    int mode;
    int temp1 = 0;
    int temp2 = 0;
    int frameSize;
    
    temp1 = frameHeader;
    
    temp1 &= 0x78; // 0111-1000
    temp1 >>= 3;
    
    mode = _NTYAMREncodeMode[temp1];
    
    temp2 = _NTYRound((double)(((double)mode / (double)AMR_FRAME_COUNT_PER_SECOND) / (double)8));
    
    frameSize = _NTYRound((double)temp2 + 0.5);
    return frameSize;
}

int _NTYReadAMRFirstFrame(FILE* fpamr, unsigned char frameBuffer[], int* stdFrameSize, unsigned char* stdFrameHeader)
{
    IGNORE_SIZEOF_WARNINGS(memset(frameBuffer, 0, sizeof(frameBuffer)));
    
    fread(stdFrameHeader, 1, sizeof(unsigned char), fpamr);
    if (feof(fpamr))
    {
        return 0;
    }
    
    *stdFrameSize = _NTYCalculateAMRFrameSize(*stdFrameHeader);
    
    frameBuffer[0] = *stdFrameHeader;
    fread(&(frameBuffer[1]), 1, (*stdFrameSize-1)*sizeof(unsigned char), fpamr);
    if (feof(fpamr))
    {
        return 0;
    }
    
    return 1;
}

int _NTYReadAMRFrame(FILE* fpamr, unsigned char frameBuffer[], int stdFrameSize, unsigned char stdFrameHeader)
{
    int bytes = 0;
    unsigned char frameHeader;
    IGNORE_SIZEOF_WARNINGS(memset(frameBuffer, 0, sizeof(frameBuffer)));
    
    while(1)
    {
        bytes = (int)fread(&frameHeader, 1, sizeof(unsigned char), fpamr);
        if (feof(fpamr))
        {
            return 0;
        }
        if (frameHeader == stdFrameHeader)
        {
            break;
        }
    }
    
    frameBuffer[0] = frameHeader;
    bytes = (int)fread(&(frameBuffer[1]), 1, (stdFrameSize-1)*sizeof(unsigned char), fpamr);
    if (feof(fpamr))
    {
        return 0;
    }
    
    return 1;
}

int _NTYDecodeAMRFileToWAVEFile(const char* pchAMRFileName, const char* pchWAVEFilename)
{
    FILE* fpamr = NULL;
    FILE* fpwave = NULL;
    char magic[8];
    void * destate;
    int nFrameCount = 0;
    int stdFrameSize;
    unsigned char stdFrameHeader;
    
    unsigned char amrFrame[MAX_AMR_FRAME_SIZE];
    short pcmFrame[PCM_FRAME_SIZE];
    
    fpamr = fopen(pchAMRFileName, "rb");
    
    if (fpamr == NULL)
    {
        return 0;
    }
    
    fread(magic, sizeof(char), strlen(AMR_MAGIC_NUMBER), fpamr);
    if (strncmp(magic, AMR_MAGIC_NUMBER, strlen(AMR_MAGIC_NUMBER)))
    {
        fclose(fpamr);
        return 0;
    }
    
    fpwave = fopen(pchWAVEFilename,"wb");
    
    _NTYWriteWAVEFileHeader(fpwave, nFrameCount);
    
    destate = Decoder_Interface_init();
    
    memset(amrFrame, 0, sizeof(amrFrame));
    memset(pcmFrame, 0, sizeof(pcmFrame));
    _NTYReadAMRFirstFrame(fpamr, amrFrame, &stdFrameSize, &stdFrameHeader);
    
    Decoder_Interface_Decode(destate, amrFrame, pcmFrame, 0);
    nFrameCount++;
    fwrite(pcmFrame, sizeof(short), PCM_FRAME_SIZE, fpwave);
    
    while(1)
    {
        memset(amrFrame, 0, sizeof(amrFrame));
        memset(pcmFrame, 0, sizeof(pcmFrame));
        if (!_NTYReadAMRFrame(fpamr, amrFrame, stdFrameSize, stdFrameHeader)) break;
        
        Decoder_Interface_Decode(destate, amrFrame, pcmFrame, 0);
        nFrameCount++;
        fwrite(pcmFrame, sizeof(short), PCM_FRAME_SIZE, fpwave);
    }
    Decoder_Interface_exit(destate);
    
    fclose(fpwave);
    
    fpwave = fopen(pchWAVEFilename, "r+");
    _NTYWriteWAVEFileHeader(fpwave, nFrameCount);
    fclose(fpwave);
    
    return nFrameCount;
}

#pragma mark - Manager

@implementation NTYAmrCoder

+ (BOOL)encodeWavFile:(NSString *)wavPath toAmrFile:(NSString *)amrPath
{
    int frames = _NTYEncodeWAVEFileToAMRFile([wavPath cStringUsingEncoding: NSASCIIStringEncoding],
                                             [amrPath cStringUsingEncoding: NSASCIIStringEncoding], 1, 16);
    return frames == 0 ? NO : YES;
}

+ (BOOL)decodeAmrFile:(NSString *)amrPath toWavFile:(NSString *)wavPath
{
    int frames = _NTYDecodeAMRFileToWAVEFile([amrPath cStringUsingEncoding: NSASCIIStringEncoding],
                                             [wavPath cStringUsingEncoding: NSASCIIStringEncoding]);
    return frames == 0 ? NO : YES;
}

+ (NSDictionary *)audioRecorderSettings
{
    return @{ AVSampleRateKey: @(8000.0),
              AVFormatIDKey: @(kAudioFormatLinearPCM),
              AVLinearPCMBitDepthKey: @(16),
              AVNumberOfChannelsKey: @(1),
            };
}

@end
