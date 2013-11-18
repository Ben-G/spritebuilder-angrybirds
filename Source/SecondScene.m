//
//  SecondScene.m
//  FirstProject
//
//  Created by Benjamin Encz on 29/10/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import "SecondScene.h"
#import <chipmunk/chipmunk.h>

@implementation SecondScene {
    BOOL shot;
}

- (void)didLoadFromCCB {
    self.contentContainer.physicsNode.gravity = ccp(0, -400);
    self.userInteractionEnabled = TRUE;
    
    CCNode *floorNode = [CCNode node];
    CCPhysicsBody *floor = [CCPhysicsBody bodyWithRect:CGRectMake(0, 30, 1000, 10) cornerRadius:0.f];
    floor.type = CCPhysicsBodyTypeStatic;
    floorNode.physicsBody = floor;
    [self.contentContainer addChild:floorNode];
}

- (void)fire {
    CCSpriteFrame* spriteFrame = [CCSpriteFrame frameWithImageNamed:@"ccbResources/flyingpenguin.png"];
    CCSprite *bullet = [CCSprite spriteWithSpriteFrame:spriteFrame];
    bullet.position = ccp(24, self.catapultArm.contentSize.height-20);
    [self.catapultArm addChild:bullet];
    
    CCBAnimationManager* animationManager = self.userObject;
    [animationManager setCompletedAnimationCallbackBlock:^(id sender) {
        [bullet removeFromParent];
        bullet.physicsBody = [CCPhysicsBody bodyWithCircleOfRadius:5 andCenter:ccp(bullet.contentSize.width/2, bullet.contentSize.height /2)];
        bullet.physicsBody.mass = 50.f;
        bullet.physicsBody.velocity = ccp(400, 100);
        bullet.physicsBody.friction = 100.0;
        bullet.physicsBody.elasticity = 0.2f;
        bullet.position = ccp(self.catapultArm.position.x, self.catapultArm.position.y + self.catapultArm.contentSize.height);
        [self.contentContainer addChild:bullet];
        
        CCActionFollow *follow = [CCActionFollow actionWithTarget:bullet worldBoundary:CGRectMake(0, 0, 960, 320)];
        [self.contentContainer runAction:follow];
        self.flyingPenguin = bullet;
        shot = TRUE;
    }];
    [animationManager runAnimationsForSequenceNamed:@"catapult"];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [[CCDirector sharedDirector] convertToGL:[touch locationInView:[CCDirector sharedDirector].view]];
    
    if (CGRectContainsPoint([self.catapultArm boundingBox], touchLocation)) {
        [self fire];
    }
}

- (void)update:(CCTime)delta {
    if (!shot) {
        return;
    }
    
    if ((fabs(self.flyingPenguin.physicsBody.velocity.x) < 0.1) && (fabs(self.flyingPenguin.physicsBody.velocity.y) < 0.1) && fabs(self.flyingPenguin.physicsBody.angularVelocity) < 0.1) {
        // game over
        shot = FALSE;
        
        CCBAnimationManager* animationManager = self.userObject;
        [animationManager setCompletedAnimationCallbackBlock:^(id sender) {
            CCScene* myScene = [CCBReader sceneWithNodeGraphFromFile:@"MainScene.ccbi"];
            [[CCDirector sharedDirector] replaceScene:myScene];
        }];
        [animationManager runAnimationsForSequenceNamed:@"gameover"];
    }
}

@end
