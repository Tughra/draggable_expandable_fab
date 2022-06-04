
# Expandable Draggable Fab

This Flutter package provides a Expandable and Draggable Floating Button with animation.

<div style="display:flex; justify-content: space-between;">
<img src="https://raw.githubusercontent.com/Tughra/draggable_expandable_fab/master/gif/demo1.gif" width="250" height="500" />
<img src="https://raw.githubusercontent.com/Tughra/draggable_expandable_fab/master/gif/demo2.gif" width="250" height="500" />
<img src="https://raw.githubusercontent.com/Tughra/draggable_expandable_fab/master/gif/demo3.gif" width="250" height="500" />
</div>
## 💻 Installation

In the dependencies: section of your pubspec.yaml, add the following line:

```yaml
dependencies:
  draggable_expandable_fab: <latest version>
```
To use the latest changes:

```yaml
  draggable_expandable_fab:
    git:
      url: https://github.com/Tughra/draggable_expandable_fab.git
      ref: master
```
## ❔ Usage

Import this class

```dart
import 'package:draggable_expandable_fab/draggable_expandable_fab.dart';
```

Replace Scaffold's parameters with these to better usage.

```dart
      floatingActionButtonAnimator: NoScalingAnimation(),
      floatingActionButtonLocation: ExpandableFloatLocation(),
```

Simple Implementation

```dart
Scaffold(
      floatingActionButtonAnimator: NoScalingAnimation(),
      floatingActionButtonLocation: ExpandableFloatLocation(),
      floatingActionButton: ExpandableDraggableFab(childrenCount: 3,
      distance: 100,// Animatiion distance during open and close. 
      children: [
        FloatingActionButton(onPressed: (){}),
        FloatingActionButton(onPressed: (){}),
        FloatingActionButton(onPressed: (){}),
      ],),
      body: Container(),
    );
 ```    
   


Full Implementation

```dart
   final Size _size = MediaQuery.of(context).size;
    return Scaffold(
      floatingActionButtonAnimator: NoScalingAnimation(),
      floatingActionButtonLocation: ExpandableFloatLocation(),
      floatingActionButton: ExpandableDraggableFab(childrenCount: 3,
        onTab: (){
        debugPrint("Tab");
        },
        childrenTransition: ChildrenTransition.fadeTransation,
        initialOpen: false,
        childrenBoxDecoration: const BoxDecoration(color: Colors.red),
        enableChildrenAnimation: true,
        curveAnimation: Curves.linear,
        reverseAnimation: Curves.linear,
        childrenType: ChildrenType.columnChildren,
        closeChildrenRotate: false,
        childrenAlignment: Alignment.topRight,
        initialDraggableOffset: Offset(_size.width-90,_size.height-100),
      distance: 100,// Animation distance during open and close.
      children: [
        FloatingActionButton(onPressed: (){}),
        FloatingActionButton(onPressed: (){}),
        FloatingActionButton(onPressed: (){}),
      ],),
      body: Container(),
    );
 ```   
