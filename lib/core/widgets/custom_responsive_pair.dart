import 'package:flutter/widgets.dart';

/// Equal columns on wide screens, stacked in reading order on mobile.
class CustomResponsivePair extends StatelessWidget {
  const CustomResponsivePair({
    super.key,
    required this.first,
    required this.second,
    this.breakpoint = 600,
    this.spacing = 16,
  });
  final Widget first;
  final Widget second;
  final double breakpoint;
  final double spacing;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => constraints.maxWidth >= breakpoint
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: first),
              SizedBox(width: spacing),
              Expanded(child: second),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              first,
              SizedBox(height: spacing),
              second,
            ],
          ),
  );
}
