### preview:    
![](https://github.com/ONECATYU/UICollectionViewCell-CLMove/blob/master/clmove.gif)    
### use
//自定义cell的时候,开启移动   
self.cl_moveEnabled = YES;    
///更新数据源的block(通过设置block,来更新数据)     
-(void)cl_setMoveItemBlock:(CLMoveItemBlock)block;
### other    
未使用ios9新增的方法,使用collectionView的moveItemAtIndexPath:toIndexPath:来实现   
    
