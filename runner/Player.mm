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
@synthesize isAlive;
@synthesize powerUps;
@synthesize collectibles;


- (id) init {
    self = [super init];
    
    if (self) {
        [self setState];
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
    
    
    b2PolygonShape shape;
    shape.SetAsBox([self boundingBox].size.width/2.0f/PTM_RATIO, [self boundingBox].size.height/2.0f/PTM_RATIO);
    
    b2FixtureDef fixtureDef;
    fixtureDef.shape = &shape;
    fixtureDef.density = 1.0f;
    fixtureDef.friction = 0.0f;
    fixtureDef.restitution = 0.0f;
    
    body->CreateFixture(&fixtureDef);
    [self setState];
}

-(void)setState{
    self.tag=TAG_PLAYER;
    isAlive=YES;
}

-(void) moveRight {
    b2Vec2 impulse = b2Vec2(PLAYER_SPEED, (body->GetLinearVelocity()).y);
    body->SetLinearVelocity(impulse);
}

-(void) jump:(int)power {
    //with timing, it is possible to jump in air
    
    if(isAlive){
    if(abs((body->GetLinearVelocity()).y)<0.01f){
        b2Vec2 impulse = b2Vec2(0.0f, power*25.0f);
        body->ApplyLinearImpulse(impulse, body->GetWorldCenter());
    }
    }
}

-(void) die {
    if(isAlive){
        CCAnimation *frames=[CCAnimation animationWithSpriteFrames:[NSArray arrayWithObjects:
                                                                    [CCSpriteFrame frameWithTextureFilename:@"die.png" rect:CGRectMake(0,0,40,65) ],
                                                                    [CCSpriteFrame frameWithTextureFilename:@"die2.png" rect:CGRectMake(0,0,40,65) ],
                                                                    nil] delay:1.0/6.0 ];
    
        CCRepeatForever *repeat =[CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:frames]];
        [self stopAllActions];
        [self runAction:repeat];
        isAlive=NO;
        body->SetLinearVelocity(b2Vec2(0.0f, 0.0f));
    }
    
}


- (void)dealloc
{
    [super dealloc];
}

@end