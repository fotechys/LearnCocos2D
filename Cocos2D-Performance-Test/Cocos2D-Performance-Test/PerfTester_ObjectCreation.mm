//
//  PerfTester
//
//  Copyright 2007-2008 Mike Ash
//					http://mikeash.com/pyblog/performance-comparisons-of-common-operations.html
//					http://mikeash.com/pyblog/performance-comparisons-of-common-operations-leopard-edition.html
//					http://mikeash.com/pyblog/performance-comparisons-of-common-operations-iphone-edition.html
//	Copyright 2010 Manomio / Stuart Carnie  (iOS port)
//					http://aussiebloke.blogspot.com/2010/01/micro-benchmarking-2nd-3rd-gen-iphones.html
//	Copyright 2011 Steffen Itterheim (Improvements, Cocos2D Tests)
//					http://www.learn-cocos2d.com/blog
//


#import "PerfTester.h"

@implementation PerfTester (ObjectCreation)

- (void)testPoolCreation
{
    BEGIN( k10MMIterationTestCount )
	[[[NSAutoreleasePool alloc] init] release];
    END()
}

- (void)testNSObjectCreation
{
    BEGIN( k10MMIterationTestCount )
	[[[NSObject alloc] init] release];
    END()
}

- (void)testCCNodeCreation
{
    BEGIN( k10MMIterationTestCount )
	[[[CCNode alloc] init] release];
    END()
}

static int iterCount = 0;

- (void)testCCSpriteWithFileCreation
{
	// cache the texture
	[[CCTextureCache sharedTextureCache] addImage:@"Icon.png"];
	
    BEGIN( k1MMIterationTestCount )
	iterCount++;
	[[[CCSprite alloc] initWithFile:@"Icon.png"] release];
    END()
	
	NSLog(@"number of iterations: %i", iterCount);
	iterCount = 0;
}

void createCCSprite(void* data)
{
	//NSLog(@"async_f thread: %@", [NSThread currentThread]);
	[[[CCSprite alloc] initWithFile:@"Icon.png"] release];
	iterCount++;
}

- (void)testCCSpriteWithFileCreationConcurrentlyWithGCD
{
	// cache the texture
	[[CCTextureCache sharedTextureCache] addImage:@"Icon.png"];
	
    BEGIN( 1 )
	if (YES)
	{
		dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
		void (^CreateSpriteApply)(size_t index) = ^(size_t index){ 
			//NSLog(@"apply thread: %@", [NSThread currentThread]);
			[[[CCSprite alloc] initWithFile:@"Icon.png"] release]; 
			iterCount++;
		};
		
		dispatch_apply(k1MMIterationTestCount, queue, CreateSpriteApply);
	}
	else
	{
		dispatch_queue_t queue1 = dispatch_queue_create("first", NULL);
		dispatch_queue_t queue2 = dispatch_queue_create("second", NULL);
		dispatch_group_t group = dispatch_group_create();
		void (^CreateSprite)() = ^(void){
			//NSLog(@"async thread: %@", [NSThread currentThread]);
			[[[CCSprite alloc] initWithFile:@"Icon.png"] release];
			iterCount++;
		};
		
		int loopCount = k1MMIterationTestCount / 2;
		for (int j = 1; j <= loopCount; j++)
		{
			//dispatch_group_async(group, queue1, CreateSprite);
			//dispatch_group_async(group, queue2, CreateSprite);
			dispatch_group_async_f(group, queue1, NULL, createCCSprite);
			dispatch_group_async_f(group, queue2, NULL, createCCSprite);
		}
		dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
		
		dispatch_release(group);
		dispatch_release(queue1);
		dispatch_release(queue2);
	}
    END()

	NSLog(@"number of iterations: %i", iterCount);
	iterCount = 0;
}

-(void) testCCLabelBMFontWithStringCreation
{
    BEGIN( k100KIterationTestCount )
	[[[CCLabelBMFont alloc] initWithString:@"Hello World!" fntFile:@"Arial14.fnt"] release];
    END()
}

- (void)testCCLabelTTFWithStringCreation
{
    BEGIN( k100KIterationTestCount )
	[[[CCLabelTTF alloc] initWithString:@"Hello World!" fontName:@"Arial" fontSize:14] release];
    END()
}

- (void)testCCMoveToCreation
{
    BEGIN( k100KIterationTestCount )
	[[[CCMoveTo alloc] initWithDuration:3 position:CGPointMake(123, 234)] release];
    END()
}

- (void)testCCSequenceCreation
{
	id move1 = [CCMoveTo actionWithDuration:3 position:CGPointMake(100, 100)];
	id move2 = [CCMoveTo actionWithDuration:3 position:CGPointMake(100, 100)];
	
    BEGIN( k100KIterationTestCount )
	[[[CCSequence alloc] initOne:move1 two:move2] release];
    END()
}

- (void)testCCParticleSystemQuadSmallCreation
{
    BEGIN( k1KIterationTestCount )
	[[[CCParticleSystemQuad alloc] initWithTotalParticles:25] release];
    END()
}

- (void)testCCParticleSystemQuadLargeCreation
{
    BEGIN( k100IterationTestCount )
	[[[CCParticleSystemQuad alloc] initWithTotalParticles:250] release];
    END()
}

- (void)testCCTMXTiledMapSmallCreation
{
	// cache the texture
	[[CCTextureCache sharedTextureCache] addImage:@"dg_grounds32.png"];

    BEGIN( k100IterationTestCount )
	[[[CCTMXTiledMap alloc] initWithTMXFile:@"tilemap-small.tmx"] release];
    END()
}
- (void)testCCTMXTiledMapLargeCreation
{
	// cache the texture
	[[CCTextureCache sharedTextureCache] addImage:@"dg_grounds32.png"];
	
    BEGIN( k10IterationTestCount )
	[[[CCTMXTiledMap alloc] initWithTMXFile:@"tilemap-large.tmx"] release];
    END()
}
- (void)testCCTMXTiledMapGiganticCreation
{
	// cache the texture
	[[CCTextureCache sharedTextureCache] addImage:@"dg_grounds32.png"];
	
    BEGIN( k10IterationTestCount )
	[[[CCTMXTiledMap alloc] initWithTMXFile:@"tilemap-gigantic.tmx"] release];
    END()
}


@end
