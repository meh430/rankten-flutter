import 'package:flutter/foundation.dart';
import 'package:rank_ten/api/rank_api.dart';
import 'package:rank_ten/models/ranked_list_card.dart';

//page, sort
const DISCOVER_LISTS = 'discover';
//page, sort, token
const LIKED_LISTS = 'likes';
//page, sort, name
const USER_LISTS = 'rankedlists';
//page, token
const FEED_LISTS = 'feed';
//page, sort, query
const SEARCH_LISTS = 'search_lists';

class RankedListPreviewRepository {
  RankApi _api = RankApi();

  Future<List<RankedListCard>> getRankedListPreview(
      {@required String endpointBase,
      String name,
      int page,
      int sort,
      String token = "",
      String query}) async {
    String endpoint = '/$endpointBase';

    switch (endpointBase) {
      case DISCOVER_LISTS:
        endpoint += '/$page/$sort';
        break;
      case LIKED_LISTS:
        endpoint += '/$page';
        break;
      case USER_LISTS:
        endpoint += '/$name/$page/$sort';
        break;
      case SEARCH_LISTS:
        endpoint += '/$page/$sort';
        break;
    }

    final response = await _api.get(endpoint: endpoint, bearerToken: token);
    var listPreviews = List<RankedListCard>();
    response
        .forEach((rList) => listPreviews.add(RankedListCard.fromJson(rList)));
    return listPreviews;
  }
}