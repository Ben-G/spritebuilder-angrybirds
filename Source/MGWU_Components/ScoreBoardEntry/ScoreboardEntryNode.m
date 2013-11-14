//
//  ScoreboardEntryNode.m
//  _MGWU-SideScroller-Template_
//
//  Created by Benjamin Encz on 5/16/13.
//  Copyright (c) 2013 MakeGamesWithUs Inc. Free to use for all purposes.
//

#import "ScoreboardEntryNode.h"

@implementation ScoreboardEntryNode {
    CCSprite *_scoreIcon;
}

@synthesize score = _score;

- (id)init {
    return [self initWithScoreImage:@"coin.png" fontFile:@"avenir.fnt"];
}

- (id)initWithScoreImage:(NSString *)scoreImage fontFile:(NSString *)fontFile
{
    self = [super init];
    
    if (self)
    {
        self.scoreStringFormat = @"%d";
        _scoreLabel = [CCLabelBMFont labelWithString:@"" fntFile:fontFile];
        _scoreLabel.string = [NSString stringWithFormat:_scoreStringFormat, _score];
        _scoreLabel.anchorPoint = ccp(0,0.5);
        [self addChild:_scoreLabel];
        
        self.scoreAnimationSteps = 3;
        
        if (scoreImage)
        {
            CCSprite *scoreIcon = [CCSprite spriteWithFile:scoreImage];
            [self addChild:scoreIcon];
            
            // move the score label to the right of the icon
            _scoreLabel.position = ccp(_scoreLabel.position.x + scoreIcon.contentSize.width, _scoreLabel.position.y);
        }
        
        [self scheduleUpdate];
    }
    
    return self;
}

- (void)setScore:(int)score {
    [self setScore:score animated:FALSE];
}

- (void)setScore:(int)score animated:(BOOL)animated
{
    if (_score == score)
    {
        // if score wasn't changed, return.
        return;
    }
    
    if (!animated)
    {
        // store the old score as the initial displayScore
        _displayScore = score;
        _scoreLabel.string = [NSString stringWithFormat:_scoreStringFormat, score];
    } else
    {
        [self resumeSchedulerAndActions];
    }
    
    _score = score;
}

- (void)setSpriteFrame:(CCSpriteFrame *)spriteFrame {
    if (spriteFrame != nil) {
        _scoreIcon.spriteFrame = spriteFrame;
    } else {
        CCSpriteFrame *spriteFrame = [CCSpriteFrame frameWithImageNamed:@"coin.png"];
        _scoreIcon.spriteFrame = spriteFrame;
    }
}

- (CCSpriteFrame *)spriteFrame {
    return _scoreIcon.spriteFrame;
}

- (void)update:(CCTime)delta {
    _timeElapsed += delta;
    
    if ( (_displayScore != _score) && (_timeElapsed >= 0.02f))
    {
        _timeElapsed = 0.f;
        
        if (_displayScore < _score)
        {
            _displayScore += self.scoreAnimationSteps;
            
            if (_displayScore > _score)
            {
                _displayScore = _score;
            }
        } else if (_displayScore > _score)
        {
            _displayScore -= self.scoreAnimationSteps;

            if (_displayScore < _score)
            {
                _displayScore = _score;
            }
        }
        
        _scoreLabel.string = [NSString stringWithFormat:_scoreStringFormat, _displayScore];
    } else if (_displayScore == _score)
    {
        [self pauseSchedulerAndActions];
    }
}

@end
