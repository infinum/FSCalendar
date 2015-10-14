//
//  FSCalendarCell.m
//  Pods
//
//  Created by Wenchao Ding on 12/3/15.
//
//

#import "FSCalendarCell.h"
#import "FSCalendar.h"
#import "UIView+FSExtension.h"
#import "NSDate+FSExtension.h"
#import "FSCalendarDynamicHeader.h"
#import "FSCalendarConstance.h"

@interface FSCalendarCell ()

@property (readonly, nonatomic) UIColor *colorForBackgroundLayer;
@property (readonly, nonatomic) UIColor *colorForTitleLabel;
@property (readonly, nonatomic) UIColor *colorForSubtitleLabel;

@end

@implementation FSCalendarCell

#pragma mark - Life cycle

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.font = [UIFont systemFontOfSize:13];
        titleLabel.textColor = [UIColor darkTextColor];
        [self.contentView addSubview:titleLabel];
        self.titleLabel = titleLabel;
        
        UILabel *subtitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        subtitleLabel.textAlignment = NSTextAlignmentCenter;
        subtitleLabel.font = [UIFont systemFontOfSize:10];
        subtitleLabel.textColor = [UIColor lightGrayColor];
        [self.contentView addSubview:subtitleLabel];
        self.subtitleLabel = subtitleLabel;
        
        CAShapeLayer *backgroundLayer = [CAShapeLayer layer];
        backgroundLayer.backgroundColor = [UIColor clearColor].CGColor;
        backgroundLayer.hidden = YES;
        [self.contentView.layer insertSublayer:backgroundLayer below:_titleLabel.layer];
        self.backgroundLayer = backgroundLayer;
        
        CAShapeLayer *periodLayer = [CAShapeLayer layer];
        periodLayer.backgroundColor = [UIColor clearColor].CGColor;
        periodLayer.hidden = YES;
        [self.contentView.layer insertSublayer:periodLayer below:self.backgroundLayer];
        self.periodLayer = periodLayer;
        
        CAShapeLayer *eventLayer = [CAShapeLayer layer];
        eventLayer.backgroundColor = [UIColor clearColor].CGColor;
        eventLayer.fillColor = [UIColor cyanColor].CGColor;
        eventLayer.path = [UIBezierPath bezierPathWithOvalInRect:eventLayer.bounds].CGPath;
        eventLayer.hidden = YES;
        [self.contentView.layer addSublayer:eventLayer];
        self.eventLayer = eventLayer;
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        imageView.contentMode = UIViewContentModeCenter;
        [self.contentView addSubview:imageView];
        self.imageView = imageView;
        
        UIImageView *intimateImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        intimateImageView.contentMode = UIViewContentModeCenter;
        [self.contentView addSubview:intimateImageView];
        self.intimateImageView = intimateImageView;
        
        UIImageView *noteImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        noteImageView.contentMode = UIViewContentModeCenter;
        [self.contentView addSubview:noteImageView];
        self.noteImageView = noteImageView;
        
        self.clipsToBounds = NO;
        self.contentView.clipsToBounds = NO;
    }
    return self;
}

- (void)setBounds:(CGRect)bounds
{
    [super setBounds:bounds];
    CGFloat titleHeight = self.bounds.size.height*5.0/6.0;
    CGFloat diameter = MIN(self.bounds.size.height*5.0/6.0,self.bounds.size.width);
    _backgroundLayer.frame = CGRectMake((self.bounds.size.width-diameter)/2,
                                        (titleHeight-diameter)/2,
                                        diameter,
                                        diameter);
    
    CGFloat eventSize = _backgroundLayer.frame.size.height/6.0;
    _eventLayer.frame = CGRectMake((_backgroundLayer.frame.size.width-eventSize)/2+_backgroundLayer.frame.origin.x, CGRectGetMaxY(_backgroundLayer.frame)+eventSize*0.2, eventSize*0.8, eventSize*0.8);
    _eventLayer.path = [UIBezierPath bezierPathWithOvalInRect:_eventLayer.bounds].CGPath;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self configureCell];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    [CATransaction setDisableActions:YES];
}

#pragma mark - Public

- (void)performSelecting
{
    _backgroundLayer.hidden = NO;
    _backgroundLayer.path = [UIBezierPath bezierPathWithOvalInRect:_backgroundLayer.bounds].CGPath;
    _backgroundLayer.fillColor = self.colorForBackgroundLayer.CGColor;
    
#define kAnimationDuration kFSCalendarDefaultBounceAnimationDuration
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    CABasicAnimation *zoomOut = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    zoomOut.fromValue = @0.3;
    zoomOut.toValue = @1.2;
    zoomOut.duration = kAnimationDuration/4*3;
    CABasicAnimation *zoomIn = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    zoomIn.fromValue = @1.2;
    zoomIn.toValue = @1.0;
    zoomIn.beginTime = kAnimationDuration/4*3;
    zoomIn.duration = kAnimationDuration/4;
    group.duration = kAnimationDuration;
    group.animations = @[zoomOut, zoomIn];
    [_backgroundLayer addAnimation:group forKey:@"bounce"];
    [self configureCell];
}

#pragma mark - Private

- (void)configureCell
{
    _titleLabel.font = [UIFont systemFontOfSize:_appearance.titleTextSize];
    _titleLabel.text = [NSString stringWithFormat:@"%@",@(_date.fs_day)];
    
#define m_calculateTitleHeight \
CGFloat titleHeight = [_titleLabel.text sizeWithAttributes:@{NSFontAttributeName:self.titleLabel.font}].height;
#define m_adjustLabelFrame \
if (_subtitle) { \
_subtitleLabel.hidden = NO; \
_subtitleLabel.text = _subtitle; \
_subtitleLabel.font = [UIFont systemFontOfSize:_appearance.subtitleTextSize]; \
CGFloat subtitleHeight = [_subtitleLabel.text sizeWithAttributes:@{NSFontAttributeName:self.subtitleLabel.font}].height;\
CGFloat height = titleHeight + subtitleHeight; \
_titleLabel.frame = CGRectMake(0, \
(self.contentView.fs_height*5.0/6.0-height)*0.5, \
self.fs_width, \
titleHeight); \
\
_imageView.frame = _titleLabel.frame;\
_noteImageView.frame = CGRectMake(_imageView.frame.size.width / 2 - 15 - 8, _imageView.frame.size.height / 2 - 15 - 8, 16, 16);\
_intimateImageView.frame = CGRectMake(_imageView.frame.size.width / 2 + 15 - 8, _imageView.frame.size.height / 2 - 15 - 8, 16, 16);\
_subtitleLabel.frame = CGRectMake(0, \
_titleLabel.fs_bottom - (_titleLabel.fs_height-_titleLabel.font.pointSize),\
self.fs_width,\
subtitleHeight);\
_subtitleLabel.textColor = self.colorForSubtitleLabel; \
} else { \
_titleLabel.frame = CGRectMake(0, 0, self.fs_width, floor(self.contentView.fs_height*5.0/6.0)); \
_imageView.frame = _titleLabel.frame;\
_noteImageView.frame = CGRectMake(_imageView.frame.size.width / 2 - 15 - 8, _imageView.frame.size.height / 2 - 15 - 8, 16, 16);\
_intimateImageView.frame = CGRectMake(_imageView.frame.size.width / 2 + 15 - 8, _imageView.frame.size.height / 2 - 15 - 8, 16, 16);\
_subtitleLabel.hidden = YES; \
}
    
    if (self.calendar.ibEditing) {
        m_calculateTitleHeight
        m_adjustLabelFrame
    } else {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            m_calculateTitleHeight
            dispatch_async(dispatch_get_main_queue(), ^{
                m_adjustLabelFrame
            });
        });
    }
    
    _titleLabel.textColor = self.colorForTitleLabel;
    
    _backgroundLayer.hidden = !self.selected && !self.dateIsToday && !self.dateIsSelected;
    if (!_backgroundLayer.hidden) {
        _backgroundLayer.path = _appearance.cellStyle == FSCalendarCellStyleCircle ?
        [UIBezierPath bezierPathWithOvalInRect:_backgroundLayer.bounds].CGPath :
        [UIBezierPath bezierPathWithRect:_backgroundLayer.bounds].CGPath;
        _backgroundLayer.fillColor = self.colorForBackgroundLayer.CGColor;
    }
    
    _periodLayer.hidden = !self.isPeriodDay;
    if (!_periodLayer.hidden) {
        _periodLayer.path = _appearance.cellStyle == FSCalendarCellStyleCircle ?
        [UIBezierPath bezierPathWithOvalInRect:_periodLayer.bounds].CGPath :
        [UIBezierPath bezierPathWithRect:_periodLayer.bounds].CGPath;
        _periodLayer.fillColor = [UIColor colorWithRed:253.0/255.0 green:160.0/255.0 blue:196.0/255.0 alpha:1.0].CGColor;
    }
    
    _imageView.image = _image;
    _imageView.hidden = !_image;
    
    _intimateImageView.image = _intimateImage;
    _intimateImageView.hidden = !_intimateImage;
    
    _noteImageView.image = _noteImage;
    _noteImageView.hidden = !_noteImage;
    
    _eventLayer.hidden = !_hasEvent;
    if (!_eventLayer.hidden) {
        _eventLayer.fillColor = self.preferedEventColor.CGColor ?: _appearance.eventColor.CGColor;
    }
}

- (BOOL)isWeekend
{
    return self.date.fs_weekday == 1 || self.date.fs_weekday == 7;
}

- (UIColor *)colorForCurrentStateInDictionary:(NSDictionary *)dictionary
{
    if (self.isSelected || self.dateIsSelected) {
        if (self.dateIsToday) {
            return dictionary[@(FSCalendarCellStateSelected|FSCalendarCellStateToday)] ?: dictionary[@(FSCalendarCellStateSelected)];
        }
        return dictionary[@(FSCalendarCellStateSelected)];
    }
    if (self.dateIsToday) {
        return dictionary[@(FSCalendarCellStateToday)];
    }
    if (self.dateIsPlaceholder) {
        return dictionary[@(FSCalendarCellStatePlaceholder)];
    }
    if (self.isWeekend && [[dictionary allKeys] containsObject:@(FSCalendarCellStateWeekend)]) {
        return dictionary[@(FSCalendarCellStateWeekend)];
    }
    return dictionary[@(FSCalendarCellStateNormal)];
}

#pragma mark - Properties

- (UIColor *)colorForBackgroundLayer
{
    if (self.dateIsSelected || self.isSelected) {
        return self.preferedSelectionColor ?: [self colorForCurrentStateInDictionary:_appearance.backgroundColors];
    }
    return [self colorForCurrentStateInDictionary:_appearance.backgroundColors];
}

- (UIColor *)colorForTitleLabel
{
    if (self.dateIsSelected || self.isSelected) {
        return self.preferedTitleSelectionColor ?: [self colorForCurrentStateInDictionary:_appearance.titleColors];
    }
    return self.preferedTitleDefaultColor ?: [self colorForCurrentStateInDictionary:_appearance.titleColors];
}

- (UIColor *)colorForSubtitleLabel
{
    if (self.dateIsSelected || self.isSelected) {
        return self.preferedSubtitleSelectionColor ?: [self colorForCurrentStateInDictionary:_appearance.subtitleColors];
    }
    return self.preferedSubtitleDefaultColor ?: [self colorForCurrentStateInDictionary:_appearance.subtitleColors];
}

@end



