//
//  ViewController.m
//  CogConf
//
//  Created by sudhakar on 4/2/14.
//  Copyright (c) 2014 sudhakar. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIButton *btnCall;

@property (weak, nonatomic) IBOutlet UITextField *txtConfCode;
@property (weak, nonatomic) IBOutlet UILabel *lblCancelInfo;
@property (weak, nonatomic) IBOutlet UITableView *tblRecents;

@end

@implementation ViewController

BOOL  makeCall=true;
NSMutableArray *tableData;
NSInteger maxRecentsSize=10;
int editedRowIndex=0;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    //Check if clipboard has text
    
    //Check if its recent copy to clipboard
    
    tableData=[[NSMutableArray alloc] init];
    
    UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    
    numberToolbar.items = [NSArray arrayWithObjects:
                           [[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelNumberPad)],
                           [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                           [[UIBarButtonItem alloc]initWithTitle:@"Call" style:UIBarButtonItemStyleDone target:self action:@selector(doneWithNumberPad)],
                           nil];
    
    self.txtConfCode.inputAccessoryView = numberToolbar;
    
    
    NSString * pasteBoardString = [UIPasteboard generalPasteboard].string;
    NSLog(@"Clipboard text %@", pasteBoardString);
    
    
    pasteBoardString = [self cleanupNumber:pasteBoardString];
    
    NSLog(@"Cleaned up text: %@", pasteBoardString);

    
    //Cleanup text
    self.txtConfCode.text = pasteBoardString;
    [self makeCall:pasteBoardString waitForSeconds:5];
    
}

-(void)cancelNumberPad{
    [self.txtConfCode resignFirstResponder];
    
}

-(void)doneWithNumberPad{
    NSString * numberFromTheKeyboard = self.txtConfCode.text;
    [self.txtConfCode resignFirstResponder];
    [self showMessage];
}


-(NSString * ) cleanupNumber:(NSString *) confCode
{
    NSLog(@"Cleaning up number %@", confCode);
    NSString *newString = [[confCode componentsSeparatedByCharactersInSet:
                            [[NSCharacterSet decimalDigitCharacterSet] invertedSet]]
                           componentsJoinedByString:@""];
    NSLog(@"Only numbers");
    NSLog(newString);
    
    //remove 800 number reference
    
    newString = [newString stringByReplacingOccurrencesOfString:@"18886951379"
                                         withString:@""];

    NSLog(@"Only numbers - after replace of 1800... number");
    NSLog(newString);
    
    newString = [newString stringByReplacingOccurrencesOfString:@"8886951379"
                                         withString:@""];

    NSLog(@"Only numbers - after replace of 800... number");
    NSLog(newString);
    return newString;
    
}

-(BOOL)stringIsNilOrEmpty:(NSString*)aString {
    return !(aString && aString.length);
}

-(void) alert:(NSString * ) msg
{
    UIAlertView *helloWorldAlert = [[UIAlertView alloc]
                                    initWithTitle:@"Cognizant Conference" message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
    // Display the Hello World Message
    [helloWorldAlert show];
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)showMessage
{
    [self cancelNumberPad];
    
    NSString * confCode = self.txtConfCode.text;
    confCode = [self cleanupNumber:confCode];
    
    makeCall=true;
     //Make call
    [self makeCall:confCode waitForSeconds:0];

}

-(void) makeCall:(NSString *) confCode waitForSeconds:(NSInteger) waitForSeconds withName:(NSString *) withName
{
    
}
-(void) makeCall:(NSString *) confCode waitForSeconds:(NSInteger) waitForSeconds
{
    if( [self stringIsNilOrEmpty:confCode])
    {
        return;
    }
    
    // Delay execution of my block for 10 seconds.
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, waitForSeconds * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        if(makeCall)
        {
            //[self alert:confCode];
            NSLog(@"making call now");
            NSString *phoneNumber = [@"tel://18002005888,2404901947#,,1,," stringByAppendingString:confCode];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
            [self addToRecents:confCode];
            
            [self.tblRecents reloadData ];
            
            
            
        }
        [self.lblCancelInfo setHidden:TRUE];
 

      });
    
    
    
}
-(void) addToRecents:(NSString *) confCode
{
     NSArray * rowData =  @[confCode , @"no name"];
    if(tableData.count==0)
    {
        NSLog(@"firstentry");
       
         [tableData insertObject: rowData atIndex:0];
            return;
        
    }
    if( [confCode isEqualToString: [tableData objectAtIndex:0][0] ] )
    {
        NSLog(@"Same as last number dialled. Not adding to the list");
    }
    else{
        [tableData insertObject:rowData atIndex:0];
        
        //if exceeds length , remove the last one
        if( tableData.count > maxRecentsSize)
        {
            NSLog(@"Removing object");
            [tableData removeObjectAtIndex:maxRecentsSize];
        }
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [tableData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"RecentItem";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:simpleTableIdentifier];
        UILongPressGestureRecognizer *longPressGesture =
        [[UILongPressGestureRecognizer alloc]
          initWithTarget:self action:@selector(longPress:)];
		[cell addGestureRecognizer:longPressGesture];
        
    }
    NSLog(@"******* Cell for rowatindexpath %ld", (long)indexPath.row);
    cell.textLabel.text = [tableData objectAtIndex:indexPath.row][0];
    cell.detailTextLabel.text=[tableData objectAtIndex:indexPath.row][1];
    cell.textLabel.tag  = indexPath.row;

    return cell;
}
- (void)longPress:(UILongPressGestureRecognizer *)gesture
{
	// only when gesture was recognized, not when ended
	if (gesture.state == UIGestureRecognizerStateBegan)
	{
		// get affected cell
		UITableViewCell *cell = (UITableViewCell *)[gesture view];
        
        NSLog(@"Long-pressed cell content %@", cell.textLabel.text);
        
		// get indexPath of cell
        int row = (int)cell.textLabel.tag;
        
        
		// do something with this action
		NSLog(@"Long-pressed cell at row %d", row);
        editedRowIndex= row;

        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Name" message:@"Provide Name" delegate:self cancelButtonTitle:@"Save" otherButtonTitles:nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        [alert show];
        
        
	}
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{


    NSString * userEnteredString = [[alertView textFieldAtIndex:0] text];
    NSLog(@"Entered: %@",userEnteredString);
    
    NSArray * rowData =  @[(NSString*)([tableData objectAtIndex:editedRowIndex][0]) ,userEnteredString ];

    NSLog(@"xxxx");
    
    [tableData replaceObjectAtIndex:editedRowIndex withObject:rowData];

    [self.tblRecents reloadData];


}


-(IBAction)confCodeBeginEditing:(UITextField *)textField {
    makeCall=false;
     [self.lblCancelInfo setHidden:TRUE];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"user selected row %i",indexPath.row);
    self.txtConfCode.text= [tableData objectAtIndex:indexPath.row];
    [self showMessage];
}


@end
