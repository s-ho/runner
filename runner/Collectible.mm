//
//  Collectible.m
//  runner
//
//  Created by Sven Holmgren on 1/8/13.
//

#import "Collectible.h"

@implementation Collectible

- (id) init {
    self = [super init];
    
    if (self) {
        self.tag=TAG_PLAYER;
    }
    
    return self;
}

@end
