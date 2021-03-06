//
//  TaskTest.m
//  Milpon
//
//  Created by mootoh on 9/6/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "RTMAPI.h"
#import "RTMTask.h"
#import "RTMTag.h"
#import "RTMNote.h"
#import "TaskProvider.h"
#import "MilponHelper.h"

@interface TaskTest : SenTestCase
{
   TaskProvider *tp;
}
@end

@implementation TaskTest

- (void) setUp
{
   tp = [TaskProvider sharedTaskProvider];
}

- (void) testTasks
{
   NSArray *tasks = [tp tasks:YES];
   STAssertEquals(tasks.count, 3U, @"should have some task elements.");
}

- (void) testPriority
{
   NSArray *tasks = [tp tasks:YES];
   RTMTask *taskOne = [tasks objectAtIndex:0];
   STAssertEquals(taskOne.priority, [NSNumber numberWithInteger:0], @"priority check");
   STAssertEquals(taskOne.edit_bits, 0, @"edit bits should flagged up");

   taskOne.priority = [NSNumber numberWithInteger:1];
   STAssertEquals(taskOne.priority, [NSNumber numberWithInteger:1], @"priority changed");
   STAssertEquals(taskOne.edit_bits, EB_TASK_PRIORITY, @"edit bits should flagged up");
}

- (void) testAttributes
{
   NSArray *tasks = [tp tasks:YES];
   RTMTask *first_task = [tasks objectAtIndex:0];

   STAssertEquals(first_task.iD, 1, @"check attr");
   STAssertTrue([first_task.name isEqualToString:@"task one"], @"check attr");
   STAssertNil(first_task.url, @"check attr");
   STAssertEquals([first_task.priority intValue], 0, @"check attr");
   STAssertEquals([first_task.postponed intValue], 0, @"check attr");
   STAssertNil(first_task.estimate, @"check attr");
   STAssertNil(first_task.rrule, @"check attr");
   STAssertEquals([first_task.list_id intValue], 1, @"check attr");
   STAssertEquals([first_task.location_id intValue], 1, @"check attr");
   STAssertEquals(first_task.edit_bits, 0, @"check attr");

   RTMTask *second_task = [tasks objectAtIndex:1];
   STAssertTrue([second_task.due isEqualToDate:[[MilponHelper sharedHelper] stringToDate:@"2009-12-31 23:59:59"]], @"check attr");

   RTMTask *third_task = [tasks objectAtIndex:2];
   STAssertTrue([third_task.completed isEqualToDate:[[MilponHelper sharedHelper] stringToDate:@"2009-03-31 23:59:59"]], @"check attr");

   STAssertEquals(first_task.tags.count, 1U, @"check tags");
}

- (void) testTasksInList
{
   NSArray *tasks = [tp tasksInList:1 showCompleted:YES];
   STAssertEquals([tasks count], 3U, @"3 tasks should exist in list_id=1.");
}

- (void) testTasksInTags
{
   NSArray *tasks = [tp tasksInTag:1 showCompleted:YES];
   STAssertEquals(tasks.count, 1U, @"should have some task elements in a index tag #1");
}

- (void) testZZZComplete
{
   NSUInteger completedCountBefore = [tp tasks:NO].count;
   RTMTask *taskOne = [[tp tasks:YES] objectAtIndex:0];

   [taskOne complete];
   STAssertTrue([taskOne is_completed], @"should be completed");
   NSUInteger completedCountAfter = [tp tasks:NO].count;
   STAssertEquals(completedCountAfter, completedCountBefore-1, @"completion check");
}

- (void) testZZZUncomplete
{
   NSUInteger completedCountBefore = [tp tasks:NO].count;
   RTMTask *taskTwo = [[tp tasks:YES] objectAtIndex:1];

   // complete first
   [taskTwo complete];
   STAssertTrue([taskTwo is_completed], @"should be completed");
   NSUInteger completedCountMiddle = [tp tasks:NO].count;
   STAssertEquals(completedCountMiddle, completedCountBefore-1, @"completion check");

   // then uncomplete
   [taskTwo uncomplete];
   STAssertFalse([taskTwo is_completed], @"should not be completed");
   NSUInteger completedCountFinally = [tp tasks:NO].count;
   STAssertEquals(completedCountFinally, completedCountMiddle+1, @"uncompletion check");
}

- (void) testNotes
{
   RTMTask *first_task = [[tp tasks:YES] objectAtIndex:0];
   NSArray *notes = first_task.notes;
   STAssertTrue(notes.count > 0, @"notes should be exist");
}

- (void) testTags
{
   RTMTask *first_task = [[tp tasks:YES] objectAtIndex:0];
   NSArray *tags = first_task.tags;
   STAssertTrue(tags.count > 0, @"tags should be exist");
}

@end
