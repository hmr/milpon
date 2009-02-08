//
//  TrialAddTaskViewController.m
//  Milpon
//
//  Created by mootoh on 1/20/09.
//  Copyright 2009 deadbeaf.org. All rights reserved.
//

#import "AddTaskViewController.h"
#import "NoteEditController.h"
#import "ListSelectController.h"
#import "DueDateSelectController.h"
#import "TagSelectController.h"

@implementation AddTaskViewController

enum {
   ROW_NAME = 0,
   ROW_DUE_PRIORITY,
   ROW_LIST,
   ROW_TAG,
   ROW_NOTE,
   ROW_COUNT
};

@synthesize list, due, tags, note;

- (id)initWithStyle:(UITableViewStyle)style
{
   if (self = [super initWithStyle:style]) {
      self.title = @"Add";
      self.list  = @"Inbox";
      self.tags  = [NSMutableSet set];
   }
   return self;
}

- (void)dealloc
{
   [priority_segment release];
   [due_button release];
   [text_input release];
   [super dealloc];
}

- (void) viewDidLoad
{
   self.tableView.rowHeight = 40;

   /*
    * Navigation buttons
    */
   UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
   self.navigationItem.leftBarButtonItem = cancelButton;
   [cancelButton release];

   UIBarButtonItem *submitButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save)];
   self.navigationItem.rightBarButtonItem = submitButton;
   [submitButton release];

   // task name
   text_input = [[UITextField alloc] initWithFrame:CGRectMake(30, 8, 300, 40)];
   [text_input setFont:[UIFont systemFontOfSize:20.0f]];
   text_input.placeholder = @"what to do...";
   
   // due button
   due_button = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
   due_button.frame = CGRectMake(8, 4, 84, 32);
   due_button.font = [UIFont systemFontOfSize:14];
   
   UIImage *iconImage = [[UIImage alloc] initWithContentsOfFile:
                         [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"icon_calendar.png"]];
   [due_button setImage:iconImage forState:UIControlStateNormal];
   [due_button addTarget:self action:@selector(selectDue) forControlEvents:UIControlEventTouchDown];
   [iconImage release];
   
   // setup priority segment
   NSArray *priority_items = [NSArray arrayWithObjects:@"-", @"3", @"2", @"1", nil];
   priority_segment = [[UISegmentedControl alloc] initWithFrame:CGRectMake(104, 4, CGRectGetWidth(self.view.frame)-104-10, 32)];
   for (int i=0; i<priority_items.count; i++)
      [priority_segment insertSegmentWithTitle:[priority_items objectAtIndex:i] atIndex:i animated:NO];
   
   priority_segment.selectedSegmentIndex = 0;
}

/*
 - (id)initWithStyle:(UITableViewStyle)style {
 // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
 if (self = [super initWithStyle:style]) {
 }
 return self;
 }
 */

/*
 - (void)viewDidLoad {
 [super viewDidLoad];
 
 // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
 // self.navigationItem.rightBarButtonItem = self.editButtonItem;
 }
 */

/*
 - (void)viewWillAppear:(BOOL)animated {
 [super viewWillAppear:animated];
 }
 */
/*
 - (void)viewDidAppear:(BOOL)animated {
 [super viewDidAppear:animated];
 }
 */
/*
 - (void)viewWillDisappear:(BOOL)animated {
 [super viewWillDisappear:animated];
 }
 */
/*
 - (void)viewDidDisappear:(BOOL)animated {
 [super viewDidDisappear:animated];
 }
 */

/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */

- (void)didReceiveMemoryWarning {
   [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
   // Release anything that's not essential, such as cached data
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
   return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
   return ROW_COUNT;
}

#define ICON_TAG 1
#define LABEL_TAG 2
#define NAME_CELL_IDENTIFIER @"NameCell"
#define DUE_PRIORITY_CELL_IDENTIFIER @"DuePriorityCell"
#define ICON_LABEL_CELL_IDENTIFIER @"IconLabelCell"

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   UITableViewCell *cell;
   switch (indexPath.row) {
      case ROW_NAME: {
         cell = [tableView dequeueReusableCellWithIdentifier:NAME_CELL_IDENTIFIER];
         if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:NAME_CELL_IDENTIFIER] autorelease];
            UIImageView *iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(8, 15, 16, 16)];
            UIImage *iconImage = [[UIImage alloc] initWithContentsOfFile:
                                  [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"icon_target.png"]];
            iconImageView.image = iconImage;
            [cell.contentView addSubview:iconImageView];

            [cell.contentView addSubview:text_input];
         }
         [text_input becomeFirstResponder];
         break;
      }
      case ROW_DUE_PRIORITY: {
         cell = [tableView dequeueReusableCellWithIdentifier:DUE_PRIORITY_CELL_IDENTIFIER];
         if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:DUE_PRIORITY_CELL_IDENTIFIER] autorelease];
            [cell.contentView addSubview:due_button];
            [cell.contentView addSubview:priority_segment];
         }
         if (self.due) {
            NSDateFormatter *date_formatter = [[NSDateFormatter alloc] init];
            date_formatter.dateFormat = @" MM/dd";
            
            NSString *due_string = [date_formatter stringFromDate:self.due];
            [due_button setTitle:due_string forState:UIControlStateNormal];
            [date_formatter release];
         }         
         break;
      }
      default: {
         UIImageView *iconImageView = nil;
         UILabel *label = nil;
         cell = [tableView dequeueReusableCellWithIdentifier:ICON_LABEL_CELL_IDENTIFIER];
         if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:ICON_LABEL_CELL_IDENTIFIER] autorelease];

            iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(8, 15, 16, 16)];
            iconImageView.tag = ICON_TAG;
            [cell.contentView addSubview:iconImageView];
            //[iconImageView release];
            
            label = [[UILabel alloc] initWithFrame:CGRectMake(30, 2, 220, 36)];
            label.tag = LABEL_TAG;
            //label.adjustsFontSizeToFitWidth = YES;
            [cell.contentView addSubview:label];
            //[listLabel release];
            
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;            
         } else {
            iconImageView = (UIImageView *)[cell.contentView viewWithTag:ICON_TAG];
            label = (UILabel *)[cell.contentView viewWithTag:LABEL_TAG];
         }
         
         switch (indexPath.row) {
            case ROW_LIST: {
               UIImage *iconImage = [[UIImage alloc] initWithContentsOfFile:
                                     [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"icon_list.png"]];
               iconImageView.image = iconImage;
               [iconImage release];
               label.text = list;
               break;
            }
            case ROW_TAG: {
               UIImage *iconImage = [[UIImage alloc] initWithContentsOfFile:
                                     [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"icon_tag.png"]];
               iconImageView.image = iconImage;
               [iconImage release];

               // join tags
               NSString *tags_joined = @"";
               if (tags.count == 0) {
                  tags_joined = @"Tag...";
               } else {         
                  for (NSString *tag in tags) {
                     tags_joined = [tags_joined stringByAppendingString:[NSString stringWithFormat:@"%@ ", tag]];
                  }
               }
               
               label.text = tags_joined;
               break;
            }
            case ROW_NOTE: {
               UIImage *iconImage = [[UIImage alloc] initWithContentsOfFile:
                                     [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"icon_note.png"]];
               iconImageView.image = iconImage;
               [iconImage release];
               
               label.text = note ? note : @"Note...";
               break;
            }
         }
         break;
      }
   }
   return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
   switch (indexPath.row) {
      case ROW_DUE_PRIORITY:
         [tableView deselectRowAtIndexPath:indexPath animated:NO];
         break;
      case ROW_LIST: {
         ListSelectController *vc = [[ListSelectController alloc] initWithNibName:nil bundle:nil];
         vc.parent = self;
         [self.navigationController pushViewController:vc animated:YES];
         [vc release];
         break;
      }
      case ROW_TAG: {
         TagSelectController *vc = [[TagSelectController alloc] initWithNibName:nil bundle:nil];
         vc.parent = self;
         [vc setTags:tags];
         [self.navigationController pushViewController:vc animated:YES];
         [vc release];
         break;
      }
      case ROW_NOTE: {
         NoteEditController *vc = [[NoteEditController alloc] initWithNibName:nil bundle:nil];
         vc.parent = self;
         vc.note = note;
         [self.navigationController pushViewController:vc animated:YES];
         [vc release];
         break;
      }
      default:
         break;
   }
   [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (void) close
{
   [self dismissModalViewControllerAnimated:YES];
}

- (IBAction) cancel
{
   [self close];
}

- (IBAction) save
{
   NSString *name = text_input.text;
   if (name == nil || [name isEqualToString:@""])
      return;

   NSNumber *priority = [NSNumber numberWithInteger:priority_segment.selectedSegmentIndex];

   // create RTMTask and store it in DB.
   NSArray *keys =  [NSArray arrayWithObjects:@"name", @"list", @"priority", nil];
   NSArray *vals = [NSArray arrayWithObjects:name, list, priority, nil];
   
   NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjects:vals forKeys:keys];
   if (due)
      [params setObject:due forKey:@"due"];
   if (note)
      [params setObject:note forKey:@"note"];

   //[RTMTask createAtOffline:params];

   [self close];
}

- (void) selectDue
{
   DueDateSelectController *vc = [[DueDateSelectController alloc] initWithNibName:nil bundle:nil];
   vc.parent = self;
   [self.navigationController pushViewController:vc animated:YES];
   [vc release];
}

@end
