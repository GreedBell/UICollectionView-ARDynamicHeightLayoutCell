# Fork
fork from [UICollectionView-ARDynamicHeightLayoutCell](https://github.com/AugustRush/UICollectionView-ARDynamicHeightLayoutCell) of version v1.0

# UICollectionView+ARDynamicHeightLayoutCell

* An simple category for caculating autolayout UICollectionViewCell size. Automatic manage cell's size cache, automatic invalidate, most improve efficiency.

## Demo gif 

<img src="https://github.com/AugustRush/UICollectionView-ARDynamicHeightLayoutCell/blob/master/gif1.gif" width="320">
<img src="https://github.com/AugustRush/UICollectionView-ARDynamicHeightLayoutCell/blob/master/gif2.gif" width="320">

## Support

* A prototype cell in storyboard

* -registerNib:forCellReuseIdentifier:

* -registerClass:forCellReuseIdentifier:

## Usage

if your cell use autolayout , all you need just to do like this:

#### Fixed width

```
#import "UICollectionView+ARDynamicHeightLayoutCell.h"

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [collectionView ar_sizeForCellWithIdentifier:@"DynamicHeightCell" fixedWidth:300 configuration:^(id cell) {

       //configuration your cell
        FeedModel *feed = self.feeds[indexPath.row];
        [cell filleCellWithFeed:feed];

    }];
}
```
#### Fixed height

```
#import "UICollectionView+ARDynamicHeightLayoutCell.h"

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [collectionView ar_sizeForCellWithIdentifier:@"DynamicHeightCell" fixedHeight:400 configuration:^(id cell) {
    	//configuration your cell
           FeedModel *feed = self.feeds[indexPath.row];
           [cell filleCellWithFeed:feed];
	}
}
```

#### Dynamic size

```
#import "UICollectionView+ARDynamicHeightLayoutCell.h"

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [collectionView ar_sizeForCellWithIdentifier:@"DynamicHeightCell" configuration:^(id cell) {
    	//configuration your cell
           FeedModel *feed = self.feeds[indexPath.row];
           [cell filleCellWithFeed:feed];
	}
}
```

## Install

pod 'UICollectionView-ARDynamicHeightLayoutCell_Bell'

## Change Log

[CHANGELOG](CHANGELOG.md)

## LICENSE

[MIT](LICENSE)
