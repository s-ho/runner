//
// Player.m
// runner
//
// Created by Sven Holmgren on 1/6/13.
//

#import "Player.h"
#import "WorldLayer.h"

@implementation Player
@synthesize body;

- (id) init {
    self = [super init];
    
    if (self) {
        self.tag=TAG_PLAYER;
    }
    
    return self;
}

-(void) createBox2dObject:(b2World*)world {
    b2BodyDef playerBodyDef;
    playerBodyDef.type = b2_dynamicBody;
    playerBodyDef.position.Set(self.position.x/PTM_RATIO, self.position.y/PTM_RATIO);
    playerBodyDef.userData = self;
    playerBodyDef.fixedRotation = true;
    
    body = world->CreateBody(&playerBodyDef);
    
    b2CircleShape circleShape;
    circleShape.m_radius = 0.7;
    
    b2FixtureDef fixtureDef;
    fixtureDef.shape = &circleShape;
    fixtureDef.density = 1.0f;
    fixtureDef.friction = 0.0f;
    fixtureDef.restitution = 0.0f;
    
    body->CreateFixture(&fixtureDef);
}

-(void) moveRight {
    b2Vec2 impulse = b2Vec2(8.0f, 0.0f);
    body->SetLinearVelocity(impulse);
}

-(void) jump {
    //with timing, it is possible to jump in air
    if(abs((body->GetLinearVelocity()).y)==0){
        b2Vec2 impulse = b2Vec2(0.0f, 15.0f);
        body->ApplyLinearImpulse(impulse, body->GetWorldCenter());
    }
}

- (void)dealloc
{
    [super dealloc];
}

@end