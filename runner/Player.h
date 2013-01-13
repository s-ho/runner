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
}

-(void) createBox2dObject:(b2World*)world;
-(void) jump;
-(void) moveRight;
-(void) die;

@property (nonatomic, readwrite) b2Body *body;

@end