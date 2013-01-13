//
//  Obstacle.m
//  runner
//
//  Created by Sven Holmgren on 1/9/13.
//

#import "Obstacle.h"

@implementation Obstacle
@synthesize body;

- (id) init {
    self = [super init];
    
    if (self) {
        self.tag=TAG_OBSTACLE;
    }
    
    return self;
}

-(void) createBox2dObject:(b2World*)world isCircle:(BOOL) isCircle{
    b2BodyDef playerBodyDef;
    playerBodyDef.type =b2_staticBody;
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
        boxShape.SetAsBox(([self boundingBox].size.width/2)/PTM_RATIO, ([self boundingBox].size.height/2)/PTM_RATIO);
        
        shape=&boxShape;
    }
    
    b2FixtureDef fixtureDef;
    fixtureDef.shape = shape;
    fixtureDef.density = 1.0f;
    fixtureDef.friction = 1.0f;
    fixtureDef.restitution = 0.0f;

    
    body->CreateFixture(&fixtureDef);
    self.tag=TAG_OBSTACLE;
}

- (void)dealloc
{
    [super dealloc];
}

@end
