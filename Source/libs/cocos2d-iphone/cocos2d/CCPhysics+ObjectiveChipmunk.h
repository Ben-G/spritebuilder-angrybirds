/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2013 Scott Lembcke
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import "CCPhysicsNode.h"
#import "CCPhysicsJoint.h"
#import "ObjectiveChipmunk/ObjectiveChipmunk.h"


// For comparison:
// https://developer.apple.com/library/ios/documentation/SpriteKit/Reference/SpriteKitFramework_Ref/_index.html#//apple_ref/doc/uid/TP40013041

/*
	TODO:
	* Sensors
	* Collision only mode. (Are sensors good enough?)
	* Projectile bodies?
	* Fixed timesteps are a hack.
	* Currently body must be set before adding to a parent node.
	* Currently nodes must have rigid transforms.
	* Currently a parent's absolute transform must be identity.
	* Currently nodes with a physics body are always considered to have dirty transforms.
	* Body constructors are still a little temporary.
	* Objective-Chipmunk interop.
	* affectedByGravity and allowsRotation properties not implemented.
	* Joints.
	* Queries.
	* Need to rename the CCPhysicsBody.absolute* properties. (not really absolute anymore)
	
	Consider:
	* Interpolation?
	* Post-step callbacks?
	* What to do about CCActions?
	* What to do about transform changes?
	* Chain/loop body types have multiple ChipmunkShapes and thus will get multiple callbacks.
	* Check argument types for delegate callbacks?
	* Angular velocity in degrees?
	* Warnings for CCPhysicsCollisionPair methods in the wrong event cycle?
	* Should CCPhysicsCollisionPair.userData retain?
	
	Probably Definitely Not:
	* Body queries?
*/


@interface CCPhysicsBody(ObjectiveChipmunk)<ChipmunkObject>

/// The CCNode this physics body is attached to.
@property(nonatomic, strong) CCNode *node;
/// The CCPhysicsNode this body is added to.
@property(nonatomic, readonly) CCPhysicsNode *physicsNode;
/// Returns YES if the body is currently added to a physicsNode.
@property(nonatomic, readonly) BOOL isRunning;

// TODO should probably rename these.
/// The position of the body relative to the space.
@property(nonatomic, assign) cpVect absolutePosition;
/// The rotation of the body relative to the space.
@property(nonatomic, assign) cpFloat absoluteRadians;
/// The transform of the body relative to the space.
@property(nonatomic, readonly) cpTransform absoluteTransform;

/// Implements the ChipmunkObject protocol.
@property(nonatomic, readonly) NSArray *chipmunkObjects;

// Used for deferring collision type setup until there is access to the physics node.
-(void)willAddToPhysicsNode:(CCPhysicsNode *)physics;
-(void)didRemoveFromPhysicsNode:(CCPhysicsNode *)physics;

@end


@interface CCPhysicsJoint(ObjectiveChipmunk)

/// Access to the underlying Objective-Chipmunk object.
@property(nonatomic, readonly) ChipmunkConstraint *constraint;

@end


@interface CCPhysicsCollisionPair(ObjectiveChipmunk)

/// Access to the underlying Objective-Chipmunk object.
@property(nonatomic, assign) cpArbiter *arbiter;

@end


@interface CCPhysicsNode(ObjectiveChipmunk)

/// Access to the underlying Objective-Chipmunk object.
@property(nonatomic, readonly) ChipmunkSpace *space;

/// Intern and copy a string to ensure it can be checked by reference
/// Used for collision type identifiers by CCPhysics.
/// nil and @"default" both return the value nil.
-(NSString *)internString:(NSString *)string;

/// Retain and track a category identifier and return it's index.
/// Up to 32 categories can be tracked for a space.
-(NSUInteger)indexForCategory:(NSString *)category;

/// Convert an array of NSStrings for collision category identifiers into a category bitmask.
/// The categories are retained and assigned indexes.
/// Up to 32 categories can be tracked for a space.
-(cpBitmask)bitmaskForCategories:(NSArray *)categories;

/// Convert a cpBitmask value to an array of collision category strings.
/// Ignores any bits that don't have a collision category assigned in the physics node.
-(NSArray *)categoriesForBitmask:(cpBitmask)categories;

@end
