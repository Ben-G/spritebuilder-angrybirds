//
//  SecondScene.m
//  FirstProject
//
//  Created by Benjamin Encz on 29/10/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import "SecondScene.h"

@implementation SecondScene

- (id)init {
    self = [super init];
    
    if (self) {
        self.debugDraw = TRUE;
        self.physicsNode.gravity = ccp(0, 0);
        self.userInteractionEnabled = TRUE;
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
        bullet.physicsBody = [CCPhysicsBody bodyWithCircleOfRadius:5 andCenter:bullet.position];
        bullet.physicsBody.mass = 1.f;
        bullet.physicsBody.velocity = ccp(100, 0);
        bullet.position = ccp(self.catapultArm.position.x, self.catapultArm.position.y + self.catapultArm.contentSize.height);
        [self addChild:bullet];

    }];
    [animationManager runAnimationsForSequenceNamed:@"catapult"];
}

- (void)setContentSize:(CGSize)contentSize {
    [super setContentSize:contentSize];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView: [touch view]];
    CGPoint touchLocation = [self convertToNodeSpace:location];
    
    if (CGRectContainsPoint([self.catapultArm boundingBox], touchLocation)) {
        [self fire];
    }
}

@end
