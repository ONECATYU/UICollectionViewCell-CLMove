//
//  UICollectionViewCell+CLMove.m
//  KuaiziHealth
//
//  Created by 余汪送 on 2017/3/30.
//  Copyright © 2017年 capsule. All rights reserved.
//

#import "UICollectionViewCell+CLMove.h"
#import <objc/runtime.h>

static const void *CL_SnapshotCellKey = &CL_SnapshotCellKey;
static const void *CL_MoveItemBlockKey = &CL_MoveItemBlockKey;
static const void *CL_FromIndexPathKey = &CL_FromIndexPathKey;
static const void *CL_ToIndexPathKey = &CL_ToIndexPathKey;

@implementation UICollectionViewCell (CLMove)

@dynamic cl_moveEnabled;

- (void)setCl_moveEnabled:(BOOL)cl_moveEnabled {
    objc_setAssociatedObject(self, @selector(cl_moveEnabled), @(cl_moveEnabled), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (cl_moveEnabled) {
        UIPanGestureRecognizer *panGes = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(cl_pan:)];
        [self addGestureRecognizer:panGes];
    }
}

- (void)cl_pan:(UIPanGestureRecognizer *)pan {
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
        {
            UIView *snapCell = [self cl_snapshotView];
            objc_setAssociatedObject(self, CL_SnapshotCellKey, snapCell, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            UICollectionView *collectionView = [self cl_collectionViewForView:self];
            [collectionView addSubview:snapCell];
            self.hidden = YES;
            NSIndexPath *fromIndexPath = [collectionView indexPathForCell:self];
            objc_setAssociatedObject(self, CL_FromIndexPathKey, fromIndexPath, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
            break;
            
        case UIGestureRecognizerStateChanged:
        {
            UICollectionView *collectionView = [self cl_collectionViewForView:self];
            UIView *snapshotCell = objc_getAssociatedObject(self, CL_SnapshotCellKey);
            CGPoint point = [pan translationInView:self];
            CGPoint newCenter = CGPointMake(snapshotCell.center.x + point.x,snapshotCell.center.y + point.y);
            newCenter.x = MAX(0, newCenter.x);
            newCenter.x = MIN(newCenter.x, CGRectGetWidth(self.superview.frame));
            newCenter.y = MAX(0, newCenter.y);
            newCenter.y = MIN(newCenter.y, CGRectGetHeight(self.superview.frame));
            snapshotCell.center = newCenter;
            [pan setTranslation:CGPointZero inView:self];
            NSArray *visibleCells = [collectionView visibleCells];
            for (UICollectionViewCell *cell in visibleCells) {
                if (CGRectContainsPoint(cell.frame, newCenter)) {
                    NSIndexPath *fromIndexPath = [collectionView indexPathForCell:self];
                    NSIndexPath *toIndexPath = [collectionView indexPathForCell:cell];
                    [collectionView moveItemAtIndexPath:fromIndexPath toIndexPath:toIndexPath];
                    objc_setAssociatedObject(self, CL_ToIndexPathKey, toIndexPath, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                }
            }
        }
            break;
            
        case UIGestureRecognizerStateEnded:
        {
            UIView *snapshotCell = objc_getAssociatedObject(self, CL_SnapshotCellKey);
            [snapshotCell removeFromSuperview];
            objc_setAssociatedObject(self, CL_SnapshotCellKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            self.hidden = NO;
            CLMoveItemBlock block = objc_getAssociatedObject(self, &CL_MoveItemBlockKey);
            if (block) {
                NSIndexPath *fromIndexPath = objc_getAssociatedObject(self, CL_FromIndexPathKey);
                NSIndexPath *toIndexPath = objc_getAssociatedObject(self, CL_ToIndexPathKey);
                block(fromIndexPath, toIndexPath);
            }
            objc_setAssociatedObject(self, CL_FromIndexPathKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            objc_setAssociatedObject(self, CL_ToIndexPathKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
            break;
            
        default:
            break;
    }
}

- (BOOL)cl_moveEnabled {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)cl_setMoveItemBlock:(CLMoveItemBlock)block {
    objc_setAssociatedObject(self, &CL_MoveItemBlockKey, block, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UICollectionView *)cl_collectionViewForView:(UIView *)view {
    if ([view.superview isKindOfClass:[UICollectionView class]]) {
        return (UICollectionView *)view.superview;
    }
    return [self cl_collectionViewForView:view.superview];
}

- (UIView *)cl_snapshotView {
    UIImage *snap = [self cl_snapshotImage];
    UIView *view = [[UIView alloc]initWithFrame:self.frame];
    view.layer.contents = (__bridge id _Nullable)([snap CGImage]);
    return view;
}

- (UIImage *)cl_snapshotImage {
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.opaque, 0);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *snap = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return snap;
}

@end
