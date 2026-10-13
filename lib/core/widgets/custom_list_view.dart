import 'package:flutter/material.dart';
import '../localization/l10n_extension.dart';

class CustomListView<T> extends StatelessWidget {
  const CustomListView({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.isLoading = false,
    this.hasError = false,
    this.onRetry,
    this.onRefresh,
    this.controller,
    this.emptyWidget,
    this.padding = const EdgeInsets.all(16),
    this.separatorBuilder,
    this.shrinkWrap = false,
    this.physics,
  });
  final List<T> items;
  final Widget Function(BuildContext, T, int) itemBuilder;
  final bool isLoading;
  final bool hasError;
  final VoidCallback? onRetry;
  final Future<void> Function()? onRefresh;
  final ScrollController? controller;
  final Widget? emptyWidget;
  final EdgeInsetsGeometry padding;
  final IndexedWidgetBuilder? separatorBuilder;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  @override
  Widget build(BuildContext context) {
    final Widget content;
    if (items.isNotEmpty) {
      content = ListView.separated(
        controller: controller,
        padding: padding,
        shrinkWrap: shrinkWrap,
        physics: physics ?? const AlwaysScrollableScrollPhysics(),
        itemCount: items.length,
        separatorBuilder:
            separatorBuilder ?? (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) =>
            itemBuilder(context, items[index], index),
      );
    } else {
      content = ListView(
        controller: controller,
        padding: padding,
        shrinkWrap: shrinkWrap,
        physics: physics ?? const AlwaysScrollableScrollPhysics(),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 48),
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : hasError
                ? Column(
                    children: [
                      Text(context.l10n.somethingWentWrong),
                      TextButton(
                        onPressed: onRetry,
                        child: Text(context.l10n.retry),
                      ),
                    ],
                  )
                : emptyWidget ?? Center(child: Text(context.l10n.emptyList)),
          ),
        ],
      );
    }
    return onRefresh == null
        ? content
        : RefreshIndicator(onRefresh: onRefresh!, child: content);
  }
}
