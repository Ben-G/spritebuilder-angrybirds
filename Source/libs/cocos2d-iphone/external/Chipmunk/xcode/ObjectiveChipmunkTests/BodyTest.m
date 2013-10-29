#import <XCTest/XCTest.h>
#import "ObjectiveChipmunk.h"

@interface UpdateTestBody : ChipmunkBody

@property(nonatomic, assign) BOOL velocityUpdated;
@property(nonatomic, assign) BOOL positionUpdated;

@end


@implementation UpdateTestBody

-(void)updateVelocity:(cpFloat)dt gravity:(cpVect)gravity damping:(cpFloat)damping
{
	self.velocityUpdated = TRUE;
}

-(void)updatePosition:(cpFloat)dt
{
	self.positionUpdated = TRUE;
}

@end


@interface BodyTest : XCTestCase {}
@end

@implementation BodyTest

#define TestAccessors(o, p, v) o.p = v; XCTAssertEqual(o.p, v, @"");

-(void)testProperties {
	ChipmunkBody *body = [ChipmunkBody bodyWithMass:123 andMoment:123];
	XCTAssertEqual(body.mass, (cpFloat)123, @"");
	XCTAssertEqual(body.moment, (cpFloat)123, @"");
	
	XCTAssertNotEqual(body.body, NULL, @"");
	XCTAssertNil(body.userData, @"");
	
	TestAccessors(body, userData, @"object");
	TestAccessors(body, mass, (cpFloat)5);
	TestAccessors(body, moment, (cpFloat)5);
	TestAccessors(body, position, cpv(5,6));
	TestAccessors(body, velocity, cpv(5,6));
	TestAccessors(body, force, cpv(5,6));
	TestAccessors(body, angle, (cpFloat)5);
	TestAccessors(body, angularVelocity, (cpFloat)5);
	TestAccessors(body, torque, (cpFloat)5);
	
	body.angle = 0;
	body.angle = M_PI;
	body.angle = M_PI_2;
	// TODO transform tests
	
	XCTAssertFalse(body.isSleeping, @"");
	XCTAssertEqual(body.type, CP_BODY_TYPE_DYNAMIC, @"");
}

-(void)testBasic {
	ChipmunkBody *body = [ChipmunkBody bodyWithMass:1 andMoment:1];
	
	[body applyForce:cpv(0,1) atWorldPoint:cpv(1,0)];
	XCTAssertTrue(body.force.y > 0, @"");
	XCTAssertTrue(body.force.x == 0, @"");
	XCTAssertTrue(body.torque > 0, @"");
	
	body.force = cpvzero;
	body.torque = 0.0f;
	XCTAssertEqual(body.force, cpvzero, @"");
	XCTAssertEqual(body.torque, (cpFloat)0, @"");
	
	[body applyImpulse:cpv(0,1) atWorldPoint:cpv(1,0)];
	XCTAssertTrue(body.velocity.y > 0, @"");
	XCTAssertTrue(body.velocity.x == 0, @"");
	XCTAssertTrue(body.angularVelocity > 0, @"");
}

-(void)testMisc {
	ChipmunkBody *staticBody = [ChipmunkBody staticBody];
	XCTAssertFalse(staticBody.isSleeping, @"");
	XCTAssertEqual(staticBody.type, CP_BODY_TYPE_STATIC, @"");
	
	ChipmunkSpace *space = [[ChipmunkSpace alloc] init];
	ChipmunkBody *body = [ChipmunkBody bodyWithMass:1 andMoment:1];
	[space add:body];
	XCTAssertFalse(body.isSleeping, @"");
	XCTAssertEqual(body.type, CP_BODY_TYPE_DYNAMIC, @"");
	
	[body sleep];
	XCTAssertTrue(body.isSleeping, @"");
	[space release];
}

-(void)testUpdate {
	ChipmunkSpace *space = [[ChipmunkSpace alloc] init];
	UpdateTestBody *body = [space add:[UpdateTestBody bodyWithMass:1.0 andMoment:1.0]];
	
	XCTAssertTrue(body.body->velocity_func != cpBodyUpdateVelocity, @"Did not set velocity integration callback.");
	XCTAssertTrue(body.body->position_func != cpBodyUpdatePosition, @"Did not set position integration callback.");
	
	[space step:1.0];
	XCTAssertTrue(body.velocityUpdated, @"Did not call velocity integration callback.");
	XCTAssertTrue(body.positionUpdated, @"Did not call position integration callback.");
	
	[space release];
}

-(void)testSpace {
	ChipmunkSpace *space = [[ChipmunkSpace alloc] init];
	ChipmunkBody *body = [ChipmunkBody bodyWithMass:1.0 andMoment:1.0];
	
	XCTAssertNil(body.space, @"body.space should be nil.");
	
	[space add:body];
	XCTAssertEqual(body.space, space, @"body.space should be nil.");
	
	[space release];
}

@end
