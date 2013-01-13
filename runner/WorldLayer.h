//
//  WorldLayer.h
//  runner
//
//  Created by Sven Holmgren on 11/27/12.


#import <GameKit/GameKit.h>
#import "cocos2d.h"
#import "Box2D.h"
#import "GLES-Render.h"
#import "ContactListener.h"
#import "Player.h"
#import "Collectible.h"
#import "Obstacle.h"
#import "PowerUp.h"
#import "TBXML.h"
#import "SimpleAudioEngine.h"
#import "IntroLayer.h"

//Pixel to metres ratio. Box2D uses metres as the unit for measurement.
//This ratio defines how many pixels correspond to 1 Box2D "metre"
#define PTM_RATIO 32
#define FLOOR_HEGHT 10.0f
#define PLAYER_SPEED 10.0f



#define TAG_PLAYER 1
#define TAG_COLLECTIBLE 2
#define TAG_OBSTACLE 3
#define TAG_POWERUP 4


@interface WorldLayer : CCLayer 
{
	CCTexture2D *spriteTexture_;	// weak ref
	b2World* world;					// strong ref
	//GLESDebugDraw *m_debugDraw;		// strong ref
    
    
    Player *player;
    ContactListener *_contactListener;
    CCSprite * _background;
    
    int currentLevel;
    float backgroundOffset;
    
    float levelWidth;
    
    
    TBXML * tbxml;
    
    CCLabelTTF *powerUpLabel;
    CCLabelTTF *collectibleLabel;
    
}

// returns a CCScene that contains the WorldLayer as the only child
+(CCScene *) level:(int)level;


-(void) Explosion:(CGPoint)atPosition;

@end
