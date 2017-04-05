//
//  Recorder.h
//  Rytmus
//
//  Created by Vojtech Rinik on 16/01/16.
//  Copyright © 2016 Vojtech Rinik. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Novocaine.h"

@interface Recorder : NSObject

@property Novocaine *manager;

@property (nonatomic, copy) void (^onSample)(float volume, NSDate *date = nil);

- (void)record;

@end
