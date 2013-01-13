//
//  Obstacle.h
//  runner
//
//  Created by Sven Holmgren on 1/9/13.
//
//
#import "GameObject.h"
#import "WorldLayer.h"

@interface Obstacle : GameObject {
    b2Body *body;
}
-(void) createBox2dObject:(b2World*)world isCircle:(BOOL) isCircle;

@property (nonatomic, readwrite) b2Body *body;

@end
