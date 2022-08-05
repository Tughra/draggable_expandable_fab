library expandable_draggable_fab;

import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'draggable_widget.dart';

enum ChildrenTransition { scaleTransation, fadeTransation }

enum ChildrenType {
  rowChildren,
  columnChildren,
}

@immutable
class ExpandableDraggableFab extends StatefulWidget {
  // to control toggling of the widget
  final Function? toggle;

  final ChildrenType? childrenType;

  /// Animation duration.
  final Duration? duration;

  /// Visible children when first navigate.
  final bool? initialOpen;

  /// Close children's rotate animation when open and close
  final bool? closeChildrenRotate;

  /// The callback that is called when the open and close button is tapped or otherwise activated.
  /// If this is set to null, the button will be disabled.
  final VoidCallback? onTab;

  /// Closing widget. Avoid using clickable widgets like floating action button, inkwell etc.
  final Widget? closeWidget;

  /// Opening widget. Avoid using clickable widgets like floating action button, inkwell etc.
  final Widget? openWidget;

  /// Alignment of children.
  final Alignment? childrenAlignment;

  /// Transition of children when open and close.
  final ChildrenTransition? childrenTransition;

  /// Children's curve animation when open.
  final Curve? curveAnimation;

  /// Children's curve animation when close.
  final Curve? reverseAnimation;

  /// Children's animation when open and close.
  final bool? enableChildrenAnimation;

  /// Initial offset of the draggable widget.
  /// Offset(0,0) is the upper right corner. If you want to move it to the bottom right position, subtract the widget height from the device height.
  /// Use hot reload when you set initial position.
  final Offset? initialDraggableOffset;

  /// Children's animation distance when open and close.
  final double distance;

  /// Margin between widgets.
  final EdgeInsets? childrenInnerMargin;

  /// Margin of children.
  final EdgeInsets? childrenMargin;
  final List<Widget> children;
  final int childrenCount;

  /// Children's container color. When you want to more customize use "childrenBoxDecoration".
  final Color? childrenBacgroundColor;

  /// Children's box decoration.
  final BoxDecoration? childrenBoxDecoration;
  const ExpandableDraggableFab(
      {super.key,
      this.toggle,
      this.initialDraggableOffset,
      this.childrenType = ChildrenType.rowChildren,
      this.initialOpen,
      this.onTab,
      this.duration,
      this.closeChildrenRotate = false,
      required this.distance,
      required this.children,
      required this.childrenCount,
      this.childrenTransition,
      this.openWidget,
      this.closeWidget,
      this.childrenAlignment,
      this.curveAnimation,
      this.reverseAnimation,
      this.childrenMargin,
      this.childrenBacgroundColor,
      this.childrenInnerMargin,
      this.enableChildrenAnimation = true,
      this.childrenBoxDecoration});

  @override
  State<ExpandableDraggableFab> createState() => _ExpandableDraggableFabState();
//_ExpandableDraggableFabState createState() => _ExpandableDraggableFabState();
}

class ExpandableFloatLocation extends FloatingActionButtonLocation {
  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    return const Offset(0, 0);
  }
}

class NoScalingAnimation extends FloatingActionButtonAnimator {
  @override
  Offset getOffset(
      {required Offset begin, required Offset end, required double progress}) {
    return end;
  }

  @override
  Animation<double> getRotationAnimation({required Animation<double> parent}) {
    return Tween<double>(begin: 1.0, end: 1.0).animate(parent);
  }

  @override
  Animation<double> getScaleAnimation({required Animation<double> parent}) {
    return Tween<double>(begin: 1.0, end: 1.0).animate(parent);
  }
}

class _ExpandableDraggableFabState extends State<ExpandableDraggableFab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _expandAnimation;
  bool _open = false;
  late final Duration _duration;
  final GlobalKey _key = GlobalKey();
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return SizedBox.expand(
      key: _key,
      child: Stack(
        alignment: widget.childrenAlignment ?? Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          AnimatedSwitcher(
              duration: widget.duration ?? const Duration(milliseconds: 500),
              transitionBuilder: (Widget child, Animation<double> animation) {
                if (widget.childrenTransition ==
                        ChildrenTransition.fadeTransation ||
                    widget.childrenTransition == null) {
                  return FadeTransition(opacity: animation, child: child);
                } else {
                  return ScaleTransition(scale: animation, child: child);
                }
              },
              child: !_open
                  ? const SizedBox.shrink()
                  : Container(
                      decoration: widget.childrenBoxDecoration ??
                          BoxDecoration(
                              color: widget.childrenBacgroundColor ??
                                  Colors.black54,
                              borderRadius: BorderRadius.circular(20)),
                      margin: widget.childrenMargin ??
                          const EdgeInsets.only(
                              top: 100, right: 10, left: 10, bottom: 10),
                      child: widget.childrenType == ChildrenType.rowChildren
                          ? SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ..._buildExpandingActionButtons(),
                                ],
                              ),
                            )
                          : SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [..._buildExpandingActionButtons()],
                              ),
                            ),
                    )),
          //  Container(color: Colors.red,width: 40,height: 40,),
          // ColoredBox(color: Colors.black12,child: SizedBox(width: 200,height: 200,)),
          DraggableWidget(
            parentKey: _key,
            initialOffset:
                widget.initialDraggableOffset ?? Offset(20, size.height - 80),
            child: Stack(
              alignment: Alignment.center,
              children: [
                _buildTapToCloseFab(),
                _buildTapToOpenFab(),
              ],
            ),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _duration = widget.duration ?? const Duration(milliseconds: 500);
    _open = widget.initialOpen ?? false;
    _controller = AnimationController(
      value: _open ? 1.0 : 0.0,
      duration: widget.duration ?? _duration,
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      curve: widget.curveAnimation ?? Curves.fastOutSlowIn,
      reverseCurve: widget.reverseAnimation ?? Curves.fastOutSlowIn,
      parent: _controller,
    );
    // ignore: unused_element
    void toggle(){
      return _toggle();
    } 
  }

  List<Widget> _buildExpandingActionButtons() {
    final children = <Widget>[];
    final count = widget.childrenCount;
    final step = 18 * count / (count / 2);
    for (var i = 0, angleInDegrees = 0.0;
        i < count;
        i++, angleInDegrees += step) {
      children.add(
        _ExpandingActionButton(
          enableOpenAnimation: widget.enableChildrenAnimation!,
          open: _open,
          childrenMargin: widget.childrenInnerMargin,
          closeChildrenRotate: widget.closeChildrenRotate!,
          directionInDegrees: angleInDegrees,
          maxDistance: widget.distance,
          progress: _expandAnimation,
          child: widget.children[i],
        ),
      );
    }
    return children;
  }

  Widget _buildTapToCloseFab() {
    return Visibility(
      visible: widget.children.isNotEmpty,
      child: GestureDetector(
        onTap: _toggle,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: widget.closeWidget ??
              Container(
                  decoration: const BoxDecoration(boxShadow: [
                    BoxShadow(
                        offset: Offset(1, 2),
                        blurRadius: 4,
                        spreadRadius: 2,
                        color: Colors.black38)
                  ], shape: BoxShape.circle, color: Colors.white),
                  width: 46,
                  height: 46,
                  child: const Icon(
                    Icons.clear,
                    color: Colors.black,
                  )),
        ),
      ),
    );
  }

  Widget _buildTapToOpenFab() {
    return IgnorePointer(
      ignoring: _open,
      child: AnimatedContainer(
        transformAlignment: Alignment.center,
        transform: Matrix4.diagonal3Values(
          _open ? 0.7 : 1.0,
          _open ? 0.7 : 1.0,
          1.0,
        ),
        duration: _duration,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
        child: AnimatedOpacity(
          opacity: widget.children.isEmpty
              ? 1
              : _open
                  ? 0.0
                  : 1.0,
          curve: const Interval(0.0, 1.0, curve: Curves.easeInOut),
          duration: _duration,
          child: GestureDetector(
            onTap: _toggle,
            child: widget.openWidget ??
                Container(
                    decoration: const BoxDecoration(boxShadow: [
                      BoxShadow(
                          offset: Offset(1, 2),
                          blurRadius: 4,
                          spreadRadius: 2,
                          color: Colors.black38)
                    ], shape: BoxShape.circle, color: Colors.black),
                    width: 60,
                    height: 60,
                    child: const Icon(
                      Icons.create,
                      color: Colors.white,
                    )),
          ),
        ),
      ),
    );
  }

  void _toggle() {
    if (widget.onTab != null) widget.onTab!();
    setState(() {
      _open = !_open;
      if (_open) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }
}

@immutable
class _ExpandingActionButton extends StatelessWidget {
  final bool closeChildrenRotate;

  final bool open;
  final bool enableOpenAnimation;
  final double directionInDegrees;
  final double maxDistance;
  final Animation<double> progress;
  final Widget child;
  final EdgeInsets? childrenMargin;
  const _ExpandingActionButton(
      {required this.childrenMargin,
      required this.directionInDegrees,
      required this.maxDistance,
      required this.progress,
      required this.child,
      required this.open,
      required this.closeChildrenRotate,
      required this.enableOpenAnimation});

  @override
  Widget build(BuildContext context) {
    // print((directionInDegrees*(math.pi / 180.0)).toString()+"-");
    //  print(math.pi);
    return AnimatedBuilder(
      animation: progress,
      builder: (context, child) {
        final offset = Offset(
          directionInDegrees * (math.pi / 180),
          maxDistance * (1 - progress.value),
        );
        return Padding(
            padding: childrenMargin ?? const EdgeInsets.all(10),
            child: Transform.rotate(
                angle: closeChildrenRotate == true
                    ? 0
                    : (1.0 - progress.value) * math.pi,
                child: Padding(
                    padding: enableOpenAnimation
                        ? EdgeInsets.symmetric(
                            vertical: open ? offset.dy : 0,
                            horizontal: open ? offset.dy : 0)
                        : EdgeInsets.zero,
                    child: child!)));
      },
      child: FadeTransition(opacity: progress, child: child),
    );
    /*
    Transform.translate(
                offset: Offset(
                    0,//(closePosition == ClosePosition.closeToRight ? 1 : -1) * offset.dy,
                    0),
     */
  }
}
