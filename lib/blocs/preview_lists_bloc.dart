import 'package:rank_ten/events/ranked_list_preview_events.dart';
import 'package:rank_ten/models/ranked_list_card.dart';
import 'package:rank_ten/repos/ranked_list_preview_repository.dart';

import 'bloc.dart';

class PreviewListsBloc
    extends Bloc<List<RankedListCard>, RankedListPreviewEvent> {
  final String endpointBase;
  RankedListPreviewRepository _previewRepository;

  PreviewListsBloc({this.endpointBase}) {
    _previewRepository = RankedListPreviewRepository();
    model = [];

    initEventListener();
  }

  @override
  Future<void> eventToState(event) async {
    super.eventToState(event);
    if (event is RankedListPreviewEvent) {
      paginate((pageNum) {
        return _previewRepository.getRankedListPreview(
            endpointBase: endpointBase,
            userId: event.userId,
            page: pageNum,
            sort: event.sort,
            token: event.token,
            query: event.query,
            refresh: event.refresh);
      }, event);
    }
  }
}
