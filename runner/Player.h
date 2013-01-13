//
// Player.h
// runner
//
// Created by Sven Holmgren on 1/6/13.
//

#import "cocos2d.h"
#import "Box2D.h"
#import "CCSprite.h"
#import "GameObject.h"

@interface Player : GameObject{
    b2Body *body;
    
    bool isAlive;
    int powerUps;
    int collectibles;
}

-(void) createBox2dObject:(b2World*)world;
-(void) jump:(int)power;
-(void) moveRight;
-(void) die;

@property (nonatomic, readwrite) b2Body *body;
@property (readonly) bool isAlive;
@property (readwrite) int powerUps;
@property (readwrite) int collectibles;

@end