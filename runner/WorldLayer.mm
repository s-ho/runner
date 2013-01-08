//
// WorldLayer.mm
// runner
//
// Created by Sven Holmgren on 11/27/12.
// Copyright __MyCompanyName__ 2012. All rights reserved.
//

// Import the interfaces
#import "WorldLayer.h"

// Needed to obtain the Navigation Controller
#import "AppDelegate.h"

enum {
    kTagParentNode = 1,
};


#pragma mark - WorldLayer

@interface WorldLayer()
-(void) initPhysics;
@end

@implementation WorldLayer

+(CCScene *) scene
{
    // 'scene' is an autorelease object.
    CCScene *scene = [CCScene node];
    
    // 'layer' is an autorelease object.
    WorldLayer *layer = [WorldLayer node];
    
    // add layer as a child to scene
    [scene addChild: layer];
    
    // return the scene
    return scene;
}

-(id) init
{
    if( (self=[super init])) {
        // enable events
        
        self.isTouchEnabled = YES;
        self.isAccelerometerEnabled = NO;
        
        // init physics
        [self initPhysics];
      
        
        // Create contact listener
        _contactListener = new ContactListener();
        world->SetContactListener(_contactListener);
        
        
        //create player
        player = [Player spriteWithFile:@"Icon-Small.png"];
        player.position = ccp(100.0f, 180.0f);
        [player createBox2dObject:world];
        
        [self addChild:player];
        [player moveRight];
        
        
        [self scheduleUpdate];
    }
    return self;
}

-(void) dealloc
{
    delete world;
    world = NULL;
    
    delete m_debugDraw;
    m_debugDraw = NULL;
    
    delete _contactListener;
    
    
    [super dealloc];
}



-(void) initPhysics
{
    
    CGSize s = [[CCDirector sharedDirector] winSize];
    
    b2Vec2 gravity;
    gravity.Set(0.0f, -9.8f);
    world = new b2World(gravity);
    
    
    // Do we want to let bodies sleep?
    world->SetAllowSleeping(true);
    
    world->SetContinuousPhysics(true);
    
    m_debugDraw = new GLESDebugDraw( PTM_RATIO );
    world->SetDebugDraw(m_debugDraw);
    
    uint32 flags = 0;
    flags += b2Draw::e_shapeBit;
    // flags += b2Draw::e_jointBit;
    // flags += b2Draw::e_aabbBit;
    // flags += b2Draw::e_pairBit;
    // flags += b2Draw::e_centerOfMassBit;
    m_debugDraw->SetFlags(flags);
    
    
    // Define the ground body.
    b2BodyDef groundBodyDef;
    groundBodyDef.position.Set(0, 0); // bottom-left corner
    
    // Call the body factory which allocates memory for the ground body
    // from a pool and creates the ground box shape (also from a pool).
    // The body is also added to the world.
    b2Body* groundBody = world->CreateBody(&groundBodyDef);
    
    // Define the ground box shape.
    b2EdgeShape groundBox;
    
    //world dimensions
    float width=s.width*15.0f;
    float height=s.height*2.0f;
    float FLOOR_HEIGHT=10.0f;
    
    // bottom
    groundBox.Set(b2Vec2(0,FLOOR_HEIGHT/PTM_RATIO), b2Vec2(width/PTM_RATIO,FLOOR_HEIGHT/PTM_RATIO));
    groundBody->CreateFixture(&groundBox,0);
    
    // top
    groundBox.Set(b2Vec2(0,height/PTM_RATIO), b2Vec2(width/PTM_RATIO,height/PTM_RATIO));
    groundBody->CreateFixture(&groundBox,0);
    
    // left
    groundBox.Set(b2Vec2(0,height/PTM_RATIO), b2Vec2(0,0));
    groundBody->CreateFixture(&groundBox,0);
    
    // right
    groundBox.Set(b2Vec2(width/PTM_RATIO,height/PTM_RATIO), b2Vec2(width/PTM_RATIO,0));
    groundBody->CreateFixture(&groundBox,0);
    
    
}

-(void) draw
{
    //
    // IMPORTANT:
    // This is only for debug purposes
    // It is recommend to disable it
    //
    /*
    [super draw];
    
    ccGLEnableVertexAttribs( kCCVertexAttribFlag_Position );
    
    kmGLPushMatrix();
    
    world->DrawDebugData();
    
    kmGLPopMatrix();
*/
}



-(void) update: (ccTime) dt
{
    //It is recommended that a fixed time step is used with Box2D for stability
    //of the simulation, however, we are using a variable time step here.
    //You need to make an informed choice, the following URL is useful
    //http://gafferongames.com/game-physics/fix-your-timestep/
    
    //yeah yeah, we have no iphone to test performance with anyway.
    
    
    int32 velocityIterations = 8;
    int32 positionIterations = 1;
    
    // Instruct the world to perform a single step of simulation. It is
    // generally best to keep the time step and iterations fixed.
    world->Step(dt, velocityIterations, positionIterations);
    
    
    
    //Iterate over the bodies in the physics world, and update the sprites
	for (b2Body* b = world->GetBodyList(); b; b = b->GetNext()) {
		if (b->GetUserData() != NULL) {
			CCSprite *sprite = (CCSprite*)b->GetUserData();
			sprite.position = CGPointMake( b->GetPosition().x * PTM_RATIO,
                                           b->GetPosition().y * PTM_RATIO);
			sprite.rotation = -1 * CC_RADIANS_TO_DEGREES(b->GetAngle());
		}	
	}
    
    //handle contacts
    std::vector<b2Body *>toDestroy;
    std::vector<Contact>::iterator pos;
    for(pos = _contactListener->_contacts.begin(); pos != _contactListener->_contacts.end(); ++pos) {
        Contact contact = *pos;

        b2Body *bodyA = contact.fixtureA->GetBody();
        b2Body *bodyB = contact.fixtureB->GetBody();
        if (bodyA->GetUserData() != NULL && bodyB->GetUserData() != NULL) {
            CCSprite *spriteA = (CCSprite *) bodyA->GetUserData();
            CCSprite *spriteB = (CCSprite *) bodyB->GetUserData();
            
            // Sprite A = player, Sprite B = collectible
            if (spriteA.tag == TAG_PLAYER && spriteB.tag == TAG_COLLECTIBLE) {
                if (std::find(toDestroy.begin(), toDestroy.end(), bodyB)
                    == toDestroy.end()) {
                    toDestroy.push_back(bodyB);
                }
            }
            // Sprite B = collectible, Sprite A = player
            else if (spriteA.tag == TAG_COLLECTIBLE && spriteB.tag == TAG_PLAYER) {
                if (std::find(toDestroy.begin(), toDestroy.end(), bodyA)
                    == toDestroy.end()) {
                    toDestroy.push_back(bodyA);
                }
            }
        }    
    }
    
    std::vector<b2Body *>::iterator pos2;
    for(pos2 = toDestroy.begin(); pos2 != toDestroy.end(); ++pos2) {
        b2Body *body = *pos2;
        if (body->GetUserData() != NULL) {
            CCSprite *sprite = (CCSprite *) body->GetUserData();
            [self removeChild:sprite cleanup:YES];
        }
        world->DestroyBody(body);
    }
    
    
    //set the 'camera'
	b2Vec2 playerPos = [player body]->GetPosition();
	CGPoint newPos = ccp(-1 * playerPos.x * PTM_RATIO + 120, self.position.y * PTM_RATIO);
	[self setPosition:newPos];
    
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [player jump];
}

#pragma mark GameKit delegate

@end