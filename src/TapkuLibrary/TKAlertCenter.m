//
//  TKAlertCenter.m
//  Created by Devin Ross on 9/29/10.
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

#import "TKAlertCenter.h"
#import "UIView+TKCategory.h"


#pragma mark -
@interface TKAlertView : UIView {
	CGRect _messageRect;
	NSString *_text;
	UIImage *_image;
}

- (id) init;
- (void) setMessageText:(NSString*)str;
- (void) setImage:(UIImage*)image;

@end


#pragma mark -
@implementation TKAlertView

- (id) init{
	if(!(self = [super initWithFrame:CGRectMake(0, 0, 100, 100)])) return nil;
	_messageRect = CGRectInset(self.bounds, 10, 10);
	self.backgroundColor = [UIColor clearColor];
	return self;
	
}

- (void) drawRect:(CGRect)rect{
	[[UIColor colorWithWhite:0 alpha:0.8] set];
	[UIView drawRoundRectangleInRect:rect withRadius:10];
	[[UIColor whiteColor] set];
	[_text drawInRect:_messageRect
             withFont:[UIFont boldSystemFontOfSize:14]
        lineBreakMode:UILineBreakModeWordWrap
            alignment:UITextAlignmentCenter];
	
	CGRect r = CGRectZero;
	r.origin.y = 15;
	r.origin.x = (NSInteger)((rect.size.width-_image.size.width)/2);
	r.size = _image.size;
	
	[_image drawInRect:r];
}

#pragma mark Instance Methods

/* The following method is copied from:
 * http://stackoverflow.com/questions/603907/uiimage-resize-then-crop
 * where it was posted by: Brad Larson.
 */
- (UIImage*)imageWithImage:(UIImage*)image 
              scaledToSize:(CGSize)newSize
{
    UIGraphicsBeginImageContext( newSize );
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (void) adjust
{
    float xPaddingFromWindowBorders = 20;
    float xPaddingFromAlertBorders = 20;
    float yPaddingFromWindowBorders = 200;
    float yPaddingFromAlertBorders = 20;
    float yPaddingFromAlertBottomBorder = 5;
    float widthUpperLimit = [UIApplication sharedApplication].keyWindow.bounds.size.width
                            - xPaddingFromWindowBorders
                            - xPaddingFromAlertBorders;
    float heightUpperLimit = [UIApplication sharedApplication].keyWindow.bounds.size.height
                            - yPaddingFromWindowBorders
                            - yPaddingFromAlertBorders;

    bool imageDimensionsNeedToBeAltered = NO;
    CGSize alteredImageSize;
    if (_image) {
        alteredImageSize = CGSizeMake(_image.size.width, _image.size.height);
    }

	float totalWidth = 160; // start with the desired upper limit for text rectangle
	if (_image) {
        // Is image width greater than default text width?
		if (_image.size.width > totalWidth) {
            //NSLog(@"Image width is greater than default text width!");
            totalWidth = _image.size.width;
        }
        // Is image width greater than the max width allowed?
        if (totalWidth > widthUpperLimit) {
            //NSLog(@"Image width is greater than screen width!");
            totalWidth = widthUpperLimit;
            imageDimensionsNeedToBeAltered = YES;
            alteredImageSize.width = totalWidth;
        }
    }

    float adjustTextWithinThisHeight = 200;
    if (_image) {
        if (adjustTextWithinThisHeight < (heightUpperLimit - _image.size.height)) {
            adjustTextWithinThisHeight = heightUpperLimit - _image.size.height;
        }
    }

	CGSize constrainedTextRectSize =
    [_text sizeWithFont:[UIFont boldSystemFontOfSize:14]
      constrainedToSize:CGSizeMake(totalWidth,adjustTextWithinThisHeight)
          lineBreakMode:UILineBreakModeWordWrap];

    //NSLog(@"Constrained Text Rectangle - width: %f, height: %f", constrainedTextRectSize.width, constrainedTextRectSize.height);
    if(_image) {
        if( (_image.size.width < totalWidth) && (constrainedTextRectSize.width < totalWidth) ) {
            /*NSLog(@"Both image and message need less space than the total width: %f, so lets use the wider one out of the two %f",
                  totalWidth,
                  MAX(_image.size.width, constrainedTextRectSize.width));*/
            totalWidth = MAX(_image.size.width, constrainedTextRectSize.width);
        }
    } else {
        //NSLog(@"There's no image, so lets use the absolute mimimum width needed for the text: %f", constrainedTextRectSize.width);
        totalWidth = constrainedTextRectSize.width;
    }

    float combinedHeight = constrainedTextRectSize.height; // without an image, the total height matches that of the text rectangle
    //NSLog(@"Without an image, the total height matches that of the text rectangle: %f", combinedHeight);
    if (_image) {
        combinedHeight += _image.size.height; // with an image, there is additional height to account for
        //NSLog(@"With an image, there is additional height to account for: %f, heightUpperLimit: %f", combinedHeight, heightUpperLimit);
        // Are image and text height together greater than the max height allowed?
        if (combinedHeight > heightUpperLimit) {
            //NSLog(@"Image and text height together are greater than the max height allowed!");
            // If so then scale down the image's height
            imageDimensionsNeedToBeAltered = YES;
            //NSLog(@"Image height before alteration - %f", alteredImageSize.height);
            alteredImageSize.height = _image.size.height - (combinedHeight - heightUpperLimit);
            //NSLog(@"Image height after alteration - %f", alteredImageSize.height);
            // And dumb down the total height
            combinedHeight = heightUpperLimit;
        }
    }

    if (imageDimensionsNeedToBeAltered) {
        /*NSLog(@"Altering image to fit - width: %f, height: %f, where combinedHeight: %f",
              alteredImageSize.width,
              alteredImageSize.height,
              combinedHeight);*/
        _image = [self imageWithImage:_image scaledToSize:alteredImageSize];
    }

    //NSLog(@"Setting alert bounds - totalWidth: %f, combinedHeight: %f", totalWidth, combinedHeight);
    self.bounds = CGRectMake(0,
                             0,
                             totalWidth + xPaddingFromAlertBorders,
                             combinedHeight + yPaddingFromAlertBorders + yPaddingFromAlertBottomBorder);

	_messageRect.size = constrainedTextRectSize;
    _messageRect.size.height += yPaddingFromAlertBottomBorder; // avoid the look where the text is stuck to the bottom
	_messageRect.origin.x = ( (totalWidth - constrainedTextRectSize.width + xPaddingFromAlertBorders) / 2 );
    if (_image) {
        _messageRect.origin.y = (combinedHeight - constrainedTextRectSize.height) + yPaddingFromAlertBorders;// + ((s.height+20)/2);
    } else {
        _messageRect.origin.y = combinedHeight - constrainedTextRectSize.height + ((constrainedTextRectSize.height+10)/2);
    }

	[self setNeedsLayout];
	[self setNeedsDisplay];
	
}

#pragma mark Setter Methods
- (void) setMessageText:(NSString*)str{
	_text = str;
	[self adjust];
}
- (void) setImage:(UIImage*)img{
	_image = img;
	[self adjust];
}

@end


#pragma mark -
@implementation TKAlertCenter

#pragma mark Init & Friends
+ (TKAlertCenter*) defaultCenter {
	static TKAlertCenter *defaultCenter = nil;
	if (!defaultCenter) {
		defaultCenter = [[TKAlertCenter alloc] init];
	}
	return defaultCenter;
}
- (id) init{
	if(!(self=[super init])) return nil;
	
	_alerts = [[NSMutableArray alloc] init];
	_alertView = [[TKAlertView alloc] init];
	_active = NO;
	
	
	_alertFrame = [UIApplication sharedApplication].keyWindow.bounds;

	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillAppear:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillDisappear:) name:UIKeyboardDidHideNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationWillChange:) name:UIApplicationWillChangeStatusBarOrientationNotification object:nil];

	return self;
}


#pragma mark Show Alert Message
- (void) showAlerts{
	
	if([_alerts count] < 1) {
		_active = NO;
		return;
	}
	
	_active = YES;
	
	_alertView.transform = CGAffineTransformIdentity;
	_alertView.alpha = 0;
	[[UIApplication sharedApplication].keyWindow addSubview:_alertView];

	
	
	NSArray *ar = [_alerts objectAtIndex:0];
	
	UIImage *img = nil;
	if([ar count] > 1) img = [[_alerts objectAtIndex:0] objectAtIndex:1];
	
	[_alertView setImage:img];

	if([ar count] > 0) [_alertView setMessageText:[[_alerts objectAtIndex:0] objectAtIndex:0]];
	
	
	
	_alertView.center = CGPointMake(_alertFrame.origin.x+_alertFrame.size.width/2, _alertFrame.origin.y+_alertFrame.size.height/2);
		
	
	CGRect rr = _alertView.frame;
	rr.origin.x = (int)rr.origin.x;
	rr.origin.y = (int)rr.origin.y;
	_alertView.frame = rr;
	
	UIInterfaceOrientation o = [UIApplication sharedApplication].statusBarOrientation;
	CGFloat degrees = 0;
	if(o == UIInterfaceOrientationLandscapeLeft ) degrees = -90;
	else if(o == UIInterfaceOrientationLandscapeRight ) degrees = 90;
	else if(o == UIInterfaceOrientationPortraitUpsideDown) degrees = 180;
	_alertView.transform = CGAffineTransformMakeRotation(degrees * M_PI / 180);
	_alertView.transform = CGAffineTransformScale(_alertView.transform, 2, 2);
	
	
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.15];
	[UIView setAnimationDelegate:self];
    if (_tapToDismiss) {
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(animationStep3)];
        [_alertView addGestureRecognizer:singleTap];
    } else {
        [UIView setAnimationDidStopSelector:@selector(animationStep2)];
    }
	
	_alertView.transform = CGAffineTransformMakeRotation(degrees * M_PI / 180);
	_alertView.frame = CGRectMake((int)_alertView.frame.origin.x, (int)_alertView.frame.origin.y, _alertView.frame.size.width, _alertView.frame.size.height);
	_alertView.alpha = 1;
	
	[UIView commitAnimations];
	
	
}
- (void) animationStep2{
	[UIView beginAnimations:nil context:nil];

	// depending on how many words are in the text
	// change the animation duration accordingly
	// avg person reads 200 words per minute
	NSArray * words = [[[_alerts objectAtIndex:0] objectAtIndex:0] componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	double duration = MAX(((double)[words count]*60.0/200.0),1);
	
	[UIView setAnimationDelay:duration];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animationStep3)];
	
	UIInterfaceOrientation o = [UIApplication sharedApplication].statusBarOrientation;
	CGFloat degrees = 0;
	if(o == UIInterfaceOrientationLandscapeLeft ) degrees = -90;
	else if(o == UIInterfaceOrientationLandscapeRight ) degrees = 90;
	else if(o == UIInterfaceOrientationPortraitUpsideDown) degrees = 180;
	_alertView.transform = CGAffineTransformMakeRotation(degrees * M_PI / 180);
	_alertView.transform = CGAffineTransformScale(_alertView.transform, 0.5, 0.5);
	
	_alertView.alpha = 0;
	[UIView commitAnimations];
}
- (void) animationStep3{
	
	[_alertView removeFromSuperview];
	[_alerts removeObjectAtIndex:0];
	[self showAlerts];
	
}
- (void) postAlertWithMessage:(NSString*)message image:(UIImage*)image tapToDismiss:(BOOL)yesOrNO{
    _tapToDismiss = yesOrNO;
	[_alerts addObject:[NSArray arrayWithObjects:message,image,nil]];
	if(!_active) [self showAlerts];
}
- (void) postAlertWithMessage:(NSString*)message image:(UIImage*)image{
    [self postAlertWithMessage:message image:image tapToDismiss:NO];
}
- (void) postAlertWithMessage:(NSString*)message{
	[self postAlertWithMessage:message image:nil];
}


#pragma mark System Observation Changes
CGRect subtractRect(CGRect wf,CGRect kf);
CGRect subtractRect(CGRect wf,CGRect kf){
	
	
	
	if(!CGPointEqualToPoint(CGPointZero,kf.origin)){
		
		if(kf.origin.x>0) kf.size.width = kf.origin.x;
		if(kf.origin.y>0) kf.size.height = kf.origin.y;
		kf.origin = CGPointZero;
		
	}else{
		
		
		kf.origin.x = abs(kf.size.width - wf.size.width);
		kf.origin.y = abs(kf.size.height -  wf.size.height);
		
		
		if(kf.origin.x > 0){
			CGFloat temp = kf.origin.x;
			kf.origin.x = kf.size.width;
			kf.size.width = temp;
		}else if(kf.origin.y > 0){
			CGFloat temp = kf.origin.y;
			kf.origin.y = kf.size.height;
			kf.size.height = temp;
		}
		
	}
	return CGRectIntersection(wf, kf);
	
	
	
}
- (void) keyboardWillAppear:(NSNotification *)notification {
	
	NSDictionary *userInfo = [notification userInfo];
	NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
	CGRect kf = [aValue CGRectValue];
	CGRect wf = [UIApplication sharedApplication].keyWindow.bounds;
	
	[UIView beginAnimations:nil context:nil];
	_alertFrame = subtractRect(wf,kf);
	_alertView.center = CGPointMake(_alertFrame.origin.x+_alertFrame.size.width/2, _alertFrame.origin.y+_alertFrame.size.height/2);

	[UIView commitAnimations];

}
- (void) keyboardWillDisappear:(NSNotification *) notification {
	_alertFrame = [UIApplication sharedApplication].keyWindow.bounds;

}
- (void) orientationWillChange:(NSNotification *) notification {
	
	NSDictionary *userInfo = [notification userInfo];
	NSNumber *v = [userInfo objectForKey:UIApplicationStatusBarOrientationUserInfoKey];
	UIInterfaceOrientation o = [v intValue];
	
	
	
	
	CGFloat degrees = 0;
	if(o == UIInterfaceOrientationLandscapeLeft ) degrees = -90;
	else if(o == UIInterfaceOrientationLandscapeRight ) degrees = 90;
	else if(o == UIInterfaceOrientationPortraitUpsideDown) degrees = 180;
	
	[UIView beginAnimations:nil context:nil];
	_alertView.transform = CGAffineTransformMakeRotation(degrees * M_PI / 180);
	_alertView.frame = CGRectMake((int)_alertView.frame.origin.x, (int)_alertView.frame.origin.y, (int)_alertView.frame.size.width, (int)_alertView.frame.size.height);
	[UIView commitAnimations];
	
}

@end