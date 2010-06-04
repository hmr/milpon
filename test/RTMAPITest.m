//
//  RTMAPITest.m
//  Milpon
//
//  Created by mootoh on 8/30/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "logger.h"
#import "PrivateInfo.h"
#import "RTMAPI.h"
#import "MockRTMAPI.h"
#import "RTMAuth.h"
#import "RTMAPIXMLParserCallback.h"

#define TEST_FROB @"ec1d083b2e10b554e6c90487328d65ba9312d6e5"

// --------------------------------------------------------------
#pragma mark -
#pragma mark RTM Test API
// --------------------------------------------------------------

@interface TestDelegate : NSObject <RTMAPIDelegate>
{
   NSMutableDictionary *response;
   NSString *key;
}
@end

@implementation TestDelegate

- (id) init
{
   if (self = [super init]) {
      response = [[NSMutableDictionary alloc] init];
      key = nil;
   }
   return self;
}

- (void) dealloc
{
   [response release];
   [key release];
   [super dealloc];
}

- (id) result
{
   return response;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
   if (! [elementName isEqualToString:@"rsp"])
      key = [elementName retain];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
   [key release];
   key = nil;
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)chars
{
   [response setObject:chars forKey:key];
}

@end


@interface RTMAPI (Test)
- (NSDictionary *)echo:(NSDictionary *)args;
- (NSDictionary *)login;
@end

@implementation RTMAPI (Test)

- (NSDictionary *)echo:(NSDictionary *)args
{
   NSDictionary *echoed = [self call:@"rtm.test.echo" args:args withDelegate:[[[TestDelegate alloc] init] autorelease]];
   return echoed;
}

- (NSDictionary *)login
{
   return nil;
}

@end

// --------------------------------------------------------------
#pragma mark -
#pragma mark RTMAPITest
// --------------------------------------------------------------
@interface RTMAPITest : SenTestCase
{
   RTMAPI *api;
}
@end

@implementation RTMAPITest

- (void) setUp
{
   api  = [[RTMAPI alloc] init];
}

- (void) tearDown
{
   [api release];
}

- (void) testToken
{
   STAssertNil(api.token, @"token should not be defined");
   api.token = @"hoge";
   STAssertNotNil(api.token, @"token should be loaded");
}

- (void) testEcho
{
   NSDictionary *echoed = [api echo:[NSDictionary dictionaryWithObject:@"bar" forKey:@"foo"]];
   STAssertTrue([[echoed objectForKey:@"api_key"] isEqualToString:RTM_API_KEY], @"");
   STAssertTrue([[echoed objectForKey:@"method"] isEqualToString:@"rtm.test.echo"], @"");
   STAssertTrue([[echoed objectForKey:@"foo"] isEqualToString:@"bar"], @"");
}

#if 0
- (void) testCall
{
   NSArray *keys = [NSArray arrayWithObjects:@"one", @"two", nil];
   NSArray *vals = [NSArray arrayWithObjects:@"1", @"2", nil];
   NSDictionary *args = [NSDictionary dictionaryWithObjects:vals
      forKeys:keys];

   NSData *ret = [api call:@"rtm.test.echo" withArgs:args];
   NSLog(@"test.echo returns %@", [[[NSString alloc] initWithData:ret encoding:NSUTF8StringEncoding] autorelease]);
   NSXMLParser *parser = [[[NSXMLParser alloc] initWithData:ret] autorelease];
   RTMAPIXMLParserCallback *callback = [[[RTMAPIXMLParserCallback alloc] init] autorelease];
   [parser setDelegate:callback];
   [parser parse];
   STAssertTrue(callback.succeeded, @"check call");
   STAssertNil(callback.error, @"check call");
}

- (void) _testError
{
   NSArray *keys = [NSArray arrayWithObjects:@"one", @"two", nil];
   NSArray *vals = [NSArray arrayWithObjects:@"1", @"2", nil];
   NSDictionary *args = [NSDictionary dictionaryWithObjects:vals
      forKeys:keys];

   NSData *ret = [api call:@"rtm.test.echoException" withArgs:args];
   NSLog(@"test.echo returns %@", [[[NSString alloc] initWithData:ret encoding:NSUTF8StringEncoding] autorelease]);
   NSXMLParser *parser = [[[NSXMLParser alloc] initWithData:ret] autorelease];
   RTMAPIXMLParserCallback *callback = [[[RTMAPIXMLParserCallback alloc] init] autorelease];
   [parser setDelegate:callback];
   [parser parse];
   STAssertFalse(callback.succeeded, @"api request should fail in invalid method.");
   STAssertNotNil(callback.error, @"error should be set");
   NSLog(@"error = %@", [callback.error localizedDescription]);
}

- (void) not_testAuthURL
{
   NSString *url = [api authURL:TEST_FROB forPermission:@"delete"];
   STAssertNotNil(url, @"check auth url");
   NSLog(@"auth url = %@", url);
}

- (void) testCreateTimeline
{
   NSString *timeline = [api createTimeline];
   STAssertNotNil(timeline, @"check timeline");
   NSLog(@"timeline = %@", timeline);
}
#endif // 0
@end