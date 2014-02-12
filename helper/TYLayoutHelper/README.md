TYLayoutHelper
===========

*View the [source of this content](https://github.com/TekYin/MordinSolus/tree/master/TYLayoutHelper).*

TYLayoutHelper used to help you layouting views on a container. 

Usage
-------------------------

Init TYLayoutHelper by passing the container with all the views you want to sort and layout.

```objective-c
TYLayoutHelper *lh = [[TYLayoutHelper alloc] initWithContainer:self.uContainer padding:CGBorderMake(0, 0, 0, 0) orientation:TYLayoutOrientationHorizontal];
```

>__note__ : CGBorder are struct with 4 variables (left, right, top, bottom) and can be created with ```CGBorderMake(CGFloat left, CGFloat right, CGFloat top, CGFloat bottom)``` 

There are 2 extra parameter to help you with customization.
 + padding : put extra space between container border and subviews. 
 + orientation : set the layout orientation (__TYLayoutOrientationHorizontal__ or __TYLayoutOrientationVertical__) 

and then add the items you want to sort with 

```objective-c
[lh addMemberWithView:view align:TYLayoutAlignCenter margin:CGBorderMake(2, 2, 2, 2)];
````
Parameters :
 + view : view you want to sort
 + align : placement align to container (__TYLayoutAlignLeftOrTop__, __TYLayoutAlignCenter__, __TYLayoutAlignRightOrTop__)
 + margin : put extra space outside the view

and finally call ```[lh doReLayoutWithAnimation:YES duration:1];``` to do the re-layout with animation, or just call ```[lh doReLayout];``` to re-layout without animation.

Extra usage
---------------------------

+ ```- (TYLayoutHelper *)randomizeMember;```  
Randomize member to scramble the position index
+ ```- (CGSize)getContentBounds;```  
Get total size of the view including padding and margin, used in UIScrollView contentSize
