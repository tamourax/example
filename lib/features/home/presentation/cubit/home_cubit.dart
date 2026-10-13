import '../../../../core/pagination/pagination_cubit.dart';
import '../../data/demo_repository.dart';

class HomeCubit extends PaginationCubit<int> {
  HomeCubit(DemoRepository repository) : super(loadPage: repository.getPage);
}
