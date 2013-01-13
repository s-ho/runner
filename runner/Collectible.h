//
//  Collectible.h
//  runner
//
//  Created by Sven Holmgren on 1/8/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "GameObject.h"
#import "WorldLayer.h"

@interface Collectible : GameObject {
    b2Body *body;
}
-(void) createBox2dObject:(b2World*)world isCircle:(BOOL) isCircle; 

@property (nonatomic, readwrite) b2Body *body;

@end
