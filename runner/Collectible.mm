//
//  Collectible.m
//  runner
//
//  Created by Sven Holmgren on 1/8/13.
//

#import "Collectible.h"

@implementation Collectible
@synthesize body;

- (id) init {
    self = [super init];
    
    if (self) {
        self.tag=TAG_COLLECTIBLE;
    }
    
    return self;
}

-(void) createBox2dObject:(b2World*)world isCircle:(BOOL) isCircle{
    b2BodyDef playerBodyDef;
    playerBodyDef.type = b2_dynamicBody;
    playerBodyDef.position.Set(self.position.x/PTM_RATIO, self.position.y/PTM_RATIO);
    playerBodyDef.userData = self;
    playerBodyDef.fixedRotation = true;
    
    body = world->CreateBody(&playerBodyDef);
    
    b2Shape* shape;
    
    if(isCircle){
        b2CircleShape circleShape;
        circleShape.m_radius = [self boundingBox].size.width/2/PTM_RATIO;
        
        shape=&circleShape;
    }
    else //box
    {
        b2PolygonShape boxShape;
        boxShape.SetAsBox([self boundingBox].size.width/2/PTM_RATIO, [self boundingBox].size.height/2/PTM_RATIO);
        
        shape=&boxShape;
    }
    
    
    b2FixtureDef fixtureDef;
    fixtureDef.shape = shape;
    fixtureDef.density = 0.0f;
    fixtureDef.friction = 0.0f;
    fixtureDef.restitution = 1.0f;
    
    body->CreateFixture(&fixtureDef);
    self.tag=TAG_COLLECTIBLE;
}

- (void)dealloc
{
    [super dealloc];
}

@end
