//
//  AlertsViewController.m
//  Created by Devin Ross on 10/6/10.
//
/*
 
 tapku.com || http://github.com/devinross/tapkulibrary
 
 Permission is hereby granted, free of charge, to any person
 obtaining a copy of this software and associated documentation
 files (the "Software"), to deal in the Software without
 restriction, including without limitation the rights to use,
 copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the
 Software is furnished to do so, subject to the following
 conditions:
 
 The above copyright notice and this permission notice shall be
 included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 OTHER DEALINGS IN THE SOFTWARE.
 
 */

#import "AlertsViewController.h"


@implementation AlertsViewController

- (id) init{
	if(!(self=[super init])) return nil;
	self.title = NSLocalizedString(@"Alerts",@"Alerts");
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Tap Me" style:UIBarButtonItemStyleBordered target:self action:@selector(beer)] autorelease];
	return self;
}
- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void) loadView{
	[super loadView];
	self.view.backgroundColor = [UIColor whiteColor];
}
- (void) viewDidAppear:(BOOL)animated{
	[super viewDidAppear:animated];
	


	
	[[TKAlertCenter defaultCenter] postAlertWithMessage:@"Hi!"];
	[[TKAlertCenter defaultCenter] postAlertWithMessage:@"This is the alert system"];
    [[TKAlertCenter defaultCenter] postAlertWithMessage:@"Really Really Really long string to help one see the flaws that are not so obvious with the math behind centering, if one always tests with really really short strings"];
	[[TKAlertCenter defaultCenter] postAlertWithMessage:@"Use images too!" image:[UIImage imageNamed:@"beer"]];

    [[TKAlertCenter defaultCenter] postAlertWithMessage:@"Beer! Omg Beer? Yes beer! Lemme have some! Sure, here you go ... glug glug glug ... Ah! that felt good :)"
                                                  image:[UIImage imageNamed:@"beer@2x"]];

	[[TKAlertCenter defaultCenter] postAlertWithMessage:@"Image will scale to fit!"
                                                  image:[UIImage imageNamed:@"ipadcover_2.jpg"]];
}

- (void) beer{
    [[TKAlertCenter defaultCenter] postAlertWithMessage:@"Tap to dismiss..."
                                                  image:[UIImage imageNamed:@"ipadcover_2.jpg"]
                                           tapToDismiss:YES];
}


@end