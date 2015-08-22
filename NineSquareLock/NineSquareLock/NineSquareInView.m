//
//  NineSquareInView.m
//  NineSquareLock
//
//  Created by 胡双飞 on 15/8/21.
//  Copyright (c) 2015年 HSF. All rights reserved.
//

#import "NineSquareInView.h"
#import "SVProgressHUD.h"

typedef enum : NSUInteger {
    NineSquareTouchesStyleBegan,
    NineSquareTouchesStyleMoved,
} NineSquareTouchesStyle;

#define kSquareWH 74
#define kSquareCount 9
#define kColumnCount 3
@interface NineSquareInView ()
/**
 *  存放全部按钮的数组
 */
@property (nonatomic, strong) NSMutableArray* btnArray;

/**
 *  存放选中按钮的数组
 */
@property (nonatomic, strong) NSMutableArray* selectedBtnArray;

//当前点的位置
@property (nonatomic, assign) CGPoint currentPoint;

//密码
@property (nonatomic, copy) NSString* pwd;

@end
@implementation NineSquareInView

#pragma mark - 布局控件
//布局控件时调用
- (void)layoutSubviews
{
    [super layoutSubviews];

    //创建九宫格
    [self createNineSquare];
}

#pragma mark - touches事件
- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{

    //开始点击时
    [self touchPointContainsPoint:touches withStyle:NineSquareTouchesStyleBegan];
}

- (void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event
{

    //拖动时
    [self touchPointContainsPoint:touches withStyle:NineSquareTouchesStyleMoved];
}

- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event
{
    //当结束的时候，线恢复到最后一个按钮的点。
    self.currentPoint = [[self.selectedBtnArray lastObject] center];
    //重会
    [self setNeedsDisplay];

    //遍历按钮
    for (NSInteger i = 0; i < self.selectedBtnArray.count; i++) {
        UIButton* btn = self.selectedBtnArray[i];
        btn.selected = YES;
        btn.highlighted = NO;
        //        NSLog(@"内容 %d", [self.selectedBtnArray[i] tag]);
    }

    //开启上下文
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0);

    //获得上下文
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    //截图
    [self.layer renderInContext:ctx];

    //获得图片
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();

    //关闭上下文
    UIGraphicsEndImageContext();

    if (self.passWordBlock) {
        //失败出现
        if (!self.passWordBlock(self.pwd, image)) {
            [SVProgressHUD showErrorWithStatus:@"密码错误"];
        }
        else {
            [self clear];
        }
    }

    //关闭交互
    self.userInteractionEnabled = NO;
    //延迟两秒，执行操作
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

        [self clear];
        //两秒后交互打开
        self.userInteractionEnabled = YES;

    });
}
#pragma mark - touch自定义的方法
//是否点击点在按钮范围内
- (void)touchPointContainsPoint:(NSSet*)touches withStyle:(NineSquareTouchesStyle)touchStyle
{
    //获取UITouche对象
    UITouch* touch = touches.anyObject;
    CGPoint touchPoint = [touch locationInView:self];
    //保留最后一个
    self.currentPoint = touchPoint;
    [self setNeedsDisplay];

    //遍历数组
    for (NSInteger i = 0; i < self.btnArray.count; i++) {
        UIButton* btn = self.btnArray[i];

        //判断是否点到按钮
        if (CGRectContainsPoint(btn.frame, touchPoint)) {
            btn.highlighted = YES;
            btn.selected = NO;

            //添加按钮
            if (![self.selectedBtnArray containsObject:btn]) {
                [self.selectedBtnArray addObject:btn];
                if (NineSquareTouchesStyleBegan == touchStyle) {

                    self.pwd = [NSString stringWithFormat:@"%ld", i];
                }
                else if (NineSquareTouchesStyleMoved == touchStyle) {

                    self.pwd = [self.pwd stringByAppendingFormat:@"%ld", i];
                }
                //重绘
                [self setNeedsDisplay];
            }
        }
    }
}

#pragma mark - 绘画方法
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    //初始化
    UIBezierPath* line = [UIBezierPath bezierPath];
    [line setLineWidth:10]; //设置线宽
    [line setLineJoinStyle:kCGLineJoinRound]; //拐角样式为圆
    [line setLineCapStyle:kCGLineCapRound]; //断点样式为圆
    [[UIColor whiteColor] setStroke]; //设置白色

    for (NSInteger i = 0; i < self.selectedBtnArray.count; i++) {
        //按钮选择位置
        UIButton* btn;
        if (i == 0) {
            //获得起始点
            btn = self.selectedBtnArray[i];
            [line moveToPoint:btn.center];
        }
        //将与它按钮连续
        btn = self.selectedBtnArray[i];
        [line addLineToPoint:btn.center];
    }

    //拖动时连线效果
    if (self.selectedBtnArray.count) {
        [line addLineToPoint:self.currentPoint];
    }

    //渲染线
    [line stroke];
}

#pragma mark - 自定义方法
//初始化按钮，并装到数组
- (void)initNineSquare
{
    //添加按钮
    for (int i = 0; i < kSquareCount; i++) {

        UIButton* btn = [[UIButton alloc] init];
        [btn setImage:[UIImage imageNamed:@"gesture_node_normal"] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:@"gesture_node_highlighted"] forState:UIControlStateHighlighted];
        [btn setImage:[UIImage imageNamed:@"gesture_node_error"] forState:UIControlStateSelected];
        btn.userInteractionEnabled = NO;
        [_btnArray addObject:btn];
        [self addSubview:btn];
    }
}

//创建九个宫格
- (void)createNineSquare
{
    //设置每个按钮的尺寸
    CGFloat margin = (self.bounds.size.width - 3 * kSquareWH) / 4;
    for (int i = 0; i < self.btnArray.count; i++) {

        int column = i % kColumnCount;
        int row = i / kColumnCount;
        CGFloat x = column * kSquareWH + (column + 1) * margin;
        CGFloat y = row * kSquareWH + (row + 1) * margin;

        [self.btnArray[i] setFrame:CGRectMake(x, y, kSquareWH, kSquareWH)];
    }
}

//清除操作
- (void)clear
{
    // 遍历所有的按钮
    for (int i = 0; i < self.btnArray.count; i++) {
        UIButton* btn = self.btnArray[i];
        btn.highlighted = NO;
        btn.selected = NO;
    }

    //移除所有的按钮
    [self.selectedBtnArray removeAllObjects];
    //重绘
    [self setNeedsDisplay];
    //密码清空
    //    self.pwd = nil;
}

#pragma mark - 懒加载方法
//重写getter方法
- (NSMutableArray*)btnArray
{
    if (!_btnArray) {
        _btnArray = [NSMutableArray arrayWithCapacity:kSquareCount];
        _selectedBtnArray = [NSMutableArray array];
        //        _pwd = @"";
        [self initNineSquare];
    }
    return _btnArray;
}

@end
