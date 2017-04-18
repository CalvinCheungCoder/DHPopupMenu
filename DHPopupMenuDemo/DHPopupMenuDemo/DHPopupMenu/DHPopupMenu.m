//
//  DHPopupMenu.m
//  DHPopupMenu
//
//  Created by 张丁豪 on 2017/4/18.
//  Copyright © 2017年 zhangdinghao. All rights reserved.
//

#import "DHPopupMenu.h"
#import "UIView+Addition.h"
#import "DHPopupMenuCell.h"

#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height
#define MainWindow  [UIApplication sharedApplication].keyWindow

@interface DHPopupMenu ()<UITableViewDelegate,UITableViewDataSource>
{
    UIView * _mainView;
    UITableView * _contentView;
    UIView * _bgView;
    
    CGPoint _anchorPoint;
    
    CGFloat kArrowHeight;
    CGFloat kArrowWidth;
    CGFloat kArrowPosition;
    CGFloat kButtonHeight;
    
    NSArray * _titles;
    NSArray * _icons;
    
    UIColor * _contentColor;
    UIColor * _separatorColor;
}

@end

@implementation DHPopupMenu

@synthesize cornerRadius = kCornerRadius;

- (instancetype)initWithTitles:(NSArray *)titles
                         icons:(NSArray *)icons
                     menuWidth:(CGFloat)itemWidth
                      delegate:(id<DHPopupMenuDelegate>)delegate
{
    if (self = [super init]) {
        
        kArrowHeight = 10;
        kArrowWidth = 15;
        kButtonHeight = 44;
        kCornerRadius = 5.0;
        _titles = titles;
        _icons  = icons;
        _dismissOnSelected = YES;
        _fontSize = 15.0;
        _textColor = [UIColor blackColor];
        _offset = 0.0;
        _type = DHPopupMenuTypeDefault;
        _contentColor = [UIColor whiteColor];
        _separatorColor = [UIColor lightGrayColor];
        
        if (delegate) self.delegate = delegate;
        
        self.width = itemWidth;
        self.height = (titles.count > 5 ? 5 * kButtonHeight : titles.count * kButtonHeight) + 2 * kArrowHeight;
        
        kArrowPosition = 0.5 * self.width - 0.5 * kArrowWidth;
        
        self.alpha = 0;
        self.layer.shadowOpacity = 0.5;
        self.layer.shadowOffset = CGSizeMake(0, 0);
        self.layer.shadowRadius = 2.0;
        
        _mainView = [[UIView alloc] initWithFrame: self.bounds];
        _mainView.backgroundColor = _contentColor;
        _mainView.layer.cornerRadius = kCornerRadius;
        _mainView.layer.masksToBounds = YES;
        
        _contentView = [[UITableView alloc] initWithFrame: _mainView.bounds style:UITableViewStylePlain];
        _contentView.backgroundColor = [UIColor clearColor];
        _contentView.delegate = self;
        _contentView.dataSource= self;
        _contentView.bounces = titles.count > 5 ? YES : NO;
        _contentView.tableFooterView = [UIView new];
        _contentView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _contentView.height -= 2 * kArrowHeight;
        _contentView.center = _mainView.center;
        
        [_mainView addSubview: _contentView];
        [self addSubview: _mainView];
        
        _bgView = [[UIView alloc] initWithFrame: [UIScreen mainScreen].bounds];
        _bgView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.1];
        _bgView.alpha = 0;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(dismiss)];
        [_bgView addGestureRecognizer: tap];
    }
    return self;
}

- (void)dismiss
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(dhPopupMenuBeganDismiss)]) {
        [self.delegate dhPopupMenuBeganDismiss];
    }
    [UIView animateWithDuration: 0.25 animations:^{
        self.layer.affineTransform = CGAffineTransformMakeScale(0.1, 0.1);
        self.alpha = 0;
        _bgView.alpha = 0;
        
    } completion:^(BOOL finished) {
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(dhPopupMenuDidDismiss)]) {
            [self.delegate dhPopupMenuDidDismiss];
        }
        self.delegate = nil;
        [self removeFromSuperview];
        [_bgView removeFromSuperview];
    }];
}


- (void)showAtPoint:(CGPoint)point
{
    _mainView.layer.mask = [self getMaskLayerWithPoint:point];
    [self show];
}

- (void)showRelyOnView:(UIView *)view
{
    CGRect absoluteRect = [view convertRect:view.bounds toView:MainWindow];
    CGPoint relyPoint = CGPointMake(absoluteRect.origin.x + absoluteRect.size.width / 2, absoluteRect.origin.y + absoluteRect.size.height);
    _mainView.layer.mask = [self getMaskLayerWithPoint:relyPoint];
    if (self.sd_y < _anchorPoint.y) {
        self.sd_y -= absoluteRect.size.height;
    }
    [self show];
}

+ (instancetype)showAtPoint:(CGPoint)point titles:(NSArray *)titles icons:(NSArray *)icons menuWidth:(CGFloat)itemWidth delegate:(id<DHPopupMenuDelegate>)delegate
{
    DHPopupMenu *popupMenu = [[DHPopupMenu alloc] initWithTitles:titles icons:icons menuWidth:itemWidth delegate:delegate];
    [popupMenu showAtPoint:point];
    return popupMenu;
}

+ (instancetype)showRelyOnView:(UIView *)view titles:(NSArray *)titles icons:(NSArray *)icons menuWidth:(CGFloat)itemWidth delegate:(id<DHPopupMenuDelegate>)delegate
{
    DHPopupMenu *popupMenu = [[DHPopupMenu alloc] initWithTitles:titles icons:icons menuWidth:itemWidth delegate:delegate];
    [popupMenu showRelyOnView:view];
    return popupMenu;
}

#pragma mark --
#pragma mark -- tableViewDelegate & dataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _titles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * identifier = @"dhPopupMenu";
    DHPopupMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[DHPopupMenuCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
    }
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = _textColor;
    cell.textLabel.font = [UIFont systemFontOfSize:_fontSize];
    cell.textLabel.text = _titles[indexPath.row];
    cell.separatorColor = _separatorColor;
    
    if (_icons.count >= indexPath.row + 1) {
        if ([_icons[indexPath.row] isKindOfClass:[NSString class]]) {
            cell.imageView.image = [UIImage imageNamed:_icons[indexPath.row]];
        }else if ([_icons[indexPath.row] isKindOfClass:[UIImage class]]){
            cell.imageView.image = _icons[indexPath.row];
        }else {
            cell.imageView.image = nil;
        }
    }else {
        cell.imageView.image = nil;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (_dismissOnSelected) [self dismiss];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(dhPopupMenuDidSelectedAtIndex:dhPopupMenu:)]) {
        
        [self.delegate dhPopupMenuDidSelectedAtIndex:indexPath.row dhPopupMenu:self];
    }
}

#pragma mark --
#pragma mark -- scrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    DHPopupMenuCell *cell = [self getLastVisibleCell];
    cell.isShowSeparator = YES;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    DHPopupMenuCell *cell = [self getLastVisibleCell];
    cell.isShowSeparator = NO;
}

- (DHPopupMenuCell *)getLastVisibleCell
{
    NSArray <NSIndexPath *>*indexPaths = [_contentView indexPathsForVisibleRows];
    indexPaths = [indexPaths sortedArrayUsingComparator:^NSComparisonResult(NSIndexPath *  _Nonnull obj1, NSIndexPath *  _Nonnull obj2) {
        return obj1.row < obj2.row;
    }];
    NSIndexPath *indexPath = indexPaths.firstObject;
    return [_contentView cellForRowAtIndexPath:indexPath];
}

#pragma mark --
#pragma mark -- private functions
- (void)setType:(DHPopupMenuType)type
{
    _type = type;
    switch (type) {
        case DHPopupMenuTypeDark:
        {
            _textColor = [UIColor lightGrayColor];
            _contentColor = [UIColor colorWithRed:0.25 green:0.27 blue:0.29 alpha:1];
            _separatorColor = [UIColor lightGrayColor];
        }
            break;
            
        default:
        {
            _textColor = [UIColor blackColor];
            _contentColor = [UIColor whiteColor];
            _separatorColor = [UIColor lightGrayColor];
        }
            break;
    }
    _mainView.backgroundColor = _contentColor;
    [_contentView reloadData];
}

- (void)setFontSize:(CGFloat)fontSize
{
    _fontSize = fontSize;
    [_contentView reloadData];
}

- (void)setTextColor:(UIColor *)textColor
{
    _textColor = textColor;
    [_contentView reloadData];
}

- (void)setDismissOnTouchOutside:(BOOL)dismissOnTouchOutside
{
    _dismissOnTouchOutside = dismissOnTouchOutside;
    if (!dismissOnTouchOutside) {
        for (UIGestureRecognizer *gr in _bgView.gestureRecognizers) {
            [_bgView removeGestureRecognizer:gr];
        }
    }
}

- (void)setIsShowShadow:(BOOL)isShowShadow
{
    _isShowShadow = isShowShadow;
    if (!isShowShadow) {
        self.layer.shadowOpacity = 0.0;
        self.layer.shadowOffset = CGSizeMake(0, 0);
        self.layer.shadowRadius = 0.0;
    }
}

- (void)setOffset:(CGFloat)offset
{
    _offset = offset;
    if (offset < 0) {
        offset = 0.0;
    }
    self.sd_y += self.sd_y >= _anchorPoint.y ? offset : -offset;
}

- (void)setCornerRadius:(CGFloat)cornerRadius
{
    kCornerRadius = cornerRadius;
    _mainView.layer.mask = [self drawMaskLayer];
    if (self.sd_y < _anchorPoint.y) {
        _mainView.layer.mask.affineTransform = CGAffineTransformMakeRotation(M_PI);
    }
}

- (void)show {
    
    [MainWindow addSubview: _bgView];
    [MainWindow addSubview: self];
    DHPopupMenuCell *cell = [self getLastVisibleCell];
    cell.isShowSeparator = NO;
    self.layer.affineTransform = CGAffineTransformMakeScale(0.1, 0.1);
    [UIView animateWithDuration: 0.25 animations:^{
        self.layer.affineTransform = CGAffineTransformMakeScale(1.0, 1.0);
        self.alpha = 1;
        _bgView.alpha = 1;
    }];
}

- (void)setAnimationAnchorPoint:(CGPoint)point
{
    CGRect originRect = self.frame;
    self.layer.anchorPoint = point;
    self.frame = originRect;
}

- (void)determineAnchorPoint
{
    CGPoint aPoint = CGPointMake(0.5, 0.5);
    if (CGRectGetMaxY(self.frame) > ScreenHeight) {
        aPoint = CGPointMake(fabs(kArrowPosition) / self.width, 1);
    }else {
        aPoint = CGPointMake(fabs(kArrowPosition) / self.width, 0);
    }
    [self setAnimationAnchorPoint:aPoint];
}

- (CAShapeLayer *)getMaskLayerWithPoint:(CGPoint)point
{
    [self setArrowPointingWhere:point];
    CAShapeLayer *layer = [self drawMaskLayer];
    [self determineAnchorPoint];
    if (CGRectGetMaxY(self.frame) > ScreenHeight) {
        
        kArrowPosition = self.width - kArrowPosition - kArrowWidth;
        layer = [self drawMaskLayer];
        layer.affineTransform = CGAffineTransformMakeRotation(M_PI);
        self.sd_y = _anchorPoint.y - self.height;
    }
    self.sd_y += self.sd_y >= _anchorPoint.y ? _offset : -_offset;
    return layer;
}

- (void)setArrowPointingWhere: (CGPoint)anchorPoint
{
    _anchorPoint = anchorPoint;
    
    self.sd_x = anchorPoint.x - kArrowPosition - 0.5*kArrowWidth;
    self.sd_y = anchorPoint.y;
    
    CGFloat maxX = CGRectGetMaxX(self.frame);
    CGFloat minX = CGRectGetMinX(self.frame);
    
    if (maxX > ScreenWidth - 10) {
        self.sd_x = ScreenWidth - 10 - self.width;
    }else if (minX < 10) {
        self.sd_x = 10;
    }
    
    maxX = CGRectGetMaxX(self.frame);
    minX = CGRectGetMinX(self.frame);
    
    if ((anchorPoint.x <= maxX - kCornerRadius) && (anchorPoint.x >= minX + kCornerRadius)) {
        kArrowPosition = anchorPoint.x - minX - 0.5*kArrowWidth;
    }else if (anchorPoint.x < minX + kCornerRadius) {
        kArrowPosition = kCornerRadius;
    }else {
        kArrowPosition = self.width - kCornerRadius - kArrowWidth;
    }
}

- (CAShapeLayer *)drawMaskLayer
{
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = _mainView.bounds;
    
    CGPoint topRightArcCenter = CGPointMake(self.width-kCornerRadius, kArrowHeight+kCornerRadius);
    CGPoint topLeftArcCenter = CGPointMake(kCornerRadius, kArrowHeight+kCornerRadius);
    CGPoint bottomRightArcCenter = CGPointMake(self.width-kCornerRadius, self.height - kArrowHeight - kCornerRadius);
    CGPoint bottomLeftArcCenter = CGPointMake(kCornerRadius, self.height - kArrowHeight - kCornerRadius);
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint: CGPointMake(0, kArrowHeight+kCornerRadius)];
    [path addLineToPoint: CGPointMake(0, bottomLeftArcCenter.y)];
    [path addArcWithCenter: bottomLeftArcCenter radius: kCornerRadius startAngle: -M_PI endAngle: -M_PI-M_PI_2 clockwise: NO];
    [path addLineToPoint: CGPointMake(self.width-kCornerRadius, self.height - kArrowHeight)];
    [path addArcWithCenter: bottomRightArcCenter radius: kCornerRadius startAngle: -M_PI-M_PI_2 endAngle: -M_PI*2 clockwise: NO];
    [path addLineToPoint: CGPointMake(self.width, kArrowHeight+kCornerRadius)];
    [path addArcWithCenter: topRightArcCenter radius: kCornerRadius startAngle: 0 endAngle: -M_PI_2 clockwise: NO];
    [path addLineToPoint: CGPointMake(kArrowPosition+kArrowWidth, kArrowHeight)];
    [path addLineToPoint: CGPointMake(kArrowPosition+0.5*kArrowWidth, 0)];
    [path addLineToPoint: CGPointMake(kArrowPosition, kArrowHeight)];
    [path addLineToPoint: CGPointMake(kCornerRadius, kArrowHeight)];
    [path addArcWithCenter: topLeftArcCenter radius: kCornerRadius startAngle: -M_PI_2 endAngle: -M_PI clockwise: NO];
    [path closePath];
    
    maskLayer.path = path.CGPath;
    
    return maskLayer;
}

@end
