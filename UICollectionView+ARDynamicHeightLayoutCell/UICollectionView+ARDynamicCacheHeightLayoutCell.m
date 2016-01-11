//
//  UICollectionView+ARDynamicHeightLayoutCell.m
//  DynamicHeightCellLayoutDemo
//
//  Created by August on 15/5/19.
//  Copyright (c) 2015年 August. All rights reserved.
//

#import "UICollectionView+ARDynamicCacheHeightLayoutCell.h"
#import <objc/runtime.h>

typedef NS_ENUM(NSUInteger, ARDynamicSizeCaculateType) {
    ARDynamicSizeCaculateTypeSize = 0,
    ARDynamicSizeCaculateTypeHeight,
    ARDynamicSizeCaculateTypeWidth
};

#define ARLayoutCellInvalidateValue [NSValue valueWithCGSize:CGSizeZero]

@implementation UICollectionView (ARDynamicCacheHeightLayoutCell)

+(void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SEL selectors[] =
        {@selector(registerNib:forCellWithReuseIdentifier:),
            @selector(registerClass:forCellWithReuseIdentifier:),
            @selector(reloadData),
            @selector(reloadSections:),
            @selector(deleteSections:),
            @selector(moveSection:toSection:),
            @selector(reloadItemsAtIndexPaths:),
            @selector(deleteItemsAtIndexPaths:),
            @selector(moveItemAtIndexPath:toIndexPath:)};
        
        for (int i = 0; i < sizeof(selectors)/sizeof(SEL); i++) {
            SEL originalSelector = selectors[i];
            SEL swizzledSelector = NSSelectorFromString([@"ar_" stringByAppendingString:NSStringFromSelector(originalSelector)]);
            
            Method originalMethod = class_getInstanceMethod(self, originalSelector);
            Method swizzledMethod = class_getInstanceMethod(self, swizzledSelector);
            
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    });
}

-(CGSize)ar_sizeForCellWithIdentifier:(NSString *)identifier indexPath:(NSIndexPath *)indexPath configuration:(void (^)(__kindof UICollectionViewCell *))configuration
{
    return [self ar_sizeForCellWithIdentifier:identifier indexPath:indexPath fixedValue:0 caculateType:ARDynamicSizeCaculateTypeSize configuration:configuration];
}

-(CGSize)ar_sizeForCellWithIdentifier:(NSString *)identifier indexPath:(NSIndexPath *)indexPath fixedWidth:(CGFloat)fixedWidth configuration:(void (^)(__kindof UICollectionViewCell *))configuration
{
    return [self ar_sizeForCellWithIdentifier:identifier indexPath:indexPath fixedValue:fixedWidth caculateType:ARDynamicSizeCaculateTypeWidth configuration:configuration];
}

-(CGSize)ar_sizeForCellWithIdentifier:(NSString *)identifier indexPath:(NSIndexPath *)indexPath fixedHeight:(CGFloat)fixedHeight configuration:(void (^)(__kindof UICollectionViewCell *))configuration
{
    return [self ar_sizeForCellWithIdentifier:identifier indexPath:indexPath fixedValue:fixedHeight caculateType:ARDynamicSizeCaculateTypeHeight configuration:configuration];
}

-(CGSize)ar_sizeForCellWithIdentifier:(NSString *)identifier
                            indexPath:(NSIndexPath *)indexPath
                           fixedValue:(CGFloat)fixedValue
                         caculateType:(ARDynamicSizeCaculateType)caculateType
                        configuration:(void (^)(__kindof UICollectionViewCell *))configuration
{
    NSValue *value = [self sizeCacheAtIndexPath:indexPath];
    if (![value isEqualToValue:ARLayoutCellInvalidateValue]) {
        return [value CGSizeValue];
    }
    //has no size chche
    UICollectionViewCell *cell = [self templeCaculateCellWithIdentifier:identifier];
    configuration(cell);
    CGSize size = CGSizeMake(fixedValue, fixedValue);
    if (caculateType != ARDynamicSizeCaculateTypeSize) {
        NSLayoutAttribute attribute = caculateType == ARDynamicSizeCaculateTypeWidth? NSLayoutAttributeWidth:NSLayoutAttributeHeight;
        NSLayoutConstraint *tempConstraint = [NSLayoutConstraint
                                              constraintWithItem:cell.contentView
                                              attribute:attribute
                                              relatedBy:NSLayoutRelationEqual
                                              toItem:nil
                                              attribute:NSLayoutAttributeNotAnAttribute
                                              multiplier:1
                                              constant:fixedValue];
        [cell.contentView addConstraint:tempConstraint];
        size  = [cell systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
        [cell.contentView removeConstraint:tempConstraint];
    } else {
        size  = [cell systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    }
    
    NSMutableArray *sectionCache = [self sizeCache][indexPath.section];
    NSValue *sizeValue = [NSValue valueWithCGSize:size];
    [sectionCache replaceObjectAtIndex:indexPath.row withObject:sizeValue];
    return size;
}

#pragma mark - swizzled methods

-(void)ar_registerClass:(Class)cellClass forCellWithReuseIdentifier:(NSString *)identifier
{
    [self ar_registerClass:cellClass forCellWithReuseIdentifier:identifier];
    
    id cell = [[cellClass alloc] initWithFrame:CGRectZero];
    NSMutableDictionary *templeCells = [self templeCells];
    templeCells[identifier] = cell;
}

-(void)ar_registerNib:(UINib *)nib forCellWithReuseIdentifier:(NSString *)identifier
{
    [self ar_registerNib:nib forCellWithReuseIdentifier:identifier];
    id cell = [[nib instantiateWithOwner:nil options:nil] lastObject];
    NSMutableDictionary *templeCells = [self templeCells];
    templeCells[identifier] = cell;
}

#pragma mark - section changes

-(void)ar_reloadSections:(NSIndexSet *)sections
{
    [sections enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        [self safeCacheAtSection:idx];
        NSMutableArray *cache = [self sizeCache];
        [cache replaceObjectAtIndex:idx withObject:[NSMutableArray array]];
    }];
    [self ar_reloadSections:sections];
}

-(void)ar_deleteSections:(NSIndexSet *)sections
{
    [sections enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        NSMutableArray *cache = [self sizeCache];
        if (cache.count > idx) {
            [cache removeObjectAtIndex:idx];
        }
    }];
    [self ar_deleteSections:sections];
}

-(void)ar_moveSection:(NSInteger)section toSection:(NSInteger)newSection
{
    [self safeCacheAtSection:MAX(section, newSection)];
    
    [[self sizeCache] exchangeObjectAtIndex:section withObjectAtIndex:newSection];
    [self ar_moveSection:section toSection:newSection];
}

#pragma mark - item changes

-(void)ar_deleteItemsAtIndexPaths:(NSArray *)indexPaths
{
    [indexPaths enumerateObjectsUsingBlock:^(NSIndexPath *obj, NSUInteger idx, BOOL *stop) {
        [self safeCacheAtIndexPath:obj];
        NSMutableArray *section = [self sizeCache][obj.section];
        [section removeObjectAtIndex:obj.row];
    }];
    [self ar_deleteItemsAtIndexPaths:indexPaths];
}

-(void)ar_reloadItemsAtIndexPaths:(NSArray *)indexPaths
{
    [indexPaths enumerateObjectsUsingBlock:^(NSIndexPath *obj, NSUInteger idx, BOOL *stop) {
        [self safeCacheAtIndexPath:obj];
        NSMutableArray *section = [self sizeCache][obj.section];
        section[obj.row] = ARLayoutCellInvalidateValue;
    }];
    [self ar_reloadItemsAtIndexPaths:indexPaths];
}

-(void)ar_moveItemAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)newIndexPath
{
    NSValue *indexPathSizeValue = [self sizeCacheAtIndexPath:indexPath];
    NSValue *newIndexPathSizeValue = [self sizeCacheAtIndexPath:newIndexPath];
    
    NSMutableArray *section1 = [self sizeCache][indexPath.section];
    NSMutableArray *section2 = [self sizeCache][newIndexPath.section];
    [section1 replaceObjectAtIndex:indexPath.row withObject:newIndexPathSizeValue];
    [section2 replaceObjectAtIndex:newIndexPath.row withObject:indexPathSizeValue];
    
    [self ar_moveItemAtIndexPath:indexPath toIndexPath:newIndexPath];
}

-(void)ar_reloadData
{
    [[self sizeCache] removeAllObjects];
    [self ar_reloadData];
}

#pragma mark - private methods

-(NSMutableDictionary *)templeCells
{
    NSMutableDictionary *templeCells = objc_getAssociatedObject(self, _cmd);
    if (templeCells == nil) {
        templeCells = @{}.mutableCopy;
        objc_setAssociatedObject(self, _cmd, templeCells, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return templeCells;
}

-(id)templeCaculateCellWithIdentifier:(NSString *)identifier
{
    NSMutableDictionary *templeCells = [self templeCells];
    id cell = [templeCells objectForKey:identifier];
    if (cell == nil) {
        NSDictionary *cellNibDict = [self valueForKey:@"_cellNibDict"];
        UINib *cellNIb = cellNibDict[identifier];
        cell = [[cellNIb instantiateWithOwner:nil options:nil] lastObject];
        templeCells[identifier] = cell;
    }
    
    return cell;
}

#pragma mark - cache methods

-(NSMutableArray *)sizeCache
{
    NSMutableArray *cache = objc_getAssociatedObject(self, _cmd);
    if (cache == nil) {
        cache = [[NSMutableArray alloc] init];
        objc_setAssociatedObject(self, _cmd, cache, OBJC_ASSOCIATION_RETAIN);
    }
    return cache;
}

-(BOOL)hasCacheAtIndexPath:(NSIndexPath *)indexPath
{
    [self safeCacheAtIndexPath:indexPath];
    NSMutableArray *cache = [self sizeCache];
    NSValue *value = cache[indexPath.section][indexPath.row];
    if ([value isEqualToValue:ARLayoutCellInvalidateValue]) {
        return NO;
    } else {
        return YES;
    }
}

-(NSValue *)sizeCacheAtIndexPath:(NSIndexPath *)indexPath
{
    [self safeCacheAtIndexPath:indexPath];
    NSValue *sizeValue = [self sizeCache][indexPath.section][indexPath.row];
    return sizeValue;
}

-(void)safeCacheAtIndexPath:(NSIndexPath *)indexPath
{
    [self safeCacheAtSection:indexPath.section];
    
    NSMutableArray *cache = [self sizeCache];
    NSMutableArray *sectionCache = [cache objectAtIndex:indexPath.section];
    
    NSInteger length = (indexPath.row - sectionCache.count + 1);
    if (length <= 0) {
        return;
    }
    NSIndexSet *indexSetA = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, length)];
    [indexSetA enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
        [sectionCache addObject:ARLayoutCellInvalidateValue];
    }];
}

-(void)safeCacheAtSection:(NSUInteger)section
{
    NSMutableArray *cache = [self sizeCache];
    NSInteger length = section - cache.count + 1;
    if (length <= 0) {
        return;
    }
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, length)];
    [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
        [cache addObject:[NSMutableArray array]];
    }];
}

@end
