//
//  PowerUp.h
//  runner
//
//  Created by Sven Holmgren on 1/13/13.
//
//

#import "GameObject.h"
#import "WorldLayer.h"

@interface PowerUp : GameObject {
    b2Body *body;
}
-(void) createBox2dObject:(b2World*)world isCircle:(BOOL) isCircle;

@property (nonatomic, readwrite) b2Body *body;

@end