/*
 
 MIT License (MIT)
 
 Copyright (c) 2016 DarlingCoder
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 
 */

#import "PureLayout.h"
#import "DLPhotoPickerDefines.h"
#import "DLPhotoSelectionButton.h"
#import "DLPhotoCheckmark.h"
#import "NSBundle+DLPhotoPicker.h"
#import "UIImage+DLPhotoPicker.h"



@interface DLPhotoSelectionButton ()

@property (nonatomic, strong) DLPhotoCheckmark *checkmark;
@property (nonatomic, strong) UIImageView *backgroundView;

@property (nonatomic, assign) BOOL didSetupConstraints;

@end





@implementation DLPhotoSelectionButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        self.isAccessibilityElement = YES;
        self.accessibilityTraits = UIAccessibilityTraitButton;
        
        [self setupViews];
        [self localize];
    }
    
    return self;
}

#pragma mark - Setup

- (void)setupViews
{
    // Background
    UIImage *backgroundImage = [UIImage assetImageNamed:@"CheckmarkUnselected"];
    UIImageView *backgroundView = [[UIImageView alloc] initWithImage:backgroundImage];
    backgroundView.userInteractionEnabled = NO;
    self.backgroundView = backgroundView;
    
    [self addSubview:self.backgroundView];
    
    // Checkmark
    DLPhotoCheckmark *checkmark = [DLPhotoCheckmark newAutoLayoutView];
    checkmark.userInteractionEnabled = NO;
    checkmark.hidden = YES;
    self.checkmark = checkmark;
    
    [self addSubview:self.checkmark];
}

- (void)localize
{
    self.accessibilityLabel = DLPhotoPickerLocalizedString(@"Select", nil);
}

- (void)updateConstraints
{
    if (!self.didSetupConstraints)
    {
        CGSize size = [UIImage assetImageNamed:@"CheckmarkUnselected"].size;
        
        [NSLayoutConstraint autoSetPriority:UILayoutPriorityRequired forConstraints:^{
            [self autoSetDimensionsToSize:size];
        }];
        
        [self.backgroundView autoCenterInSuperview];
        [self.checkmark autoCenterInSuperview];
        
        self.didSetupConstraints = YES;
    }
    
    [super updateConstraints];
}

#pragma mark - States

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    self.checkmark.hidden = !selected;
    
    self.accessibilityLabel = (selected) ? DLPhotoPickerLocalizedString(@"Deselect", nil) : DLPhotoPickerLocalizedString(@"Select", nil);
}


@end
