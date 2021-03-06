#import "ARNavigationButton.h"

#import "ARFonts.h"

#import <FLKAutoLayout/UIView+FLKAutoLayout.h>
#import <ObjectiveSugar/ObjectiveSugar.h>


@interface ARNavigationButton ()

@property (nonatomic, strong, readonly) UILabel *primaryTitleLabel;
@property (nonatomic, strong, readonly) UILabel *subtitleLabel;
@property (nonatomic, strong, readonly) UIView *topBorder;
@property (nonatomic, strong, readonly) UIView *bottomBorder;
@property (nonatomic, strong, readonly) UIImageView *arrowView;
@property (nonatomic, assign, readonly) CGFloat borderWidth;

@end


@implementation ARNavigationButton

- (id)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame withBorder:1];
}

- (id)initWithFrame:(CGRect)frame withBorder:(CGFloat)borderWidth
{
    self = [super initWithFrame:frame];
    if (!self) {
        return nil;
    }

    _borderWidth = borderWidth;
    _topBorder = [[UIView alloc] init];
    self.topBorder.backgroundColor = [UIColor artsyGrayRegular];
    [self addSubview:self.topBorder];

    _primaryTitleLabel = [[UILabel alloc] init];
    self.primaryTitleLabel.numberOfLines = 1;
    self.primaryTitleLabel.backgroundColor = [UIColor clearColor];
    self.primaryTitleLabel.font = [UIFont sansSerifFontWithSize:12];
    [self addSubview:self.primaryTitleLabel];

    _subtitleLabel = [[UILabel alloc] init];
    self.subtitleLabel.numberOfLines = 1;
    self.subtitleLabel.backgroundColor = [UIColor clearColor];
    self.subtitleLabel.font = [UIFont serifFontWithSize:14];
    self.subtitleLabel.textColor = [UIColor blackColor];
    [self addSubview:self.subtitleLabel];

    _arrowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"navigation_more_arrow_horizontal@2x"]];
    self.arrowView.backgroundColor = [UIColor clearColor];
    self.arrowView.contentMode = UIViewContentModeCenter;
    [self addSubview:self.arrowView];

    _bottomBorder = [[UIView alloc] init];
    [self.bottomBorder constrainHeight:NSStringWithFormat(@"%f", borderWidth)];
    self.bottomBorder.backgroundColor = [UIColor artsyGrayRegular];
    [self addSubview:self.bottomBorder];

    [self setNeedsUpdateConstraints];

    return self;
}

- (id)initWithTitle:(NSString *)title
{
    return [self initWithTitle:title andSubtitle:nil];
}

- (id)initWithTitle:(NSString *)title andSubtitle:(NSString *)subtitle
{
    return [self initWithTitle:title andSubtitle:subtitle withBorder:1];
}

- (id)initWithTitle:(NSString *)title andSubtitle:(NSString *)subtitle withBorder:(CGFloat)borderWidth
{
    return [self initWithFrame:CGRectZero andTitle:title andSubtitle:subtitle withBorder:borderWidth];
}

- (id)initWithFrame:(CGRect)frame andTitle:(NSString *)title andSubtitle:(NSString *)subtitle withBorder:(CGFloat)borderWidth
{
    self = [self initWithFrame:frame withBorder:borderWidth];
    if (!self) {
        return nil;
    }

    self.title = title;
    self.subtitle = subtitle;

    [self updateConstraintsIfNeeded];

    return self;
}

- (CGFloat)verticalPadding
{
    return self.subtitle.length == 0 ? 15 : 12;
}

- (void)updateConstraints
{
    NSString *paddingHeight = NSStringWithFormat(@"%f", self.verticalPadding);

    [self.topBorder removeConstraints:self.topBorder.constraints];
    [self.topBorder constrainHeight:NSStringWithFormat(@"%f", self.borderWidth)];
    [self.topBorder alignCenterXWithView:self predicate:@"0"];
    [self.topBorder constrainWidthToView:self predicate:@"0"];
    [self alignTopEdgeWithView:self.topBorder predicate:@"0"];

    [self.primaryTitleLabel removeConstraints:self.primaryTitleLabel.constraints];
    [self.primaryTitleLabel constrainTopSpaceToView:self.topBorder predicate:paddingHeight];
    [self.primaryTitleLabel alignLeadingEdgeWithView:self predicate:@"0"];
    [self.primaryTitleLabel alignTrailingEdgeWithView:self predicate:@"-26"];

    [self.subtitleLabel removeConstraints:self.subtitleLabel.constraints];
    [self.subtitleLabel constrainTopSpaceToView:self.primaryTitleLabel predicate:@"0"];
    [self.subtitleLabel alignLeadingEdgeWithView:self predicate:@"0"];
    [self.subtitleLabel alignTrailingEdgeWithView:self predicate:@"-26"];

    [self.arrowView removeConstraints:self.arrowView.constraints];
    [self.arrowView alignTrailingEdgeWithView:self predicate:@"0"];
    [self.arrowView alignCenterYWithView:self predicate:@"0"];

    [self.bottomBorder removeConstraints:self.bottomBorder.constraints];
    [self.bottomBorder constrainHeight:NSStringWithFormat(@"%f", self.borderWidth)];
    [self.bottomBorder constrainTopSpaceToView:self.subtitleLabel predicate:paddingHeight];
    [self.bottomBorder alignCenterXWithView:self predicate:@"0"];
    [self.bottomBorder constrainWidthToView:self predicate:@"0"];
    [self alignBottomEdgeWithView:self.bottomBorder predicate:@"0"];

    [super updateConstraints];
}

- (void)setTitle:(NSString *)title
{
    _title = [title copy];

    self.primaryTitleLabel.text = title.uppercaseString;
}

- (void)setSubtitle:(NSString *)subtitle
{
    _subtitle = [subtitle copy];

    if (_subtitle) {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.minimumLineHeight = 17;
        NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:_subtitle attributes:@{NSParagraphStyleAttributeName : paragraphStyle}];
        self.subtitleLabel.attributedText = attrString;
    }
}

#pragma mark - UIView

- (void)tappedButton
{
    [self sendActionsForControlEvents:UIControlEventTouchUpInside];
}

- (void)setEnabled:(BOOL)enabled
{
    [super setEnabled:enabled];

    self.primaryTitleLabel.alpha = enabled ? 1 : 0.6;
    self.arrowView.alpha = enabled ? 1 : 0.6;
}

- (void)setOnTap:(void (^)(UIButton *))onTap
{
    _onTap = [onTap copy];
    [self addTarget:self action:@selector(tappedForBlockAPI:) forControlEvents:UIControlEventTouchUpInside];
}


- (void)tappedForBlockAPI:(id)sender
{
    self.onTap(self);
}

@end


@implementation ARSerifNavigationButton

- (id)initWithFrame:(CGRect)frame withBorder:(CGFloat)borderWidth
{
    self = [super initWithFrame:frame withBorder:borderWidth];
    if (self) {
        self.primaryTitleLabel.font = [UIFont serifFontWithSize:18];
        self.subtitleLabel.font = [UIFont serifFontWithSize:16];
    }

    [self setNeedsUpdateConstraints];
    [self updateConstraintsIfNeeded];

    return self;
}

- (void)setTitle:(NSString *)title
{
    [super setTitle:title];

    self.primaryTitleLabel.text = title;
}

@end
