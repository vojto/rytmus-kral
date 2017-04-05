//
//  Recorder.m
//  Rytmus
//
//  Created by Vojtech Rinik on 16/01/16.
//  Copyright © 2016 Vojtech Rinik. All rights reserved.
//

#import "Recorder.h"
#import "Novocaine.h"
#import "NVHighpassFilter.h"
#import "NVLowpassFilter.h"

@implementation Recorder

- (void)record {
    self.manager = [Novocaine audioManager];

    NVLowpassFilter *LPF;
    LPF = [[NVLowpassFilter alloc] initWithSamplingRate:self.manager.samplingRate];

    LPF.cornerFrequency = 800.0f;
    LPF.Q = 0.8f;

    __block NSDate *date;
    __block float dbVal = 0.0;

    [self.manager setInputBlock:^(float *data, UInt32 numFrames, UInt32 numChannels) {
        [LPF filterData:data numFrames:numFrames numChannels:numChannels];

        vDSP_vsq(data, 1, data, 1, numFrames*numChannels);
        float meanVal = 0.0;
        vDSP_meanv(data, 1, &meanVal, numFrames*numChannels);


        float one = 1.0;


        vDSP_vdbcon(&meanVal, 1, &one, &meanVal, 1, 1, 0);

        if (meanVal != -INFINITY) {


            dbVal = dbVal + 0.2*(meanVal - dbVal);

            NSDate *previousDate = date;
            date = [NSDate date];

            if (previousDate) {
                self.onSample(dbVal, previousDate);
            }


        }



    }];



    [self.manager play];
}

@end
