//
//  RTMAPI+Task.m
//  Milpon
//
//  Created by mootoh on 8/31/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import "RTMAPI.h"
#import "RTMAPI+Task.h"
#import "RTMAPIParserDelegate.h"
#import "MPLogger.h"

// -------------------------------------------------------------------
#pragma mark TaskGetListCallback
@interface TaskGetListCallback : RTMAPIParserDelegate
{
   enum state_t {
      TAG,
      NOTE,
      RRULE,
      DELETED
   } mode;

   NSMutableArray      *taskserieses;
   NSString            *list_id;
   NSMutableDictionary *taskseries;
   NSMutableSet        *tags;
   NSMutableArray      *notes;
   NSMutableArray      *taskEntries;
   NSMutableDictionary *note;
   NSMutableDictionary *rrule;
   NSString            *string;
}
@end // TaskGetListCallback

@implementation TaskGetListCallback

- (id) init
{
   if (self = [super init]) {
      taskserieses = [[NSMutableArray alloc] init];
      list_id      = nil;
      taskseries   = nil;
      tags         = nil;
      notes        = nil;
      taskEntries  = nil;
      note         = nil;
      rrule        = nil;
      string       = nil;
   }
   return self;
}

- (void) dealloc
{
   [taskserieses release];
   [super dealloc];
}

- (id) result
{
   return taskserieses;
}

/*
 * construct taskseries array of NSStrings.
 */
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{
   SUPER_PARSE;

   if ([elementName isEqualToString:@"tasks"]) {
      NSAssert(list_id == nil, @"state check");
      return;
   }
   if ([elementName isEqualToString:@"list"]) {
      list_id = [attributeDict valueForKey:@"id"];
      return;
   }
   if ([elementName isEqualToString:@"taskseries"]) {
      NSAssert(list_id != nil, @"state check");
      taskseries = [NSMutableDictionary dictionaryWithDictionary:attributeDict];
      [taskseries setObject:list_id forKey:@"list_id"];
      taskEntries = [NSMutableArray array];
      [taskseries setObject:taskEntries forKey:@"tasks"];
      [taskserieses addObject:taskseries];
      return;
   }
   if ([elementName isEqualToString:@"tags"]) {
      NSAssert(taskseries, @"should be in taskseries element");
      tags = [NSMutableSet set];
      [taskseries setObject:tags forKey:@"tags"];
      return;
   }
   if ([elementName isEqualToString:@"tag"]) {
      NSAssert(taskseries, @"should be in taskseries element");
      NSAssert(tags, @"should be in tags element");
      string = @"";
      mode = TAG;
      return;
   }
   if ([elementName isEqualToString:@"notes"]) {
      NSAssert(taskseries, @"should be in taskseries element");
      notes = [NSMutableArray array];
      [taskseries setObject:notes forKey:@"notes"];
      return;
   }
   if ([elementName isEqualToString:@"note"]) {
      NSAssert(taskseries, @"should be in taskseries element");
      NSAssert(notes, @"should be in notes element");
      mode = NOTE;
      note = [NSMutableDictionary dictionaryWithDictionary:attributeDict];
      string = @"";
      [notes addObject:note];
      return;
   }
   if ([elementName isEqualToString:@"rrule"]) {
      NSAssert(taskseries, @"should be in taskseries element");
      mode = RRULE;
      string = @"";
      rrule = [NSMutableDictionary dictionaryWithDictionary:attributeDict];
      return;
   }
   if ([elementName isEqualToString:@"task"]) {
      NSAssert(taskseries, @"should be in taskseries element");
      NSAssert(taskEntries, @"should be in taskseries element");
      [taskEntries addObject:attributeDict];
      return;
   }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
   if ([elementName isEqualToString:@"taskseries"]) {
      taskseries = nil;
      taskEntries = nil;
      return;
   }
   if ([elementName isEqualToString:@"tags"]) {
      tags = nil;
      return;
   }
   if ([elementName isEqualToString:@"tag"]) {
      NSAssert(tags, @"should be in tags");
      [tags addObject:string];
      string = nil;
      return;
   }
   if ([elementName isEqualToString:@"notes"]) {
      notes = nil;
      return;
   }
   if ([elementName isEqualToString:@"note"]) {
      if (! [string isEqualToString:@""])
         [note setObject:string forKey:@"text"];
      note = nil;
      string = nil;
      return;
   }
   if ([elementName isEqualToString:@"rrule"]) {
      if (string && ! [string isEqualToString:@""])
         [rrule setObject:string forKey:@"rule"];
      [taskseries setObject:rrule forKey:@"rrule"];
      string = nil;
      return;
   }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)chars
{
   NSAssert(string != nil, @"");
   string = [string stringByAppendingString:chars];
}

@end // TaskGetListCallback

/* -------------------------------------------------------------------
 * TaskListAddCallback
 */
@interface TaskAddCallback : RTMAPIParserDelegate
{
   NSMutableDictionary *addedTask;
   NSString *list_id;
}
@end

@implementation TaskAddCallback

- (id) init
{
   if (self = [super init]) {
      addedTask = nil;
      list_id = nil;
   }
   return self;
}

- (void) dealloc
{
   [super dealloc];
}

- (id) result
{
   return addedTask;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{
   SUPER_PARSE;

   if ([elementName isEqualToString:@"list"]) {
      list_id = [attributeDict valueForKey:@"id"];
      return;
   }
   if ([elementName isEqualToString:@"taskseries"]) {
      addedTask = [NSMutableDictionary dictionaryWithDictionary:attributeDict];
      [addedTask setObject:list_id forKey:@"list_id"];
      return;
   }
   if ([elementName isEqualToString:@"task"]) {
      [addedTask setObject:attributeDict forKey:@"task"];
      return;
   }
}
@end

/* -------------------------------------------------------------------
 * RTMAPITask
 */
@implementation RTMAPI (Task)

- (NSArray *) getList_internal:(NSDictionary *)args
{
   return [self call:@"rtm.tasks.getList" args:args delegate:[[[TaskGetListCallback alloc] init] autorelease]];
}

- (NSArray *) getTaskList
{
   return [self getList_internal:nil];
}

- (NSArray *) getTaskList:(NSString *)lastSync
{
   return [self getList_internal:[NSDictionary dictionaryWithObject:lastSync forKey:@"last_sync"]];
}

- (NSArray *) getTaskList:(NSString *)inListID filter:(NSString *)filter lastSync:(NSString *)lastSync
{
   NSMutableDictionary *args = [NSMutableDictionary dictionary];
   if (inListID)
      [args setObject:inListID forKey:@"list_id"];
   if (filter)
      [args setObject:filter forKey:@"filter"];
   if (lastSync)
      [args setObject:lastSync forKey:@"last_sync"];
   
   return [self getList_internal:args];
}

- (NSDictionary *) addTask:(NSString *)name list_id:(NSString *)list_id timeline:(NSString *)timeline
{
   NSArray             *keys = [NSArray arrayWithObjects:@"name", @"timeline", nil];
   NSArray             *vals = [NSArray arrayWithObjects:name, timeline, nil];
   NSMutableDictionary *args = [NSMutableDictionary dictionaryWithObjects:vals forKeys:keys];
   if (list_id)
      [args setObject:list_id forKey:@"list_id"];
   
   return [self call:@"rtm.tasks.add" args:args delegate:[[[TaskAddCallback alloc] init] autorelease]];
}

- (void) deleteTask:(NSString *)task_id taskseries_id:(NSString *)taskseries_id list_id:(NSString *)list_id timeline:(NSString *)timeLine
{
   NSArray      *keys = [NSArray arrayWithObjects:@"list_id", @"taskseries_id", @"task_id", @"timeline", nil];
   NSArray      *vals = [NSArray arrayWithObjects:list_id, taskseries_id, task_id, timeLine, nil];
   NSDictionary *args = [NSDictionary dictionaryWithObjects:vals forKeys:keys];

   [self call:@"rtm.tasks.delete" args:args delegate:[[[RTMAPIParserDelegate alloc] init] autorelease]];
}

- (void) setTaskDueDate:(NSString *)due timeline:(NSString *)timeline list_id:(NSString *)list_id taskseries_id:(NSString *)taskseries_id task_id:(NSString *)task_id has_due_time:(BOOL)has_due_time parse:(BOOL)parse
{
   NSArray             *keys = [NSArray arrayWithObjects:@"list_id", @"taskseries_id", @"task_id", @"timeline", @"due", nil];
   NSArray             *vals = [NSArray arrayWithObjects:list_id, taskseries_id, task_id, timeline, due, nil];
   NSMutableDictionary *args = [NSMutableDictionary dictionaryWithObjects:vals forKeys:keys];
   if (has_due_time)
      [args setObject:@"1" forKey:@"has_due_time"];
   if (parse)
      [args setObject:@"1" forKey:@"parse"];

   [self call:@"rtm.tasks.setDueDate" args:args delegate:[[[RTMAPIParserDelegate alloc] init] autorelease]];
}

- (void) setTaskLocation:(NSString *)location_id timeline:(NSString *)timeline list_id:(NSString *)list_id taskseries_id:(NSString *)taskseries_id task_id:(NSString *)task_id
{
   NSArray      *keys = [NSArray arrayWithObjects:@"list_id", @"taskseries_id", @"task_id", @"timeline", @"location_id", nil];
   NSArray      *vals = [NSArray arrayWithObjects:list_id, taskseries_id, task_id, timeline, location_id, nil];
   NSDictionary *args = [NSDictionary dictionaryWithObjects:vals forKeys:keys];
   
   [self call:@"rtm.tasks.setLocation" args:args delegate:[[[RTMAPIParserDelegate alloc] init] autorelease]];
}

- (void) setTaskPriority:(NSString *)priority timeline:(NSString *)timeline list_id:(NSString *)list_id taskseries_id:(NSString *)taskseries_id task_id:(NSString *)task_id
{
   NSArray      *keys = [NSArray arrayWithObjects:@"list_id", @"taskseries_id", @"task_id", @"timeline", @"priority", nil];
   NSArray      *vals = [NSArray arrayWithObjects:list_id, taskseries_id, task_id, timeline, priority, nil];
   NSDictionary *args = [NSDictionary dictionaryWithObjects:vals forKeys:keys];

   [self call:@"rtm.tasks.setPriority" args:args delegate:[[[RTMAPIParserDelegate alloc] init] autorelease]];
}

- (void) setTaskEstimate:(NSString *)estimate timeline:(NSString *)timeline list_id:(NSString *)list_id taskseries_id:(NSString *)taskseries_id task_id:(NSString *)task_id
{
   NSArray      *keys = [NSArray arrayWithObjects:@"list_id", @"taskseries_id", @"task_id", @"timeline", @"estimate", nil];
   NSArray      *vals = [NSArray arrayWithObjects:list_id, taskseries_id, task_id, timeline, estimate, nil];
   NSDictionary *args = [NSDictionary dictionaryWithObjects:vals forKeys:keys];
   
   [self call:@"rtm.tasks.setEstimate" args:args delegate:[[[RTMAPIParserDelegate alloc] init] autorelease]];
}

- (void) completeTask:(NSString *)task_id taskseries_id:(NSString *)taskseries_id list_id:(NSString *)list_id timeline:(NSString *)timeline
{
   NSArray      *keys = [NSArray arrayWithObjects:@"list_id", @"taskseries_id", @"task_id", @"timeline", nil];
   NSArray      *vals = [NSArray arrayWithObjects:list_id, taskseries_id, task_id, timeline, nil];
   NSDictionary *args = [NSDictionary dictionaryWithObjects:vals forKeys:keys];
   
   [self call:@"rtm.tasks.complete" args:args delegate:[[[RTMAPIParserDelegate alloc] init] autorelease]];
}

- (void) uncompleteTask:(NSString *)task_id taskseries_id:(NSString *)taskseries_id list_id:(NSString *)list_id timeline:(NSString *)timeline
{
   NSArray      *keys = [NSArray arrayWithObjects:@"list_id", @"taskseries_id", @"task_id", @"timeline", nil];
   NSArray      *vals = [NSArray arrayWithObjects:list_id, taskseries_id, task_id, timeline, nil];
   NSDictionary *args = [NSDictionary dictionaryWithObjects:vals forKeys:keys];
   
   [self call:@"rtm.tasks.uncomplete" args:args delegate:[[[RTMAPIParserDelegate alloc] init] autorelease]];
}

- (void) setTaskTags:(NSString *)tags task_id:(NSString *)task_id taskseries_id:(NSString *)taskseries_id list_id:(NSString *)list_id timeline:(NSString *)timeline
{
   NSArray             *keys = [NSArray arrayWithObjects:@"list_id", @"taskseries_id", @"task_id", @"timeline", nil];
   NSArray             *vals = [NSArray arrayWithObjects:list_id, taskseries_id, task_id, timeline, nil];
   NSMutableDictionary *args = [NSMutableDictionary dictionaryWithObjects:vals forKeys:keys];
   if (tags)
      [args setObject:tags forKey:@"tags"];
   
   [self call:@"rtm.tasks.setTags" args:args delegate:[[[RTMAPIParserDelegate alloc] init] autorelease]];
}

- (void) moveTaskTo:(NSString *)to_list_id from_list_id:(NSString *)from_list_id task_id:(NSString *)task_id taskseries_id:(NSString *)taskseries_id  timeline:(NSString *)timeline
{
   NSArray      *keys = [NSArray arrayWithObjects:@"to_list_id", @"from_list_id", @"taskseries_id", @"task_id", @"timeline", nil];
   NSArray      *vals = [NSArray arrayWithObjects:to_list_id, from_list_id, taskseries_id, task_id, timeline, nil];
   NSDictionary *args = [NSMutableDictionary dictionaryWithObjects:vals forKeys:keys];

   [self call:@"rtm.tasks.moveTo" args:args delegate:[[[RTMAPIParserDelegate alloc] init] autorelease]];
}

- (void) setTaskName:(NSString *)name timeline:(NSString *)timeline list_id:(NSString *)list_id taskseries_id:(NSString *)taskseries_id task_id:(NSString *)task_id
{
   NSAssert(name, @"name is required");

   NSArray      *keys = [NSArray arrayWithObjects:@"list_id", @"taskseries_id", @"task_id", @"timeline", @"name", nil];
   NSArray      *vals = [NSArray arrayWithObjects:list_id, taskseries_id, task_id, timeline, name, nil];
   NSDictionary *args = [NSDictionary dictionaryWithObjects:vals forKeys:keys];

   [self call:@"rtm.tasks.setName" args:args delegate:[[[RTMAPIParserDelegate alloc] init] autorelease]];
}

- (void) setRecurrence:(NSString *)recurrence timeline:(NSString *)timeline list_id:(NSString *)list_id taskseries_id:(NSString *)taskseries_id task_id:(NSString *)task_id
{
   NSArray             *keys = [NSArray arrayWithObjects:@"list_id", @"taskseries_id", @"task_id", @"timeline", nil];
   NSArray             *vals = [NSArray arrayWithObjects:list_id, taskseries_id, task_id, timeline, nil];
   NSMutableDictionary *args = [NSMutableDictionary dictionaryWithObjects:vals forKeys:keys];

   if (recurrence)
      [args setObject:recurrence forKey:@"repeat"];

   [self call:@"rtm.tasks.setRecurrence" args:args delegate:[[[RTMAPIParserDelegate alloc] init] autorelease]];
}

@end