/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2008-2010 Ricardo Quesada
 * Copyright (c) 2011 Zynga Inc.
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
 *
 */


#import "CCLabelTTF.h"
#import "Support/CGPointExtension.h"
#import "ccMacros.h"
#import "CCShaderCache.h"
#import "CCGLProgram.h"
#import "Support/CCFileUtils.h"
#import "ccDeprecated.h"
#import "ccMacros.h"
#import "ccUtils.h"
#import "NSAttributedString+CCAdditions.h"
#import "CCConfiguration.h"
#import "CCNode_Private.h"

#ifdef __CC_PLATFORM_IOS
#import "Platforms/iOS/CCDirectorIOS.h"
#import <CoreText/CoreText.h>
#endif

static __strong NSMutableDictionary* ccLabelTTF_registeredFonts;


@implementation CCTexture (CCLabelTTF)

- (void) setPremultipliedAlpha:(BOOL)flag
{
    _premultipliedAlpha = flag;
}

@end

#pragma mark CCLabelTTF


@implementation CCLabelTTF

+ (id) labelWithString:(NSString *)string fontName:(NSString *)name fontSize:(CGFloat)size
{
    return [[self alloc] initWithString:string fontName:name fontSize:size];
}

+ (id) labelWithString:(NSString *)string fontName:(NSString *)name fontSize:(CGFloat)size dimensions:(CGSize)dimensions
{
    return [[self alloc] initWithString:string fontName:name fontSize:size dimensions:dimensions];
}

+ (id) labelWithAttributedString:(NSAttributedString *)attrString
{
    return [[self alloc] initWithAttributedString:attrString];
}

+ (id) labelWithAttributedString:(NSAttributedString *)attrString dimensions:(CGSize)dimensions
{
    return [[self alloc] initWithAttributedString:attrString dimensions:dimensions];
}

- (id) init
{
    return [self initWithString:@"" fontName:@"Helvetica" fontSize:12];
}


- (id) initWithString:(NSString*)str fontName:(NSString*)name fontSize:(CGFloat)size
{
	return [self initWithAttributedString:[[NSAttributedString alloc] initWithString:str] fontName:name fontSize:size dimensions:CGSizeZero];
}

- (id) initWithString:(NSString*)str fontName:(NSString*)name fontSize:(CGFloat)size dimensions:(CGSize)dimensions
{
    return [self initWithAttributedString:[[NSAttributedString alloc] initWithString:str] fontName:name fontSize:size dimensions:dimensions];
}

- (id) initWithAttributedString:(NSAttributedString *)attrString;
{
    NSAssert([CCConfiguration sharedConfiguration].OSVersion >= CCSystemVersion_iOS_6_0, @"Attributed strings are only supported on iOS 6 or later");
    return [self initWithAttributedString:attrString fontName:@"Helvetica" fontSize:12 dimensions:CGSizeZero];
}

- (id) initWithAttributedString:(NSAttributedString *)attrString dimensions:(CGSize)dimensions
{
    NSAssert([CCConfiguration sharedConfiguration].OSVersion >= CCSystemVersion_iOS_6_0, @"Attributed strings are only supported on iOS 6 or later");
    return [self initWithAttributedString:attrString fontName:@"Helvetica" fontSize:12 dimensions:dimensions];
}

// This is a private initializer
- (id) initWithAttributedString:(NSAttributedString *)attrString fontName:(NSString*)fontName fontSize:(float)fontSize dimensions:(CGSize)dimensions
{
    if ( (self = [super init]) )
    {
        if (!fontName) fontName = @"Helvetica";
        if (!fontSize) fontSize = 12;
        
        _blendFunc.src = CC_BLEND_SRC;
        _blendFunc.dst = CC_BLEND_DST;
        
        // other properties
        self.fontName = fontName;
        self.fontSize = fontSize;
        self.dimensions = dimensions;
        self.fontColor = ccc4(255, 255, 255, 255);
        self.outlineWidth = 1;
        [self _setAttributedString:attrString];
    }
    return self;
}



#pragma mark Properties

- (void) _setAttributedString:(NSAttributedString *)attributedString
{
    NSAssert(attributedString, @"Invalid attributedString");
    
    if ( _attributedString.hash != attributedString.hash)
    {
        _attributedString = [attributedString copy];
        
        [self setTextureDirty];
    }
}

- (void) setAttributedString:(NSAttributedString *)attributedString
{
    NSAssert([CCConfiguration sharedConfiguration].OSVersion >= CCSystemVersion_iOS_6_0, @"Attributed strings are only supported on iOS 6 or later");
    [self _setAttributedString:attributedString];
}

- (void) setString:(NSString*)str
{
	NSAssert( str, @"Invalid string" );
    [self _setAttributedString:[[NSAttributedString alloc] initWithString:str]];
}

-(NSString*) string
{
	return [_attributedString string];
}

- (void)setFontName:(NSString*)fontName
{
    // Handle passing of complete file paths
    if ([[[fontName pathExtension] lowercaseString] isEqualToString:@"ttf"])
    {
        [CCLabelTTF registerCustomTTF:fontName];
        fontName = [[fontName lastPathComponent] stringByDeletingPathExtension];
    }
    
	if( fontName.hash != _fontName.hash ) {
		_fontName = [fontName copy];
		[self setTextureDirty];
	}
}

- (void) setFontSize:(float)fontSize
{
	if( fontSize != _fontSize ) {
		_fontSize = fontSize;
		[self setTextureDirty];
	}
}

- (void) setAdjustsFontSizeToFit:(BOOL)adjustsFontSizeToFit
{
    if (adjustsFontSizeToFit != _adjustsFontSizeToFit)
    {
        _adjustsFontSizeToFit = adjustsFontSizeToFit;
        [self setTextureDirty];
    }
}

- (void) setFontColor:(ccColor4B)fontColor
{
    if (!ccc4BEqual(_fontColor, fontColor))
    {
        _fontColor = fontColor;
        [self setTextureDirty];
    }
}

- (void) setMinimumFontSize:(float)minimumFontSize
{
    if (minimumFontSize != _minimumFontSize)
    {
        _minimumFontSize = minimumFontSize;
        [self setTextureDirty];
    }
}

-(void) setDimensions:(CGSize) dim
{
    if( dim.width != _dimensions.width || dim.height != _dimensions.height)
	{
        _dimensions = dim;
		[self setTextureDirty];
    }
}

- (CGSize) contentSize
{
    [self updateTexture];
    return _contentSize;
}

-(void) setHorizontalAlignment:(CCTextAlignment)alignment
{
    if (alignment != _horizontalAlignment)
    {
        _horizontalAlignment = alignment;
		[self setTextureDirty];

    }
}

-(void) setVerticalAlignment:(CCVerticalTextAlignment)verticalAlignment
{
    if (_verticalAlignment != verticalAlignment)
    {
        _verticalAlignment = verticalAlignment;
		[self setTextureDirty];
    }
}


- (void) setShadowColor:(ccColor4B)shadowColor
{
    if (!ccc4BEqual(_shadowColor, shadowColor))
    {
        _shadowColor = shadowColor;
        [self setTextureDirty];
    }
}

- (void) setShadowOffset:(CGPoint)shadowOffset
{
    if (!CGPointEqualToPoint(_shadowOffset, shadowOffset))
    {
        _shadowOffset = shadowOffset;
        [self setTextureDirty];
    }
}

- (void) setShadowBlurRadius:(float)shadowBlurRadius
{
    if (_shadowBlurRadius != shadowBlurRadius)
    {
        _shadowBlurRadius = shadowBlurRadius;
        [self setTextureDirty];
    }
}

- (void) setOutlineColor:(ccColor4B)outlineColor
{
    if (!ccc4BEqual(outlineColor, _outlineColor))
    {
        _outlineColor = outlineColor;
        [self setTextureDirty];
    }
}

- (void) setOutlineWidth:(float)outlineWidth
{
    if (outlineWidth != _outlineWidth)
    {
        _outlineWidth = outlineWidth;
        [self setTextureDirty];
    }
}

- (NSString*) description
{
	// XXX: _string, _fontName can't be displayed here, since they might be already released

	return [NSString stringWithFormat:@"<%@ = %p | FontSize = %.1f>", [self class], self, _fontSize];
}

- (void) visit
{
    if (_isTextureDirty)
    {
        [self updateTexture];
    }
    
    [super visit];
}

- (void) setTextureDirty
{
    _isTextureDirty = YES;
}


#pragma mark -
#pragma mark Render Font Mac & iOS 6

- (BOOL) updateTexture
{
    if (!_attributedString) return NO;
    if (!_isTextureDirty) return NO;
    
    _isTextureDirty = NO;
    
#ifdef __CC_PLATFORM_IOS
    // Handle fonts on iOS 5
    if ([CCConfiguration sharedConfiguration].OSVersion < CCSystemVersion_iOS_6_0)
    {
        return [self updateTextureOld];
    }
#endif
    
    // Set default values for font attributes if they are not set in the attributed string
    
    NSMutableAttributedString* formattedAttributedString = [_attributedString mutableCopy];
    NSRange fullRange = NSMakeRange(0, formattedAttributedString.length);
    
    BOOL useFullColor = NO;
    
    if (_shadowColor.a > 0) useFullColor = YES;
    if (_outlineColor.a > 0 && _outlineWidth > 0) useFullColor = YES;
    
#ifdef __CC_PLATFORM_IOS
    
    // Font color
    if (![formattedAttributedString hasAttribute:NSForegroundColorAttributeName])
    {
        if (!ccc4BEqual(_fontColor, ccc4(255, 255, 255, 255)))
        {
            useFullColor = YES;
        }
        
        float r = ((float)_fontColor.r)/255;
        float g = ((float)_fontColor.g)/255;
        float b = ((float)_fontColor.b)/255;
        float a = ((float)_fontColor.a)/255;
        
        UIColor* color = [UIColor colorWithRed:r green:g blue:b alpha:a];
        
        [formattedAttributedString addAttribute:NSForegroundColorAttributeName value:color range:fullRange];
    }
    else
    {
        useFullColor = YES;
    }
    
    // Font
    if (![formattedAttributedString hasAttribute:NSFontAttributeName])
    {
        UIFont* font = [UIFont fontWithName:_fontName size:_fontSize];
        if (!font) font = [UIFont fontWithName:@"Helvetica" size:_fontSize];
        [formattedAttributedString addAttribute:NSFontAttributeName value:font range:fullRange];
    }
    
    // Shadow
    if ([formattedAttributedString hasAttribute:NSShadowAttributeName])
    {
        useFullColor = YES;
    }
    
    // Text alignment
    if (![formattedAttributedString hasAttribute:NSParagraphStyleAttributeName])
    {
        NSMutableParagraphStyle* style = [[NSMutableParagraphStyle alloc] init];
        
        if (_horizontalAlignment == CCTextAlignmentLeft) style.alignment = NSTextAlignmentLeft;
        else if (_horizontalAlignment == CCTextAlignmentCenter) style.alignment = NSTextAlignmentCenter;
        else if (_horizontalAlignment == CCTextAlignmentRight) style.alignment = NSTextAlignmentRight;
        
        [formattedAttributedString addAttribute:NSParagraphStyleAttributeName value:style range:fullRange];
    }
    
#elif defined(__CC_PLATFORM_MAC)
    // Font color
    if (![formattedAttributedString hasAttribute:NSForegroundColorAttributeName])
    {
        if (!ccc4BEqual(_fontColor, ccc4(255, 255, 255, 255)))
        {
            useFullColor = YES;
        }
        
        float r = ((float)_fontColor.r)/255;
        float g = ((float)_fontColor.g)/255;
        float b = ((float)_fontColor.b)/255;
        float a = ((float)_fontColor.a)/255;
        
        NSColor* color = [NSColor colorWithCalibratedRed:r green:g blue:b alpha:a];
        
        [formattedAttributedString addAttribute:NSForegroundColorAttributeName value:color range:fullRange];
    }
    else
    {
        useFullColor = YES;
    }
    
    // Font
    if (![formattedAttributedString hasAttribute:NSFontAttributeName])
    {
        NSFont* font = [NSFont fontWithName:_fontName size:_fontSize];
        if (!font) font = [NSFont fontWithName:@"Helvetica" size:_fontSize];
        [formattedAttributedString addAttribute:NSFontAttributeName value:font range:fullRange];
    }
    
    // Shadow
    if ([formattedAttributedString hasAttribute:NSShadowAttributeName])
    {
        useFullColor = YES;
    }
    
    // Text alignment
    if (![formattedAttributedString hasAttribute:NSParagraphStyleAttributeName])
    {
        NSMutableParagraphStyle* style = [[NSMutableParagraphStyle alloc] init];
        
        if (_horizontalAlignment == CCTextAlignmentLeft) style.alignment = NSLeftTextAlignment;
        else if (_horizontalAlignment == CCTextAlignmentCenter) style.alignment = NSCenterTextAlignment;
        else if (_horizontalAlignment == CCTextAlignmentRight) style.alignment = NSRightTextAlignment;
        
        [formattedAttributedString addAttribute:NSParagraphStyleAttributeName value:style range:fullRange];
    }
#endif
    

    // Generate a new texture from the attributed string
	CCTexture *tex;
    
    tex = [self createTextureWithAttributedString:[formattedAttributedString copyAdjustedForContentScaleFactor] useFullColor:useFullColor];

	if( !tex )
		return NO;
    
    if (!useFullColor)
    {
        self.shaderProgram = [[CCShaderCache sharedShaderCache] programForKey:kCCShader_PositionTextureA8Color];
    }
    else
    {
        self.shaderProgram = [[CCShaderCache sharedShaderCache] programForKey:kCCShader_PositionTextureColor];
    }

#ifdef __CC_PLATFORM_IOS
	// iPad ?
	if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) {
		if( CC_CONTENT_SCALE_FACTOR() == 2 )
			[tex setResolutionType:CCResolutionTypeiPadRetinaDisplay];
		else
			[tex setResolutionType:CCResolutionTypeiPad];
	}
	// iPhone ?
	else
	{
		if( CC_CONTENT_SCALE_FACTOR() == 2 )
			[tex setResolutionType:CCResolutionTypeiPhoneRetinaDisplay];
		else
			[tex setResolutionType:CCResolutionTypeiPhone];
	}
#endif
	
    // Update texture and content size
	[self setTexture:tex];
	
	CGRect rect = CGRectZero;
	rect.size = [_texture contentSize];
	[self setTextureRect: rect];
	
	return YES;
}

- (CCTexture*) createTextureWithAttributedString:(NSAttributedString*)attributedString useFullColor:(BOOL) fullColor
{
	NSAssert(attributedString, @"Invalid attributedString");
    
    CGSize originalDimensions = _dimensions;
    
#ifdef __CC_PLATFORM_IOS
    originalDimensions.width *= CC_CONTENT_SCALE_FACTOR();
    originalDimensions.height *= CC_CONTENT_SCALE_FACTOR();
#endif
    
    CGSize dimensions = originalDimensions;
    
    float shadowBlurRadius = _shadowBlurRadius * CC_CONTENT_SCALE_FACTOR();
    CGPoint shadowOffset = ccpMult(_shadowOffset, CC_CONTENT_SCALE_FACTOR());
    float outlineWidth = _outlineWidth * CC_CONTENT_SCALE_FACTOR();
    
    BOOL hasShadow = (_shadowColor.a > 0);
    BOOL hasOutline = (_outlineColor.a > 0 && _outlineWidth > 0);
    
    float xOffset = 0;
    float yOffset = 0;
    float scaleFactor = 1;
    
    float xPadding = 0;
    float yPadding = 0;
    float wDrawArea = 0;
    float hDrawArea = 0;
    
    // Calculate padding
    if (hasShadow)
    {
        xPadding = (shadowBlurRadius + fabs(shadowOffset.x));
        yPadding = (shadowBlurRadius + fabs(shadowOffset.y));
    }
    if (hasOutline)
    {
        xPadding += outlineWidth;
        yPadding += outlineWidth;
    }
    
	// Get actual rendered dimensions
    if (dimensions.height == 0)
    {
        // Get dimensions for string without dimensions of string with variable height
#ifdef __CC_PLATFORM_IOS
        dimensions = [attributedString boundingRectWithSize:dimensions options:NSStringDrawingUsesLineFragmentOrigin context:NULL].size;
#elif defined(__CC_PLATFORM_MAC)
        dimensions = [attributedString boundingRectWithSize:NSSizeFromCGSize(dimensions) options:NSStringDrawingUsesLineFragmentOrigin].size;
#endif
        
        wDrawArea = dimensions.width;
        hDrawArea = dimensions.height;
        
        dimensions.width += xPadding * 2;
        dimensions.height += yPadding * 2;
    }
    else if (dimensions.width > 0 && dimensions.height > 0)
    {
        wDrawArea = dimensions.width - xPadding * 2;
        hDrawArea = dimensions.height - yPadding * 2;
        
        // Handle strings with fixed dimensions
        if (_adjustsFontSizeToFit)
        {
            float fontSize = [attributedString singleFontSize];
            if (fontSize)
            {
                // This is a string that can be resized (it only uses one font and size)
#ifdef __CC_PLATFORM_IOS
                CGSize wantedSize = [attributedString boundingRectWithSize:CGSizeZero options:NSStringDrawingUsesLineFragmentOrigin context:NULL].size;
#elif defined(__CC_PLATFORM_MAC)
                CGSize wantedSize = [attributedString boundingRectWithSize:CGSizeZero options:NSStringDrawingUsesLineFragmentOrigin].size;
#endif
                
                float wScaleFactor = 1;
                float hScaleFactor = 1;
                if (wantedSize.width > wDrawArea)
                {
                    wScaleFactor = wDrawArea/wantedSize.width;
                }
                if (wantedSize.height > hDrawArea)
                {
                    hScaleFactor = hDrawArea/wantedSize.height;
                }
                
                if (wScaleFactor < hScaleFactor) scaleFactor = wScaleFactor;
                else scaleFactor = hScaleFactor;
            
                if (scaleFactor != 1)
                {
                    float newFontSize = fontSize * scaleFactor;
                    float minFontSize = _minimumFontSize * CC_CONTENT_SCALE_FACTOR();
                    if (minFontSize && newFontSize < minFontSize) newFontSize = minFontSize;
                    attributedString = [attributedString copyWithNewFontSize:newFontSize];
                }
            }
        }

        // Handle vertical alignment
#ifdef __CC_PLATFORM_IOS
        CGSize actualSize = [attributedString boundingRectWithSize:CGSizeMake(wDrawArea, 0) options:NSStringDrawingUsesLineFragmentOrigin context:NULL].size;
#elif defined(__CC_PLATFORM_MAC)
        CGSize actualSize = NSSizeToCGSize([attributedString boundingRectWithSize:NSMakeSize(wDrawArea, 0) options:NSStringDrawingUsesLineFragmentOrigin].size);
#endif
        if (_verticalAlignment == CCVerticalTextAlignmentBottom)
        {
            yOffset = hDrawArea - actualSize.height;
        }
        else if (_verticalAlignment == CCVerticalTextAlignmentCenter)
        {
            yOffset = (hDrawArea - actualSize.height)/2;
        }
    }
    
    // Handle baseline adjustments
    yOffset += _baselineAdjustment * scaleFactor * CC_CONTENT_SCALE_FACTOR() + yPadding;
    xOffset += xPadding;
    
    // Round dimensions to nearest number that is dividable by 2
    dimensions.width = ceilf(dimensions.width/2)*2;
    dimensions.height = ceilf(dimensions.height/2)*2;
    
    // get nearest power of two
    CGSize POTSize = CGSizeMake(CCNextPOT(dimensions.width), CCNextPOT(dimensions.height));
    
	// Mac crashes if the width or height is 0
	if( POTSize.width == 0 )
		POTSize.width = 2;
    
	if( POTSize.height == 0)
		POTSize.height = 2;
    
    // Render the label - different code for Mac / iOS
    
#ifdef __CC_PLATFORM_IOS
    yOffset = (POTSize.height - dimensions.height) + yOffset;
	
	CGRect drawArea = CGRectMake(xOffset, yOffset, wDrawArea, hDrawArea);
    
    unsigned char* data = calloc(POTSize.width, POTSize.height * 4);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(data, POTSize.width, POTSize.height, 8, POTSize.width * 4, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    
    if (!context)
    {
        free(data);
        return NULL;
    }
    
    CGAffineTransform flipVertical = CGAffineTransformMake(1, 0, 0, -1, 0, POTSize.height * 2 - dimensions.height);
    CGContextConcatCTM(context, flipVertical);
    
	UIGraphicsPushContext(context);
    
    // Handle shadow
    if (hasShadow)
    {
        float r = ((float)_shadowColor.r)/255;
        float g = ((float)_shadowColor.g)/255;
        float b = ((float)_shadowColor.b)/255;
        float a = ((float)_shadowColor.a)/255;
        
        UIColor* color = [UIColor colorWithRed:r green:g blue:b alpha:a];
        
        CGContextSetShadowWithColor(context, CGSizeMake(shadowOffset.x, shadowOffset.y), shadowBlurRadius, [color CGColor]);
    }
    
    // Handle outline
    if (hasOutline)
    {
        float r = ((float)_outlineColor.r)/255;
        float g = ((float)_outlineColor.g)/255;
        float b = ((float)_outlineColor.b)/255;
        float a = ((float)_outlineColor.a)/255;
        
        UIColor* color = [UIColor colorWithRed:r green:g blue:b alpha:a];
        
        CGContextSetTextDrawingMode(context, kCGTextFillStroke);
        CGContextSetLineWidth(context, outlineWidth * 2);
        CGContextSetLineJoin(context, kCGLineJoinRound);
        CGContextSetStrokeColorWithColor(context, [color CGColor]);
        
        NSMutableAttributedString* outlineString = [attributedString mutableCopy];
        [outlineString removeAttribute:NSForegroundColorAttributeName range:NSMakeRange(0, outlineString.length)];
        
        [outlineString drawInRect:drawArea];
        
        CGContextSetTextDrawingMode(context, kCGTextFill);
        
        // Don't draw shadow for main font
        CGContextSetShadowWithColor(context, CGSizeZero, 0, NULL);
        
        if (hasShadow)
        {
            // Draw outline again because shadow overlap
            [outlineString drawInRect:drawArea];
        }
    }
    
    [attributedString drawInRect:drawArea];
    
    UIGraphicsPopContext();
    CGContextRelease(context);
    
#elif defined(__CC_PLATFORM_MAC)
    yOffset = (POTSize.height - hDrawArea) - yOffset;
	
	CGRect drawArea = CGRectMake(xOffset, yOffset, wDrawArea, hDrawArea);
	
	NSImage *image = [[NSImage alloc] initWithSize:POTSize];
	[image lockFocus];
	[[NSAffineTransform transform] set];
    
    // XXX: The shadows are for some reason scaled on OS X if a retina display is connected
    float retinaFix = 1;
    for (NSScreen* screen in [NSScreen screens])
    {
        if (screen.backingScaleFactor > retinaFix) retinaFix = screen.backingScaleFactor;
    }
    
    CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
    
    // Handle shadow
    if (hasShadow || hasOutline)
    {
        NSMutableAttributedString* effectsString = [attributedString mutableCopy];
        
        if (hasShadow)
        {
            float r = ((float)_shadowColor.r)/255;
            float g = ((float)_shadowColor.g)/255;
            float b = ((float)_shadowColor.b)/255;
            float a = ((float)_shadowColor.a)/255;
            NSColor* color = [NSColor colorWithCalibratedRed:r green:g blue:b alpha:a];
            
            CGContextSetShadowWithColor(context, CGSizeMake(shadowOffset.x/retinaFix, shadowOffset.y/retinaFix), shadowBlurRadius/retinaFix, [color CGColor]);
        }
        
        if (hasOutline)
        {
            
            CGContextSetTextDrawingMode(context, kCGTextFillStroke);
            CGContextSetLineWidth(context, outlineWidth * 2);
            CGContextSetLineJoin(context, kCGLineJoinRound);
            
            float r = ((float)_outlineColor.r)/255;
            float g = ((float)_outlineColor.g)/255;
            float b = ((float)_outlineColor.b)/255;
            float a = ((float)_outlineColor.a)/255;
            NSColor* color = [NSColor colorWithCalibratedRed:r green:g blue:b alpha:a];
            
            [effectsString addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0, effectsString.length)];
            
            [effectsString drawWithRect:NSRectFromCGRect(drawArea) options:NSStringDrawingUsesLineFragmentOrigin];
            
            if (hasShadow)
            {
                CGContextSetShadowWithColor(context, CGSizeZero, 0, NULL);
                [effectsString drawInRect:drawArea];
            }
            CGContextSetTextDrawingMode(context, kCGTextFill);
        }
    }
	
    [attributedString drawWithRect:NSRectFromCGRect(drawArea) options:NSStringDrawingUsesLineFragmentOrigin];
	
	NSBitmapImageRep *bitmap = [[NSBitmapImageRep alloc] initWithFocusedViewRect:NSMakeRect (0.0f, 0.0f, POTSize.width, POTSize.height)];
	[image unlockFocus];
    
	unsigned char *data = (unsigned char*) [bitmap bitmapData];  //Use the same buffer to improve the performance.
#endif
    
    CCTexture* texture = NULL;
    
    // Initialize the texture
    if (fullColor)
    {
        // RGBA8888 format
        texture = [[CCTexture alloc] initWithData:data pixelFormat:CCTexturePixelFormat_RGBA8888 pixelsWide:POTSize.width pixelsHigh:POTSize.height contentSize:dimensions];
        [texture setPremultipliedAlpha:YES];
    }
    else
    {
        NSUInteger textureSize = POTSize.width * POTSize.height;
        
        // A8 format (alpha channel only)
        unsigned char* dst = data;
        for(int i = 0; i<textureSize; i++)
            dst[i] = data[i*4+3];
        
        texture = [[CCTexture alloc] initWithData:data pixelFormat:CCTexturePixelFormat_A8 pixelsWide:POTSize.width pixelsHigh:POTSize.height contentSize:dimensions];
        self.shaderProgram = [[CCShaderCache sharedShaderCache] programForKey:kCCShader_PositionTextureA8Color];
    }
    
#ifdef __CC_PLATFORM_IOS
    free(data); // On Mac data is freed by NSBitmapImageRep
#endif
    
	return texture;
}


#pragma mark -
#pragma mark Render Font iOS 5

#ifdef __CC_PLATFORM_IOS
- (BOOL) updateTextureOld
{
    NSString* string = [self string];
    if (!string) return NO;
    
    BOOL useFullColor = NO;
    if (_shadowColor.a > 0) useFullColor = YES;
    if (!ccc4BEqual(_fontColor, ccc4(255, 255, 255, 255))) useFullColor = YES;
    if (_outlineColor.a > 0 && _outlineWidth > 0) useFullColor = YES;
    
    CCTexture* tex = [self createTextureWithString:string useFullColor:useFullColor];
    if (!tex) return NO;
    
    if (!useFullColor)
    {
        self.shaderProgram = [[CCShaderCache sharedShaderCache] programForKey:kCCShader_PositionTextureA8Color];
    }
    
    if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) {
		if( CC_CONTENT_SCALE_FACTOR() == 2 )
			[tex setResolutionType:CCResolutionTypeiPadRetinaDisplay];
		else
			[tex setResolutionType:CCResolutionTypeiPad];
	}
	// iPhone ?
	else
	{
		if( CC_CONTENT_SCALE_FACTOR() == 2 )
			[tex setResolutionType:CCResolutionTypeiPhoneRetinaDisplay];
		else
			[tex setResolutionType:CCResolutionTypeiPhone];
	}
    
    // Update texture and content size
	[self setTexture:tex];
	
	CGRect rect = CGRectZero;
	rect.size = [_texture contentSize];
	[self setTextureRect: rect];
	
	return YES;
}

- (CCTexture*) createTextureWithString:(NSString*) string useFullColor:(BOOL)useFullColor
{
    // Scale everything up by content scale
    UIFont* font = [UIFont fontWithName:_fontName size:_fontSize * CC_CONTENT_SCALE_FACTOR()];
    float shadowBlurRadius = _shadowBlurRadius * CC_CONTENT_SCALE_FACTOR();
    CGPoint shadowOffset = ccpMult(_shadowOffset, CC_CONTENT_SCALE_FACTOR());
    float outlineWidth = _outlineWidth * CC_CONTENT_SCALE_FACTOR();
    
    BOOL hasShadow = (_shadowColor.a > 0);
    BOOL hasOutline = (_outlineColor.a > 0 && _outlineWidth > 0);
    
    float xOffset = 0;
    float yOffset = 0;
    float scaleFactor = 1;
    
    float xPadding = 0;
    float yPadding = 0;
    float wDrawArea = 0;
    float hDrawArea = 0;
    
    CGSize originalDimensions = _dimensions;
    originalDimensions.width *= CC_CONTENT_SCALE_FACTOR();
    originalDimensions.height *= CC_CONTENT_SCALE_FACTOR();
    
    // Calculate padding
    if (hasShadow)
    {
        xPadding = (shadowBlurRadius + fabs(shadowOffset.x));
        yPadding = (shadowBlurRadius + fabs(shadowOffset.y));
    }
    if (hasOutline)
    {
        xPadding += outlineWidth;
        yPadding += outlineWidth;
    }
    
    CGSize dimensions = originalDimensions;
    
    // Get actual rendered dimensions
    if (dimensions.height == 0)
    {
        // Get dimensions for string without dimensions of string with variable height
        if (dimensions.width > 0)
        {
            dimensions = [string sizeWithFont:font forWidth:dimensions.width lineBreakMode:0];
        }
        else
        {
            CGSize firstLineSize = [string sizeWithFont:font];
            dimensions = [string sizeWithFont:font constrainedToSize:CGSizeMake(firstLineSize.width,1024) lineBreakMode:0];
        }
        
        wDrawArea = dimensions.width;
        hDrawArea = dimensions.height;
        
        dimensions.width += xPadding * 2;
        dimensions.height += yPadding * 2;
    }
    else if (dimensions.width > 0 && dimensions.height > 0)
    {
        wDrawArea = dimensions.width - xPadding * 2;
        hDrawArea = dimensions.height - yPadding * 2;
        
        // Handle strings with fixed dimensions
        if (_adjustsFontSizeToFit)
        {
            float fontSize = font.pointSize;
            CGSize wantedSizeFirstLine = [string sizeWithFont:font];
            CGSize wantedSize = [string sizeWithFont:font constrainedToSize:CGSizeMake(wantedSizeFirstLine.width, 1024) lineBreakMode:0];
            
            float wScaleFactor = 1;
            float hScaleFactor = 1;
            if (wantedSize.width > wDrawArea)
            {
                wScaleFactor = wDrawArea/wantedSize.width;
            }
            if (wantedSize.height > hDrawArea)
            {
                hScaleFactor = hDrawArea/wantedSize.height;
            }
            
            if (wScaleFactor < hScaleFactor) scaleFactor = wScaleFactor;
            else scaleFactor = hScaleFactor;
            
            if (scaleFactor != 1)
            {
                float newFontSize = fontSize * scaleFactor;
                float minFontSize = _minimumFontSize * CC_CONTENT_SCALE_FACTOR();
                if (minFontSize && newFontSize < minFontSize) newFontSize = minFontSize;
                font = [UIFont fontWithName:font.fontName size:newFontSize];
            }
        }
        
        // Handle vertical alignment
        CGSize actualSize = [string sizeWithFont:font constrainedToSize:CGSizeMake(wDrawArea, 1024) lineBreakMode:0];
    
        if (_verticalAlignment == CCVerticalTextAlignmentBottom)
        {
            yOffset = hDrawArea - actualSize.height;
        }
        else if (_verticalAlignment == CCVerticalTextAlignmentCenter)
        {
            yOffset = (hDrawArea - actualSize.height)/2;
        }
    }
    
    // Handle baseline adjustments
    yOffset += _baselineAdjustment * scaleFactor * CC_CONTENT_SCALE_FACTOR() + yPadding;
    xOffset += xPadding;
    
    // Round dimensions to nearest number that is dividable by 2
    dimensions.width = ceilf(dimensions.width/2)*2;
    dimensions.height = ceilf(dimensions.height/2)*2;

    // get nearest power of two
    CGSize POTSize = CGSizeMake(CCNextPOT(dimensions.width), CCNextPOT(dimensions.height));

    // Mac crashes if the width or height is 0
    if( POTSize.width == 0 )
    POTSize.width = 2;

    if( POTSize.height == 0)
    POTSize.height = 2;

    yOffset = (POTSize.height - dimensions.height) + yOffset;

    CGRect drawArea = CGRectMake(xOffset, yOffset, wDrawArea, hDrawArea);

    unsigned char* data = calloc(POTSize.width, POTSize.height * 4);

    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(data, POTSize.width, POTSize.height, 8, POTSize.width * 4, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);

    if (!context)
    {
        free(data);
        return NULL;
    }

    CGAffineTransform flipVertical = CGAffineTransformMake(1, 0, 0, -1, 0, POTSize.height * 2 - dimensions.height);
    CGContextConcatCTM(context, flipVertical);

    UIGraphicsPushContext(context);
    
    // Handle shadow
    if (hasShadow)
    {
        float r = ((float)_shadowColor.r)/255;
        float g = ((float)_shadowColor.g)/255;
        float b = ((float)_shadowColor.b)/255;
        float a = ((float)_shadowColor.a)/255;
        
        UIColor* color = [UIColor colorWithRed:r green:g blue:b alpha:a];
        
        CGContextSetShadowWithColor(context, CGSizeMake(shadowOffset.x, shadowOffset.y), shadowBlurRadius, [color CGColor]);
    }
    
    // Handle outline
    if (hasOutline)
    {
        float r = ((float)_outlineColor.r)/255;
        float g = ((float)_outlineColor.g)/255;
        float b = ((float)_outlineColor.b)/255;
        float a = ((float)_outlineColor.a)/255;
        
        CGContextSetTextDrawingMode(context, kCGTextFillStroke);
        CGContextSetRGBStrokeColor(context, r, g, b, a);
        CGContextSetRGBFillColor(context, r, g, b, a);
        CGContextSetLineWidth(context, outlineWidth * 2);
        CGContextSetLineJoin(context, kCGLineJoinRound);
        
        [string drawInRect:drawArea withFont:font lineBreakMode:0 alignment:(int)_horizontalAlignment];
        
        // Don't draw shadow for main font
        CGContextSetShadowWithColor(context, CGSizeZero, 0, NULL);
        
        if (hasShadow)
        {
            // Draw again, because shadows overlap
            [string drawInRect:drawArea withFont:font lineBreakMode:0 alignment:(int)_horizontalAlignment];
        }
        
        CGContextSetTextDrawingMode(context, kCGTextFill);
    }
    
    // Handle font color
    float r = ((float)_fontColor.r)/255;
    float g = ((float)_fontColor.g)/255;
    float b = ((float)_fontColor.b)/255;
    float a = ((float)_fontColor.a)/255;
    
    UIColor* color = [UIColor colorWithRed:r green:g blue:b alpha:a];
    [color set];
    
    [string drawInRect:drawArea withFont:font lineBreakMode:0 alignment:(int)_horizontalAlignment];

    UIGraphicsPopContext();
    CGContextRelease(context);

    CCTexture* texture = NULL;

    // Initialize the texture
    if (useFullColor)
    {
        // RGBA8888 format
        texture = [[CCTexture alloc] initWithData:data pixelFormat:CCTexturePixelFormat_RGBA8888 pixelsWide:POTSize.width pixelsHigh:POTSize.height contentSize:dimensions];
        [texture setPremultipliedAlpha:YES];
    }
    else
    {
        NSUInteger textureSize = POTSize.width * POTSize.height;
        
        // A8 format (alpha channel only)
        unsigned char* dst = data;
        for(int i = 0; i<textureSize; i++)
            dst[i] = data[i*4+3];
        
        texture = [[CCTexture alloc] initWithData:data pixelFormat:CCTexturePixelFormat_A8 pixelsWide:POTSize.width pixelsHigh:POTSize.height contentSize:dimensions];
        self.shaderProgram = [[CCShaderCache sharedShaderCache] programForKey:kCCShader_PositionTextureA8Color];
    }

    free(data);

    return texture;
}

#endif

#pragma mark -
#pragma mark Handle HTML

#ifdef __CC_PLATFORM_MAC
- (void) setHTML:(NSString *)html
{
    NSData* data = [html dataUsingEncoding:NSUTF8StringEncoding];
    
    self.attributedString = [[NSAttributedString alloc] initWithHTML:data documentAttributes:NULL];
}
#endif



#pragma mark Class functions

+ (void) registerCustomTTF:(NSString *)fontFile
{
    // Do not register a font if it has already been registered
    if (!ccLabelTTF_registeredFonts)
    {
        ccLabelTTF_registeredFonts = [[NSMutableDictionary alloc] init];
    }
    
    if ([ccLabelTTF_registeredFonts objectForKey:fontFile]) return;
    [ccLabelTTF_registeredFonts setObject:[NSNumber numberWithBool:YES] forKey:fontFile];
    
    // Register with font manager
    if ([[fontFile lowercaseString] hasSuffix:@".ttf"])
    {
        // This is a file, register font with font manager
        NSString* fontPath = [[CCFileUtils sharedFileUtils] fullPathForFilename:fontFile];
        NSURL* fontURL = [NSURL fileURLWithPath:fontPath];
        CTFontManagerRegisterFontsForURL((__bridge CFURLRef)fontURL, kCTFontManagerScopeProcess, NULL);
    }
}

@end
