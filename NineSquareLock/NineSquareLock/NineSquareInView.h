//
//  NineSquareInView.h
//  NineSquareLock
//
//  Created by 胡双飞 on 15/8/21.
//  Copyright (c) 2015年 HSF. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NineSquareInView : UIView

@property (nonatomic, copy) BOOL (^passWordBlock)(NSString* ,UIImage *);

@end
