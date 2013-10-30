//
//  SecondScene.h
//  FirstProject
//
//  Created by Benjamin Encz on 29/10/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import "CCNode.h"

@interface SecondScene : CCPhysicsNode

@property (nonatomic, assign) CCNode *catapultArm;
@property (nonatomic, assign) CCNode *penguin;
@property (nonatomic, assign) CCNode *flyingPenguin;
@property (nonatomic, assign) CCNode *background;
@property (nonatomic, assign) CCNode *gameOverLabel;
@property (nonatomic, assign) CCNode *contentContainer;

@end
