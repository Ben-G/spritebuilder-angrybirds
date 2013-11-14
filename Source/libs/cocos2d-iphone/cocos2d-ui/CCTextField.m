/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2013 Apportable Inc.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import "CCTextField.h"
#import "CCControlSubclass.h"

@implementation CCTextField

+ (id) textFieldWithSpriteFrame:(CCSpriteFrame *)frame
{
    return [[self alloc] initWithSpriteFrame:frame];
}

- (id) init
{
    return [self initWithSpriteFrame:NULL];
}

- (id) initWithSpriteFrame:(CCSpriteFrame*)frame
{
    self = [super init];
    if (!self) return NULL;
    
    if (frame)
    {
        _background = [[CCSprite9Slice alloc] initWithSpriteFrame:frame];
    }
    else
    {
        _background = [[CCSprite9Slice alloc] init];
    }
    
    [self addChild:_background];
    
#ifdef __CC_PLATFORM_IOS
    
    // Create UITextField and set it up
    _textField = [[UITextField alloc] initWithFrame:CGRectZero];
    _textField.delegate = self;
    _textField.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    
#elif defined(__CC_PLATFORM_MAC)
    
    // Create NSTextField and set it up
    _textField = [[NSTextField alloc] initWithFrame: NSMakeRect(10, 10, 300, 40)];
    _textField.delegate = self;
    
    [_textField setFont:[NSFont fontWithName:@"Helvetica" size:17]];
    [_textField setBezeled:NO];
    [_textField setBackgroundColor:[NSColor colorWithCalibratedRed:0 green:0 blue:0 alpha:0]];
    [_textField setWantsLayer:YES];
    
#endif
    
    _padding = 4;
    
    return self;
}

- (void) positionTextField
{
#ifdef __CC_PLATFORM_IOS
    CGPoint worldPos = [self convertToWorldSpace:CGPointZero];
    CGPoint viewPos = [[CCDirector sharedDirector] convertToUI:worldPos];
    viewPos.x += _padding;
    viewPos.y += _padding;
    
    CGSize size = self.contentSizeInPoints;
    viewPos.y -= size.height;
    size.width -= _padding * 2;
    size.height -= _padding * 2;
    
    CGRect frame = CGRectZero;
    frame.origin = viewPos;
    frame.size = size;
    
    _textField.frame = frame;
#elif defined(__CC_PLATFORM_MAC)
    CGPoint worldPos = [self convertToWorldSpace:CGPointZero];
    CGPoint viewPos = [[CCDirector sharedDirector] convertToUI:worldPos];
    viewPos.x += _padding;
    viewPos.y += _padding;
    
    CGSize size = self.contentSizeInPoints;
    //viewPos.y -= size.height;
    size.width -= _padding * 2;
    size.height -= _padding * 2;
    
    CGRect frame = CGRectZero;
    frame.origin = viewPos;
    frame.size = size;
    
    _textField.frame = frame;
    
#endif
}

- (void) addUITextView
{
    [[[CCDirector sharedDirector] view] addSubview:_textField];
    [self positionTextField];
}

- (void) removeUITextView
{
    [_textField removeFromSuperview];
}

- (void) onEnter
{
    [super onEnter];
}

- (void) onEnterTransitionDidFinish
{
    [self addUITextView];
    [super onEnterTransitionDidFinish];
    [self registerForKeyboardNotifications];
}

- (void) onExitTransitionDidStart
{
    [self removeUITextView];
    [super onExitTransitionDidStart];
    [self unregisterForKeyboardNotifications];
}

- (void) update:(CCTime)delta
{
    [self positionTextField];
}

- (void) layout
{
    CGSize sizeInPoints = [self convertContentSizeToPoints: self.preferredSize type:self.preferredSizeType];
    
    [_background setContentSize:sizeInPoints];
    _background.anchorPoint = ccp(0,0);
    _background.position = ccp(0,0);
    
    self.contentSize = [self convertContentSizeFromPoints: sizeInPoints type:self.contentSizeType];
    
    [super layout];
}

#pragma mark Text Field Delegate Methods

#ifdef __CC_PLATFORM_IOS
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (_keyboardIsShown)
    {
        [self focusOnTextField];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self endFocusingOnTextField];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [self triggerAction];
    
    return YES;
}

#elif defined(__CC_PLATFORM_MAC)

- (BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor
{
    [self triggerAction];
    return YES;
}

#endif

#pragma mark Keyboard Notifications

- (void)registerForKeyboardNotifications
{
#ifdef __CC_PLATFORM_IOS
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
#endif
}

- (void) unregisterForKeyboardNotifications
{
#ifdef __CC_PLATFORM_IOS
    [[NSNotificationCenter defaultCenter] removeObserver:self];
#endif
}

#ifdef __CC_PLATFORM_IOS
- (void)keyboardWasShown:(NSNotification*)notification
{
    _keyboardIsShown = YES;
    
    UIView* view = [[CCDirector sharedDirector] view];
    
    NSDictionary* info = [notification userInfo];
    NSValue* value = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect frame = [value CGRectValue];
    frame = [view.window convertRect:frame toView:view];
    
    CGSize kbSize = frame.size;
    
    _keyboardHeight = kbSize.height;
    
    if (_textField.isEditing)
    {
        [self focusOnTextField];
    }
}

- (void) keyboardWillBeHidden:(NSNotification*) notification
{
    _keyboardIsShown = NO;
}

#endif

#pragma mark Focusing on Text Field

#ifdef __CC_PLATFORM_IOS

- (void) focusOnTextField
{
    CGSize windowSize = [[CCDirector sharedDirector] viewSize];
    
    // Find the location of the textField
    float fieldCenterY = _textField.frame.origin.y - (_textField.frame.size.height/2);
    
    // Upper third part of the screen
    float upperThirdHeight = windowSize.height / 3;
    
    if (fieldCenterY > upperThirdHeight)
    {
        // Slide the main view up
        
        // Calculate offset
        float dstYLocation = windowSize.height / 4;
        float offset = -(fieldCenterY - dstYLocation);
        if (offset < -_keyboardHeight) offset = -_keyboardHeight;
        
        // Calcualte target frame
        UIView* view = [[CCDirector sharedDirector] view];
        CGRect frame = view.frame;
        frame.origin.y = offset;
        
        // Do animation
        [UIView beginAnimations: @"textFieldAnim" context: nil];
        [UIView setAnimationBeginsFromCurrentState: YES];
        [UIView setAnimationDuration: 0.2f];

        view.frame = frame;
        
        [UIView commitAnimations];
    }
}

- (void) endFocusingOnTextField
{
    UIView* view = [[CCDirector sharedDirector] view];
    
    // Slide the main view back down
    [UIView beginAnimations: @"textFieldAnim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: 0.2f];
    
    CGRect frame = view.frame;
    frame.origin = CGPointZero;
    view.frame = frame;
    
    [UIView commitAnimations];
}

#endif

#pragma mark Properties

#ifdef __CC_PLATFORM_IOS

- (void) setString:(NSString *)string
{
    _textField.text = string;
}

- (NSString*) string
{
    return _textField.text;
}

#elif defined(__CC_PLATFORM_MAC)

- (void) setString:(NSString *)string
{
    _textField.stringValue = string;
}

- (NSString*) string
{
    return _textField.stringValue;
}

#endif

- (void) setBackgroundSpriteFrame:(CCSpriteFrame*)spriteFrame
{
    _background.spriteFrame = spriteFrame;
}

- (CCSpriteFrame*) backgroundSpriteFrame
{
    return _background.spriteFrame;
}

@end
