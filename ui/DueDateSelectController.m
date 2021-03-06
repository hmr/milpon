//
//  TrialDueDateSelectController.m
//  Milpon
//
//  Created by mootoh on 1/26/09.
//  Copyright 2009 deadbeaf.org. All rights reserved.
//

#import "DueDateSelectController.h"
#import "UICCalendarPicker.h"


@implementation DueDateSelectController

enum {
   ROW_TODAY    = 0,
   ROW_TOMORROW = 1,
   ROW_CALENDAR = 2
};

@synthesize parent;

// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
       calendar_picker = [[UICCalendarPicker alloc] initWithSize:UICCalendarPickerSizeExtraLarge];
       calendar_picker.delegate = self;
       self.title = @"Due Date";
    }
    return self;
}

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
   return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
   return 3;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   
   static NSString *CellIdentifier = @"TrialDueDateSelect";
   
   UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
   if (cell == nil) {
      cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
   }
   
   switch (indexPath.row) {
      case ROW_TODAY:
         cell.textLabel.text = @"Today";
         break;
      case ROW_TOMORROW:
         cell.textLabel.text = @"Tomorrow";
         break;
      case ROW_CALENDAR:
         [calendar_picker showInView:cell.contentView animated:NO];
         break;
      default:
         break;
   }
   return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
   switch (indexPath.row) {
      case ROW_TODAY:
         [self.parent setDue:[NSDate date]];
         break;
      case ROW_TOMORROW: {
         NSDate *now = [NSDate date];
         NSDateComponents *comps = [[NSDateComponents alloc] init];
         [comps setDay:1];
         NSDate *date = [[NSCalendar currentCalendar] dateByAddingComponents:comps toDate:now  options:0];
         [comps release];
         [self.parent setDue:date];
         break;
      }
      case ROW_CALENDAR:
         [tableView deselectRowAtIndexPath:indexPath animated:NO];
         return;
      default:
         break;
   }
         
   [self.navigationController popViewControllerAnimated:YES];
   [self.parent updateView]; // TODO: should reload due row only.
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
   return (indexPath.row == 2) ? 340.0f : 44.0f;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
   [calendar_picker release];
   [super dealloc];
}

- (void) setDate:(NSDate *) date
{
   [calendar_picker addSelectedDate:date];
}

- (void) picker:(UICCalendarPicker *)picker didSelectDate:(NSArray *)selectedDate
{
   if (selectedDate == nil) return;
   [self.parent setDue:[selectedDate objectAtIndex:0]];
   [self.navigationController popViewControllerAnimated:YES];
   [self.parent updateView]; // TODO: should reload due row only.
}

@end
