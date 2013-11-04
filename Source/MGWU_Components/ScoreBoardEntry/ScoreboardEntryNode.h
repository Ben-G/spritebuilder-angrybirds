//
//  ScoreboardEntryNode.h
//  _MGWU-SideScroller-Template_
//
//  Created by Benjamin Encz on 5/16/13.
//  Copyright (c) 2013 MakeGamesWithUs Inc. Free to use for all purposes.
//

#import "CCNode.h"

/**
 Displays an icon and a score.
 */
@interface ScoreboardEntryNode : CCNode
{
    // label displaying the current score
    CCLabelBMFont *_scoreLabel;
    
    // the currently displayed score, which can differ from the actual score due to animations
    int _displayScore;
    
    // stores the timeElapsed since the last time the score display was updated
    NSTimeInterval _timeElapsed;
}

/**
 Stores the string format to display the score.
 This defaults to: 
 @"%d"
 
 Alternatively you can add some text to the score:
 @"%d meters"
 */
@property (nonatomic, strong) NSString *scoreStringFormat;

/**
 Stores the actual score. Setting this property will update the 
 score unanimated.
 */
@property (nonatomic, assign) int score;

/**
 Defines the score steps when updating the score animated.
 This value defaults to 3.
 */
@property (nonatomic, assign) int scoreAnimationSteps;

/**
 Lets you define a score image (optional) and a font file. Both resources need to be 
 part of the apps main bundle.
 
 Example for initialization:
 
 [[ScoreboardEntryNode alloc] initWithScoreImage:@"coin.png" fontFile:@"avenir.fnt"];
 */
- (id)initWithScoreImage:(NSString *)scoreImage fontFile:(NSString *)fontFile;

/**
 Sets the score. Allows the sender to choose if this shot happen animated or not.
 */
- (void)setScore:(int)score animated:(BOOL)animated;

@end
