//
// WorldLayer.mm
// runner
//
// Created by Sven Holmgren on 11/27/12.
// Copyright __MyCompanyName__ 2012. All rights reserved.
//

// Import the interfaces
#import "WorldLayer.h"
#import "TBXML.h"

// Needed to obtain the Navigation Controller
#import "AppDelegate.h"

enum {
    kTagParentNode = 1,
};


#pragma mark - WorldLayer

@interface WorldLayer()
-(void) initPhysics:(float)worldWidth;
@end

@implementation WorldLayer

+(CCScene *) level:(int)level
{
    // 'scene' is an autorelease object.
    CCScene *scene = [CCScene node];
    
    // 'layer' is an autorelease object.
    WorldLayer *layer = [WorldLayer alloc];
    [layer initWithLevel:level];
    [layer autorelease];
    
    // add layer as a child to scene
    [scene addChild: layer];
    
    // return the scene
    return scene;
}

-(id) init
{
    return [self initWithLevel:1];
}

-(id) initWithLevel:(int)level
{
    if([super init]) {
        NSError ** error=nil;
        tbxml = [[TBXML newTBXMLWithXMLFile:@"levels.xml" error:error] retain];
        TBXMLElement * rootXMLElement = tbxml.rootXMLElement;
        
        
        // iterate levels to find the current one
        [TBXML iterateElementsForQuery:@"level" fromElement:rootXMLElement withBlock:^(TBXMLElement *levelXMLElement) {
            
           NSString * name = [TBXML valueOfAttributeNamed:@"name" forElement:levelXMLElement];
        
            if([name intValue]==level){
                //create background
                [self genBackground: [TBXML textForElement:[TBXML childElementNamed:@"background" parentElement:levelXMLElement]]];
                
                // enable events
                self.isTouchEnabled = YES;
                self.isAccelerometerEnabled = NO;
                
                // init physics
                [self initPhysics:[[TBXML textForElement:[TBXML childElementNamed:@"width" parentElement:levelXMLElement]] floatValue]];
                
                
                // Create contact listener
                _contactListener = new ContactListener();
                world->SetContactListener(_contactListener);
                
                
                //create player
                player = [Player spriteWithFile:@"srun1.png"];
                CCAnimation *frames=[CCAnimation animationWithSpriteFrames:[NSArray arrayWithObjects:
                                                                            [CCSpriteFrame frameWithTextureFilename:@"srun1.png" rect:CGRectMake(0,0,74,86)],
                                                                            [CCSpriteFrame frameWithTextureFilename:@"srun2.png" rect:CGRectMake(0,0,74,87) ],
                                                                            [CCSpriteFrame frameWithTextureFilename:@"srun3.png" rect:CGRectMake(0,0,74,87) ],
                                                                            [CCSpriteFrame frameWithTextureFilename:@"srun4.png" rect:CGRectMake(0,0,74,87) ],
                                                                            [CCSpriteFrame frameWithTextureFilename:@"srun5.png" rect:CGRectMake(0,0,73,87) ],
                                                                            [CCSpriteFrame frameWithTextureFilename:@"srun6.png" rect:CGRectMake(0,0,74,87) ],
                                                                            nil] delay:1.0/12.0 ];
                
                CCRepeatForever *repeat =[CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:frames]];
                [player runAction:repeat];
                
                player.position = ccp(100.0f, FLOOR_HEGHT+[player boundingBox].size.height/2);
                [player createBox2dObject:world];
                
                [self addChild:player];
                [player moveRight];
                
                //Obstacles
                TBXMLElement * obstaclesXMLElement =[TBXML childElementNamed:@"obstacles" parentElement:levelXMLElement];
                [TBXML iterateElementsForQuery:@"obstacle" fromElement:obstaclesXMLElement withBlock:^(TBXMLElement *obstacleXMLElement) {
                    [self addObstacle:[TBXML textForElement:[TBXML childElementNamed:@"file" parentElement:obstacleXMLElement]]
                           atPosition:[[TBXML textForElement:[TBXML childElementNamed:@"atPosition" parentElement:obstacleXMLElement]] floatValue]
                            isCircle:[[TBXML textForElement:[TBXML childElementNamed:@"isCircle" parentElement:obstacleXMLElement]] boolValue]
                            atFloorHeight:[[TBXML textForElement:[TBXML childElementNamed:@"atFloorHeight" parentElement:obstacleXMLElement]] boolValue]
                     ];
                }];
                
                
                
                [self scheduleUpdate];
            }

        }];

    }
    return self;
}


-(void)addObstacle:(NSString*)file atPosition:(float)position isCircle:(BOOL)isCircle atFloorHeight:(BOOL) atFloorHeight{
    Obstacle * Ob=[Obstacle spriteWithFile:file];
    Ob.position = ccp(position, (atFloorHeight? FLOOR_HEGHT:0) +[Ob boundingBox].size.height/2);
    
    [Ob createBox2dObject:world isCircle:isCircle];
    [self addChild:Ob];
}

- (void)genBackground:(NSString*)file {
    _background =[CCSprite spriteWithFile:file ] ;
    _background.position = ccp([_background boundingBox].size.width/2, [_background boundingBox].size.height/2);
    ccTexParams tp = {GL_LINEAR, GL_LINEAR, GL_REPEAT, GL_REPEAT};
    [_background.texture setTexParameters:&tp];
    
    [self addChild:_background z:-1];
}

-(void) dealloc
{
    delete world;
    world = NULL;
    
    //delete m_debugDraw;
    //m_debugDraw = NULL;
    
    delete _contactListener;
    
    
    [super dealloc];
}



-(void) initPhysics:(float)worldWidth
{
    
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    b2Vec2 gravity;
    gravity.Set(0.0f, -9.8f);
    world = new b2World(gravity);
    
    
    // Do we want to let bodies sleep?
    world->SetAllowSleeping(true);
    
    world->SetContinuousPhysics(true);
    
    /*
    m_debugDraw = new GLESDebugDraw( PTM_RATIO );
    world->SetDebugDraw(m_debugDraw);
    
    uint32 flags = 0;
    flags += b2Draw::e_shapeBit;
    // flags += b2Draw::e_jointBit;
    // flags += b2Draw::e_aabbBit;
    // flags += b2Draw::e_pairBit;
    // flags += b2Draw::e_centerOfMassBit;
    m_debugDraw->SetFlags(flags);
    */
    
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
    float width=worldWidth;
    float height=winSize.height*2.0f;
    float FLOOR_HEIGHT=FLOOR_HEGHT;
    
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
    
    //yeah yeah, we have no iphone to test with anyway.
    
    
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
            // Sprite A = collectible, Sprite B = player
            else if (spriteA.tag == TAG_COLLECTIBLE && spriteB.tag == TAG_PLAYER) {
                if (std::find(toDestroy.begin(), toDestroy.end(), bodyA)
                    == toDestroy.end()) {
                    toDestroy.push_back(bodyA);
                }
            }
            // Sprite A = OBSTACLE, Sprite B = player
            else if (spriteA.tag == TAG_OBSTACLE && spriteB.tag == TAG_PLAYER ){
                [self dieAction];
                
            }
            // Sprite A = player, Sprite B = OBSTACLE
            else if (spriteA.tag == TAG_PLAYER && spriteB.tag == TAG_OBSTACLE ) {
                [self dieAction];
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
    CGPoint oldPos =[self position];
	CGPoint newPos = ccp(-1 * playerPos.x * PTM_RATIO + 120, self.position.y * PTM_RATIO);
	[self setPosition:newPos];
    
    
    //Background handling
    static float offset = 0;
    offset += oldPos.x-newPos.x;
    CGSize textureSize = _background.textureRect.size;
    [_background setTextureRect:CGRectMake(offset, 0, textureSize.width, textureSize.height)];
    _background.position = ccp([_background boundingBox].size.width/2+offset, [_background boundingBox].size.height/2);
    
}

-(void)dieAction{
    [player die];
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [player jump];
}

-(void) Explosion:(CGPoint)atPosition{
    
//CCSprite *spriteExplosion = [CCSprite spriteWithFile:@"srun1.png"];
//CCAnimation *frames=[CCAnimation animationWithSpriteFrames:[NSArray arrayWithObjects:
//                                                                            [CCSpriteFrame frameWithTextureFilename:@"srun1.png" rect:CGRectMake(0,0,74,86)],
//                                                                            [CCSpriteFrame frameWithTextureFilename:@"srun2.png" rect:CGRectMake(0,0,74,87) ],
//                                                                            [CCSpriteFrame frameWithTextureFilename:@"srun3.png" rect:CGRectMake(0,0,74,87) ],
 //                                                                           [CCSpriteFrame frameWithTextureFilename:@"srun4.png" rect:CGRectMake(0,0,74,87) ],
 //                                                                           [CCSpriteFrame frameWithTextureFilename:@"srun5.png" rect:CGRectMake(0,0,73,87) ],
 //                                                                           [CCSpriteFrame frameWithTextureFilename:@"srun6.png" rect:CGRectMake(0,0,74,87) ],
 //                                                                           nil] delay:1.0/5.0 ];
                
  //              [player runAction:[CCSequence actions:[CCAnimate actionWithAnimation:frames restoreOriginalFrame:YES],
 
//[CCCallFuncN actionWithTarget:self selector:@selector(spriteDone:)],nil]];

}

- (void)spriteDone:(id)sender {
 
CCSprite *sprite = (CCSprite *)sender;
 
[self removeChild:sprite cleanup:YES];
 
}

#pragma mark GameKit delegate

@end