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
        self.physicsNode.gravity = ccp(0, -50);
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
    CCBAnimationManager* animationManager = self.userObject;
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
