//
//  SecondScene.m
//  FirstProject
//
//  Created by Benjamin Encz on 29/10/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import "SecondScene.h"
#import <chipmunk/chipmunk.h>

@implementation SecondScene

- (id)init {
    self = [super init];
    
    if (self) {
        //self.debugDraw = TRUE;
        self.physicsNode.gravity = ccp(0, -20);
        self.userInteractionEnabled = TRUE;
        
        CCNode *floorNode = [CCNode node];
        CCPhysicsBody *floor = [CCPhysicsBody bodyWithRect:CGRectMake(0, 30, 1000, 10) cornerRadius:0.f];
        floor.type = kCCPhysicsBodyTypeStatic;
        floorNode.physicsBody = floor;
        [self addChild:floorNode];
    }
    
    return self;
}

- (void)onAppear {
    CCMoveTo *moveTo = [CCMoveTo actionWithDuration:6.f position:ccp(self.contentSize.width, self.penguin.position.y)];
    [self.penguin runAction:moveTo];
    
    /* following line cannot be used, since 'affectedByGravity' is not implemented yet*/
    //self.catapultArm.physicsBody.affectedByGravity = FALSE;
}

- (void)onHide {
    
}

- (void)fire {
    NSLog(@"Fire");
    CCSprite *bullet = [CCSprite spriteWithImageNamed:@"flyingpenguin.png"];
    bullet.position = ccp(0, self.catapultArm.contentSize.height);
    [self.catapultArm addChild:bullet];
    
    CCBAnimationManager* animationManager = self.userObject;
    [animationManager setCompletedAnimationCallbackBlock:^(id sender) {
        [bullet removeFromParent];
        bullet.physicsBody = [CCPhysicsBody bodyWithCircleOfRadius:5 andCenter:ccp(bullet.contentSize.width/2, bullet.contentSize.height /2)];
        bullet.physicsBody.mass = 500.f;
        bullet.physicsBody.velocity = ccp(150, 0);
        bullet.position = ccp(self.catapultArm.position.x, self.catapultArm.position.y + self.catapultArm.contentSize.height);
        [self addChild:bullet];
        
        CCFollow *follow = [CCFollow actionWithTarget:bullet worldBoundary:CGRectMake(0, 0, 960, 320)];
        [self runAction:follow];
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

@end
