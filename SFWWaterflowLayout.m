//
//  SFWWaterflowLayout.m
//  3.瀑布流
//
//  Created by 沈方武 on 15/8/7.
//  Copyright © 2015年 沈方武. All rights reserved.
//

#import "SFWWaterflowLayout.h"


@interface SFWWaterflowLayout(){
    NSInteger _defaultColumnCount;//默认列数
    CGFloat _defaultHorizontalMargin;//默认水平间距
    CGFloat _defaultVerticalMargin;//默认垂直间距
    UIEdgeInsets _defaultContentInsets;//默认内容边距
}
/**所有列的当前高度*/
@property(nonatomic,strong)NSMutableArray *columnsHeihgt;

/**所有cell的布局属性*/
@property(nonatomic,strong)NSMutableArray *layoutAttrs;
@end

@implementation SFWWaterflowLayout

-(instancetype)init{
    if (self = [super init]) {
        // 初始化
        _defaultColumnCount = 3;
        _defaultHorizontalMargin = 10;
        _defaultVerticalMargin = 10;
        _defaultContentInsets = UIEdgeInsetsMake(10, 10, 40, 10);
        
        self.columnsHeihgt = [NSMutableArray array];
        self.layoutAttrs = [NSMutableArray array];
    }
    return self;
}


-(void)prepareLayout{
//    NSLog(@"%s",__func__);
#pragma mark 调用reload方法时，把以前的数据清空
    [self.columnsHeihgt removeAllObjects];
    [self.layoutAttrs removeAllObjects];
    
    // 1.初始化三列的高度
    NSInteger columnCount = [self columnFromDelegate];
    UIEdgeInsets contentInset = [self contentInsetFromDelegate];
    for (NSInteger i = 0; i < columnCount; i++) {
        [self.columnsHeihgt addObject:@(contentInset.top)];
    }
    
    // 2.初始化所有cell的布局属性
    NSInteger count = [self.collectionView numberOfItemsInSection:0];
    for (NSInteger i = 0;i < count;i++) {
        // 2.1创建布局属性
        UICollectionViewLayoutAttributes *layoutAttr = [self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        
        // 2.2 添加到数组
        [self.layoutAttrs addObject:layoutAttr];
    }

}

-(NSArray *)layoutAttributesForElementsInRect:(CGRect)rect{
    return self.layoutAttrs;
}

-(UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    // 1.创建布局属性对象
    UICollectionViewLayoutAttributes *layoutAtt = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    
    // 2.计算哪一列最矮
    NSInteger shortestColumn = [self shortestColumn];
    
    // 获取列数
    NSInteger columnCount = [self columnFromDelegate];
    // 水平间距
    CGFloat horizontalMarin = [self horizontalMarginFromDelegate];
    // 垂直间距
    CGFloat verticalMargin = [self verticalMarginFromDelegate];
    
    // 内容边距
    UIEdgeInsets contentInset = [self contentInsetFromDelegate];
    
    CGFloat cellW = (self.collectionView.frame.size.width - contentInset.left - contentInset.right - (columnCount - 1) * horizontalMarin) / columnCount;

    //从代理获取高度
    CGFloat cellH = [self heihgtFromDelegate:indexPath width:cellW];
    
    CGFloat cellX = contentInset.left + shortestColumn * (cellW + horizontalMarin);
    
    CGFloat cellY = [self.columnsHeihgt[shortestColumn] floatValue]+ verticalMargin;
    layoutAtt.frame = CGRectMake(cellX,cellY,cellW, cellH);
    
    //3.更改当前最短的那一列值
    self.columnsHeihgt[shortestColumn] = @(cellY + cellH);
    
    return layoutAtt;
    
}

/**返回最矮的列*/
-(NSInteger)shortestColumn{
    // 1.最矮列-->默认为第0列
    NSInteger shortestColumn = 0;
    
    // 2.获取第一列的高度
    CGFloat height = [self.columnsHeihgt[0] floatValue];
    
    NSInteger columnCount = [self columnFromDelegate];
    
    if (columnCount == 0) {
        return 0;
    }
    // 4.遍历
    for (NSInteger i = 1; i < columnCount; i++) {
        // 当前遍历列的高度
        CGFloat currentColumnH = [self.columnsHeihgt[i] floatValue];
        if (currentColumnH < height) {
            height = currentColumnH;
            shortestColumn = i;
        }
    }
    
    return shortestColumn;
}

/**返回最高的列*/
-(NSInteger)heihgtestColumn{
    // 1.最矮列-->默认为第0列
    NSInteger heihgtestColumn = 0;
    
    // 2.获取第一列的高度
    CGFloat height = [self.columnsHeihgt[0] floatValue];
    
    // 4.遍历
    NSInteger columnCount = [self columnFromDelegate];
    
    if (columnCount == 0) {
        return 0;
    }
    for (NSInteger i = 1; i < columnCount; i++) {
        // 当前遍历列的高度
        CGFloat currentColumnH = [self.columnsHeihgt[i] floatValue];
        if (currentColumnH > height) {
            height = currentColumnH;
            heihgtestColumn = i;
        }
    }
    
    return heihgtestColumn;
}


-(CGSize)collectionViewContentSize{
    // 获取高列
    NSInteger heightestColumn = [self heihgtestColumn];
    
    UIEdgeInsets contentInset = [self contentInsetFromDelegate];
    return CGSizeMake(0, [self.columnsHeihgt[heightestColumn] floatValue] +     contentInset.bottom);
}


-(CGFloat)heihgtFromDelegate:(NSIndexPath *)indexPath width:(CGFloat)width{
    if ([self.delegate respondsToSelector:@selector(WaterflowLayout:heightForItemAtIndex:itemWidth:)]) {
        return [self.delegate WaterflowLayout:self heightForItemAtIndex:indexPath itemWidth:width];
    }
    
    // 未实现代理，默认返回宽度为空度
    return width;
}

-(NSInteger)columnFromDelegate{
    //未实现代理，返回默认列数
    if ([self.delegate respondsToSelector:@selector(columnCountInWaterflowLayout:)]) {
        NSInteger column = [self.delegate columnCountInWaterflowLayout:self];
        if (column == 0) {
            return _defaultColumnCount;
        }
        
        return column;
    }
    
    return _defaultColumnCount;
}

-(CGFloat)horizontalMarginFromDelegate{
    //未实现代理，返回默认水平间距
    if ([self.delegate respondsToSelector:@selector(horizontalMaginInWaterflowLayout:)]) {
        return [self.delegate horizontalMaginInWaterflowLayout:self];;
    }
    
    return _defaultHorizontalMargin;
}

-(CGFloat)verticalMarginFromDelegate{
    if ([self.delegate respondsToSelector:@selector(verticalMarginInWaterflowLayout:)]) {
        return [self.delegate verticalMarginInWaterflowLayout:self];;
    }
    
    return _defaultVerticalMargin;
}

-(UIEdgeInsets)contentInsetFromDelegate{
    if ([self.delegate respondsToSelector:@selector(contentInsetInWaterflowLayout:)]) {
        return [self.delegate contentInsetInWaterflowLayout:self];;
    }
    
    return _defaultContentInsets;
}

@end
