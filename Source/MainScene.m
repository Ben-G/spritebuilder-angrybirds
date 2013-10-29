//
//  MainScene.m
//  PROJECTNAME
//
//  Created by Viktor on 10/10/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import "MainScene.h"
#import "SecondScene.h"

@implementation MainScene

- (id)init {
    return [super init];
}

- (void)startButtonPressed {
    NSLog(@"Test");
   // SecondScene *scene = [[SecondScene alloc] init];
    CCScene* myScene = [CCBReader sceneWithNodeGraphFromFile:@"SecondScene.ccbi"];
    
    CCTransition *transition = [CCTransition moveInWithDirection:CCTransitionDirectionLeft duration:0.3f];
    
    // go to recap scene
    [CCDirector.sharedDirector replaceScene:myScene withTransition:transition];
}

@end