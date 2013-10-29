//
//  MainScene.m
//  PROJECTNAME
//
//  Created by Viktor on 10/10/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import "MainScene.h"

@implementation MainScene

- (void)startButtonPressed {
    NSLog(@"Test");
    CCScene* myScene = [CCBReader sceneWithNodeGraphFromFile:@"SecondScene.ccbi"];
    [[CCDirector sharedDirector] pushScene:myScene];
}

@end