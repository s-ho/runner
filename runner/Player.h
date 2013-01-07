//
// Player.h
// runner
//
// Created by Sven Holmgren on 1/6/13.
//
//
#import "cocos2d.h"
#import "Box2D.h"
#import "CCSprite.h"

@interface Player : CCSprite{
    b2Body *body;
    
}

-(void) createBox2dObject:(b2World*)world;
-(void) jump;
-(void) moveRight;


@property (nonatomic, readwrite) b2Body *body;

@end