//
//  IntroLayer.m
//  runner
//
//  Created by Sven Holmgren on 11/27/12.
//


// Import the interfaces
#import "IntroLayer.h"
#import "WorldLayer.h"
static const ccColor3B ccDARKRED={139,0,0};

#pragma mark - IntroLayer

// WorldLayer implementation
@implementation IntroLayer

// Helper class method that creates a Scene with the WorldLayer as the only child.
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	IntroLayer *layer = [IntroLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// 
-(void) onEnter
{
	[super onEnter];

    //music
    [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"mrbasket.mp3"];
    
	// ask director for the window size
	CGSize size = [[CCDirector sharedDirector] winSize];

	CCSprite *background;
	
    
	if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ) {
		background = [CCSprite spriteWithFile:@"Default.png"];
        background.rotation=-90;
	} else {
		background = [CCSprite spriteWithFile:@"Default-Landscape~ipad.png"];
	}
	background.position = ccp(size.width/2, size.height/2);

	// add the label as a child to this Layer
	[self addChild: background];
    
    [self createMenu];
	
}

-(void) createMenu
{
    // Play Button
    [CCMenuItemFont setFontSize:22];
    CCMenuItemLabel *play = [CCMenuItemFont itemWithString:@"Play" block:^(id sender){
        [self scheduleOnce:@selector(makeTransition:) delay:1];
    }];
    [play setColor:(ccDARKRED)];
    
    
    //sound button
    CCMenuItem *soundOnItem = [CCMenuItemImage itemWithNormalImage:@"unmuted.png"
                                                     selectedImage:@"unmuted.png"];
    
    CCMenuItem *soundOffItem = [CCMenuItemImage  itemWithNormalImage:@"muted.png"
                                                      selectedImage:@"muted.png"];
   
    CCMenuItemToggle *soundToggler = [CCMenuItemToggle itemWithItems:[NSArray arrayWithObjects: soundOnItem, soundOffItem, nil]
                                                               block:^(id sender)
    {
        [[SimpleAudioEngine sharedEngine] setMute:![SimpleAudioEngine sharedEngine].mute];
    }];

    
    
    CCMenu *menu = [CCMenu menuWithItems:play,soundToggler, nil];
    
    [menu alignItemsVertically];
    
    CGSize size = [[CCDirector sharedDirector] winSize];
    [menu setPosition:ccp( size.width/2, size.height/4)];
    
    
    [self addChild: menu ];
}

-(void) makeTransition:(ccTime)dt
{
	[[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:dt scene:[WorldLayer level:1] withColor:ccWHITE]];
}

@end
