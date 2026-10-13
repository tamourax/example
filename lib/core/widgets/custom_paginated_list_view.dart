import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../localization/l10n_extension.dart';
import '../pagination/pagination_cubit.dart';
import '../pagination/pagination_state.dart';
import 'custom_list_view.dart';

/// The caller owns the Cubit and triggers its first load.
class CustomPaginatedListView<T> extends StatefulWidget {
  const CustomPaginatedListView({
    super.key,
    required this.cubit,
    required this.itemBuilder,
    this.padding = const EdgeInsets.all(16),
    this.emptyWidget,
  });
  final PaginationCubit<T> cubit;
  final Widget Function(BuildContext, T, int) itemBuilder;
  final EdgeInsetsGeometry padding;
  final Widget? emptyWidget;

  @override
  State<CustomPaginatedListView<T>> createState() =>
      _CustomPaginatedListViewState<T>();
}

class _CustomPaginatedListViewState<T>
    extends State<CustomPaginatedListView<T>> {
  final _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onScroll);
  }

  void _onScroll() {
    final state = widget.cubit.state;
    if (_controller.hasClients &&
        _controller.position.extentAfter < 240 &&
        state.failure == null) {
      widget.cubit.loadNextPage();
    }
  }

  void _fillViewport() => WidgetsBinding.instance.addPostFrameCallback((_) {
    if (mounted) _onScroll();
  });

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<PaginationCubit<T>, PaginationState<T>>(
        bloc: widget.cubit,
        builder: (context, state) {
          if (state.items.isNotEmpty &&
              !state.isLoading &&
              state.hasMore &&
              state.failure == null) {
            _fillViewport();
          }
          return Column(
            children: [
              Expanded(
                child: CustomListView<T>(
                  items: state.items,
                  itemBuilder: widget.itemBuilder,
                  controller: _controller,
                  padding: widget.padding,
                  emptyWidget: widget.emptyWidget,
                  isLoading: state.isLoading,
                  hasError: state.failure != null,
                  onRetry: widget.cubit.loadNextPage,
                  onRefresh: widget.cubit.refresh,
                ),
              ),
              if (state.items.isNotEmpty && state.isLoading)
                const Padding(
                  padding: EdgeInsets.all(12),
                  child: CircularProgressIndicator(),
                ),
              if (state.items.isNotEmpty && state.failure != null)
                TextButton(
                  onPressed: widget.cubit.loadNextPage,
                  child: Text(context.l10n.retry),
                ),
            ],
          );
        },
      );
}
