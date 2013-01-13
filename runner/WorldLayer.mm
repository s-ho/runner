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
    CCScene *scene = [CCScene node];
    
    WorldLayer *layer = [[WorldLayer alloc]initWithLevel:level];
    
    [scene addChild: layer];
    
    [layer release];
    
    // return the scene
    return scene;
}

-(id) init
{
    return [self initWithLevel:1];
}

-(id) initWithLevel:(int)level
{
    if(self=[super init]) {
        [self createInterface];
        
        backgroundOffset = 0;
        
        
        NSError ** error=nil;
        self->tbxml = [[TBXML newTBXMLWithXMLFile:@"levels.xml" error:error] retain];
        TBXMLElement * rootXMLElement = tbxml.rootXMLElement;
        
        
        // iterate levels to find the current one
        [TBXML iterateElementsForQuery:@"level" fromElement:rootXMLElement withBlock:^(TBXMLElement *levelXMLElement) {
            
           NSString * name = [TBXML valueOfAttributeNamed:@"name" forElement:levelXMLElement];
        
            if([name intValue]==level){
                self->currentLevel=level;
                //create background
                [self genBackground: [TBXML textForElement:[TBXML childElementNamed:@"background" parentElement:levelXMLElement]]];
                
                // enable events
                self.isTouchEnabled = YES;
                self.isAccelerometerEnabled = NO;
                
                // init physics
                levelWidth=[[TBXML textForElement:[TBXML childElementNamed:@"width" parentElement:levelXMLElement]] floatValue];
                [self initPhysics:levelWidth];
                
                
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
                
                //Collectibles
                TBXMLElement * collectiblesXMLElement =[TBXML childElementNamed:@"collectibles" parentElement:levelXMLElement];
                [TBXML iterateElementsForQuery:@"collectible" fromElement:collectiblesXMLElement withBlock:^(TBXMLElement *collectibleXMLElement) {
                    [self addCollectible:[TBXML textForElement:[TBXML childElementNamed:@"file" parentElement:collectibleXMLElement]]
                           atPosition:[[TBXML textForElement:[TBXML childElementNamed:@"atPosition" parentElement:collectibleXMLElement]] floatValue]
                             isCircle:[[TBXML textForElement:[TBXML childElementNamed:@"isCircle" parentElement:collectibleXMLElement]] boolValue]
                     ];
                }];
                
                //PowerUps
                TBXMLElement * powerupsXMLElement =[TBXML childElementNamed:@"powerups" parentElement:levelXMLElement];
                [TBXML iterateElementsForQuery:@"powerup" fromElement:powerupsXMLElement withBlock:^(TBXMLElement *powerupXMLElement) {
                    [self addPowerUp:[TBXML textForElement:[TBXML childElementNamed:@"file" parentElement:powerupXMLElement]]
                              atPosition:[[TBXML textForElement:[TBXML childElementNamed:@"atPosition" parentElement:powerupXMLElement]] floatValue]
                                isCircle:[[TBXML textForElement:[TBXML childElementNamed:@"isCircle" parentElement:powerupXMLElement]] boolValue]
                     ];
                }];
                
                [self scheduleUpdate];
            }

        }];

        
        if(self->currentLevel!=level){
            //end game
        }
        
    }
    return self;
}


-(void)addObstacle:(NSString*)file atPosition:(float)position isCircle:(BOOL)isCircle atFloorHeight:(BOOL) atFloorHeight{
    Obstacle * Ob=[Obstacle spriteWithFile:file];
    Ob.position = ccp(position, (atFloorHeight? FLOOR_HEGHT:0) +[Ob boundingBox].size.height/2);
    
    [Ob createBox2dObject:world isCircle:isCircle];
    [self addChild:Ob];
}

-(void)addCollectible:(NSString*)file atPosition:(float)position isCircle:(BOOL)isCircle {
    Collectible * Ob=[Collectible spriteWithFile:file];
    Ob.position = ccp(position,  FLOOR_HEGHT+250 +[Ob boundingBox].size.height/2);
    
    [Ob createBox2dObject:world isCircle:isCircle];
    [self addChild:Ob];
}

-(void)addPowerUp:(NSString*)file atPosition:(float)position isCircle:(BOOL)isCircle {
    PowerUp * Ob=[PowerUp spriteWithFile:file];
    Ob.position = ccp(position,  FLOOR_HEGHT+350 +[Ob boundingBox].size.height/2);
    
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
    ///*
    [super draw];
    
    ccGLEnableVertexAttribs( kCCVertexAttribFlag_Position );
    
    kmGLPushMatrix();
    
    world->DrawDebugData();
    
     kmGLPopMatrix();
//*/
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
                    [player moveRight];
                    player.collectibles++;
                    
                    [self updateCollectibleCounterLabel];
                }
            }
            // Sprite A = collectible, Sprite B = player
            else if (spriteA.tag == TAG_COLLECTIBLE && spriteB.tag == TAG_PLAYER) {
                if (std::find(toDestroy.begin(), toDestroy.end(), bodyA)
                    == toDestroy.end()) {
                    toDestroy.push_back(bodyA);
                    [player moveRight];
                    player.collectibles++;
                    
                    [self updateCollectibleCounterLabel];
                }
            }
            // Sprite A = OBSTACLE, Sprite B = player
            else if (spriteA.tag == TAG_OBSTACLE && spriteB.tag == TAG_PLAYER ){
                if(player.powerUps>0){
                    if (std::find(toDestroy.begin(), toDestroy.end(), bodyA)
                        == toDestroy.end()) {
                        [self Explosion:spriteA.position];
                        
                        toDestroy.push_back(bodyA);
                        [player moveRight];
                        player.powerUps--;
                        
                        [self updatePowerUpCounterLabel];
                    }
                }
                else
                    [self dieAction];
            }
            // Sprite A = player, Sprite B = OBSTACLE
            else if (spriteA.tag == TAG_PLAYER && spriteB.tag == TAG_OBSTACLE ) {
                if(player.powerUps>0){
                    if (std::find(toDestroy.begin(), toDestroy.end(), bodyB)
                        == toDestroy.end()) {
                        [self Explosion:spriteB.position];
                        
                        toDestroy.push_back(bodyB);
                        [player moveRight];
                        player.powerUps--;
                        
                        [self updatePowerUpCounterLabel];
                    }
                }
                else
                    [self dieAction];            }
            // Sprite A = player, Sprite B = powerup
            if (spriteA.tag == TAG_PLAYER && spriteB.tag == TAG_POWERUP) {
                if (std::find(toDestroy.begin(), toDestroy.end(), bodyB)
                    == toDestroy.end()) {
                    toDestroy.push_back(bodyB);
                    [player moveRight];
                    player.powerUps++;
                    
                    [self updatePowerUpCounterLabel];
                }
            }
            // Sprite A = powerup, Sprite B = player
            else if (spriteA.tag == TAG_POWERUP && spriteB.tag == TAG_PLAYER) {
                if (std::find(toDestroy.begin(), toDestroy.end(), bodyA)
                    == toDestroy.end()) {
                    toDestroy.push_back(bodyA);
                    [player moveRight];
                    player.powerUps++;
                    
                    [self updatePowerUpCounterLabel];
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
    CGPoint oldPos =[self position];
	CGPoint newPos = ccp(-1 * playerPos.x * PTM_RATIO + 120, self.position.y * PTM_RATIO);
	[self setPosition:newPos];
    
    
    //Background handling
    backgroundOffset += oldPos.x-newPos.x;
    CGSize textureSize = _background.textureRect.size;
    [_background setTextureRect:CGRectMake(backgroundOffset, 0, textureSize.width, textureSize.height)];
    _background.position = ccp([_background boundingBox].size.width/2+backgroundOffset, [_background boundingBox].size.height/2);
    
    
    if(abs(oldPos.x)>levelWidth-([_background boundingBox].size.width/2+1.0f)){
        [self scheduleOnce:@selector(restartLevel:) delay:2];
    }
}

-(void)dieAction{
    if([player isAlive]){
        [player die];
        [self Explosion:player.position];
        [self scheduleOnce:@selector(restartLevel:) delay:2];
    }
}


- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    int fingersUsed=[touches count];
    
    if(fingersUsed>1)
        [player jump:fingersUsed];
}



-(void) Explosion:(CGPoint)atPosition{
    
    CCSprite *spriteExplosion = [CCSprite spriteWithFile:@"explode.png" rect:CGRectMake(0,0,192,192)];
    [spriteExplosion setPosition:atPosition];
    [self addChild:spriteExplosion];
    
    NSMutableArray *explosionAnimFrames = [NSMutableArray array];
    for(int y=0;y<4;y++){
        for(int x=0;x<4;x++){
            [explosionAnimFrames addObject:[CCSpriteFrame
                                            frameWithTextureFilename:@"explode.png"
                                            rectInPixels:CGRectMake(x*192,y*192,192,192)
                                            rotated:NO offset:ccp(0,0)
                                            originalSize:CGSizeMake(192,192)
                                            ]];
       }
    }
    
    CCAnimation *frames=[CCAnimation
                         animationWithSpriteFrames:explosionAnimFrames
                         delay:1.0/16.0];
    
    [spriteExplosion runAction:[CCSequence  actions:[CCAnimate actionWithAnimation:frames],
                                [CCCallFuncN actionWithTarget:spriteExplosion selector:@selector(removeFromParentAndCleanup:)],
                                nil]];
    

}

-(void) restartLevel:(ccTime)dt
{
	[[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:dt scene:[WorldLayer level:self->currentLevel] withColor:ccWHITE]];
}

-(void) nextLevel:(ccTime)dt
{
	[[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:dt scene:[WorldLayer level:self->currentLevel+1] withColor:ccWHITE]];
}


-(void) createInterface
{
    CCParallaxNode *UI=[CCParallaxNode node];
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    //'menu'
    //pause button
    CCMenuItem *pauseItem = [CCMenuItemImage itemWithNormalImage:@"pause.png"
                                                     selectedImage:@"pause.png"];
    
    CCMenuItem *playItem = [CCMenuItemImage  itemWithNormalImage:@"play.png"
                                                       selectedImage:@"play.png"];
    
    CCMenuItemToggle *pauseToggler = [CCMenuItemToggle itemWithItems:[NSArray arrayWithObjects: pauseItem, playItem, nil]
                                                               block:^(id sender)
                                      {
                                          if([[CCDirector sharedDirector]isPaused]){
                                              [[CCDirector sharedDirector]resume];
                                              [[SimpleAudioEngine sharedEngine] resumeBackgroundMusic];
                                          }
                                          else{
                                           [[CCDirector sharedDirector]pause];
                                              [[SimpleAudioEngine sharedEngine] pauseBackgroundMusic];
                                          }
                                      }];
    
    
    
    CCMenu *menu = [CCMenu menuWithItems:pauseToggler, nil];
    [menu alignItemsVertically];
    //end 'menu'
    
    
    
    //powerUp counterLabel
    powerUpLabel=[CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d",player.powerUps] fontName:@"Helvetica" fontSize:24];
    [powerUpLabel setColor:(ccRED)];
    
    //collectible counterLabel
    collectibleLabel=[CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d",player.collectibles] fontName:@"Helvetica" fontSize:24];
    [collectibleLabel setColor:(ccRED)];
    
    CCSprite * powerUpLogo=[CCSprite spriteWithFile:@"powerup.png"];
    CCSprite * collectibleLogo=[CCSprite spriteWithFile:@"notes.png"];
    
    
    [UI addChild:menu z:7 parallaxRatio:ccp(0.0f,0.0f) positionOffset:ccp(winSize.width-pauseItem.boundingBox.size.width,pauseItem.boundingBox.size.height)];
    
    [UI addChild:powerUpLabel z:6 parallaxRatio:ccp(0.0f,0.0f) positionOffset:ccp(winSize.width-powerUpLabel.boundingBox.size.width*2,
                                                                                  winSize.height-powerUpLabel.boundingBox.size.height)];
    
    [UI addChild:powerUpLogo z:6 parallaxRatio:ccp(0.0f,0.0f) positionOffset:ccp(powerUpLabel.position.x- powerUpLogo.boundingBox.size.width,
                                                                                  winSize.height-powerUpLabel.boundingBox.size.height)];
    
    [UI addChild:collectibleLabel z:6 parallaxRatio:ccp(0.0f,0.0f) positionOffset:ccp(winSize.width-collectibleLabel.boundingBox.size.width*8,
                                                                                  winSize.height-collectibleLabel.boundingBox.size.height)];
    
    [UI addChild:collectibleLogo z:6 parallaxRatio:ccp(0.0f,0.0f) positionOffset:ccp(collectibleLabel.position.x- collectibleLogo.boundingBox.size.width,
                                                                                 winSize.height-powerUpLabel.boundingBox.size.height)];

    
    [self addChild: UI z:7];
}

-(void)updatePowerUpCounterLabel
{
    [powerUpLabel setString:[NSString stringWithFormat:@"%d",player.powerUps]] ;
}

-(void)updateCollectibleCounterLabel
{
    [collectibleLabel setString:[NSString stringWithFormat:@"%d",player.collectibles]] ;
}

@end