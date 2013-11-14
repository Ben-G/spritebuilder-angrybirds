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
    //self.contentContainer.physicsNode.debugDraw = TRUE;
    self.contentContainer.physicsNode.gravity = ccp(0, -400);
    self.userInteractionEnabled = TRUE;
    
    CCNode *floorNode = [CCNode node];
    CCPhysicsBody *floor = [CCPhysicsBody bodyWithRect:CGRectMake(0, 30, 1000, 10) cornerRadius:0.f];
    floor.type = CCPhysicsBodyTypeStatic;
    floorNode.physicsBody = floor;
    [self.contentContainer addChild:floorNode];
}

- (void)onAppear {
    CCActionMoveTo *moveTo = [CCActionMoveTo actionWithDuration:6.f position:ccp(self.contentSize.width, self.penguin.position.y)];
    [self.penguin runAction:moveTo];
    
    /* following line cannot be used, since 'affectedByGravity' is not implemented yet*/
    //self.catapultArm.physicsBody.affectedByGravity = FALSE;
}

- (void)onHide {
    
}

- (void)fire {
    NSLog(@"Fire");

    CCSpriteFrame* spriteFrame = [CCSpriteFrame frameWithImageNamed:@"ccbResources/flyingpenguin.png"];
    CCSprite *bullet = [CCSprite spriteWithSpriteFrame:spriteFrame];
    bullet.position = ccp(0, self.catapultArm.contentSize.height);
    [self.catapultArm addChild:bullet];
    
    CCBAnimationManager* animationManager = self.userObject;
    [animationManager setCompletedAnimationCallbackBlock:^(id sender) {
        [bullet removeFromParent];
        bullet.physicsBody = [CCPhysicsBody bodyWithCircleOfRadius:5 andCenter:ccp(bullet.contentSize.width/2, bullet.contentSize.height /2)];
        bullet.physicsBody.mass = 500.f;
        bullet.physicsBody.velocity = ccp(450, 100);
        bullet.position = ccp(self.catapultArm.position.x, self.catapultArm.position.y + self.catapultArm.contentSize.height);
        [self.contentContainer addChild:bullet];
        
        CCActionFollow *follow = [CCActionFollow actionWithTarget:bullet worldBoundary:CGRectMake(0, 0, 960, 320)];
        [self.contentContainer runAction:follow];
        self.flyingPenguin = bullet;
        shot = TRUE;
    }];
    [animationManager runAnimationsForSequenceNamed:@"catapult"];
}

- (void)setContentSize:(CGSize)contentSize {
    [super setContentSize:contentSize];
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
