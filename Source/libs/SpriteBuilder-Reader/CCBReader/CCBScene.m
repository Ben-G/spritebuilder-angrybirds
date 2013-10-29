//
//  CCBScene.m
//  FirstProject
//
//  Created by Benjamin Encz on 29/10/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import "CCBScene.h"

@implementation CCBScene

- (void)onEnterTransitionDidFinish {
    if ([self.customClass respondsToSelector:@selector(onAppear)]) {
        [self.customClass performSelector:@selector(onAppear) withObject:nil];
    }
}

- (void)onExitTransitionDidStart {
    if ([self.customClass respondsToSelector:@selector(onHide)]) {
        [self.customClass performSelector:@selector(onHide) withObject:nil];
    }
}

@end
