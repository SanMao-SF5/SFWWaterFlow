//
//  SFWWaterflowLayout.h
//  3.瀑布流
//
//  Created by 沈方武 on 15/8/22.
//  Copyright (c) 2015年 沈方武. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SFWWaterflowLayout;

@protocol SFWWaterflowLayoutDelegate <NSObject>
//必定实现
@required
/**cell的高度*/
-(CGFloat)WaterflowLayout:(SFWWaterflowLayout *)layout heightForItemAtIndex:(NSIndexPath *)index itemWidth:(CGFloat)itemWidth;

//可选实现
@optional
/**布局的列数*/
-(NSInteger)columnCountInWaterflowLayout:(SFWWaterflowLayout *)layout;

/**cell的水平间距*/
-(CGFloat)horizontalMaginInWaterflowLayout:(SFWWaterflowLayout *)layout;

/**cell的垂直间距*/
-(CGFloat)verticalMarginInWaterflowLayout:(SFWWaterflowLayout *)layout;

/**内容边距*/
-(UIEdgeInsets)contentInsetInWaterflowLayout:(SFWWaterflowLayout *)layout;

@end

@interface SFWWaterflowLayout : UICollectionViewFlowLayout

/**布局代理*/
@property(nonatomic,weak)id<SFWWaterflowLayoutDelegate> delegate;

@end
