import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:rank_ten/api/preferences_store.dart';
import 'package:rank_ten/blocs/preview_lists_bloc.dart';
import 'package:rank_ten/components/ranked_list_card_widget.dart';
import 'package:rank_ten/events/ranked_list_preview_events.dart';
import 'package:rank_ten/misc/app_theme.dart';
import 'package:rank_ten/misc/utils.dart';
import 'package:rank_ten/models/ranked_list_card.dart';
import 'package:rank_ten/repos/ranked_list_preview_repository.dart';

class GenericListPreviewWidget extends StatefulWidget {
  final int sort, userId;
  final String token, query, listType, emptyMessage;

  const GenericListPreviewWidget(
      {this.sort = 0,
      this.userId = 0,
      this.token = "",
      this.query = "",
      this.emptyMessage = 'No lists found',
      @required this.listType,
      Key key})
      : super(key: key);

  @override
  _GenericListPreviewWidgetState createState() =>
      _GenericListPreviewWidgetState();
}

class _GenericListPreviewWidgetState extends State<GenericListPreviewWidget> {
  PreviewListsBloc _listsBloc;
  ScrollController _scrollController;
  int _sort = PreferencesStore.currentSort;

  @override
  void initState() {
    super.initState();
    _listsBloc = PreviewListsBloc(endpointBase: widget.listType);
    _sort = widget.sort;
    _listsBloc.addEvent(RankedListPreviewEvent(
        sort: _sort,
        userId: widget.userId,
        token: widget.token,
        query: widget.query,
        refresh: false));
    _scrollController = ScrollController()..addListener(_onScrollListener);
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
    _listsBloc.dispose();
  }

  void _onScrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (!_listsBloc.hitMax) {
        _listsBloc.addEvent(RankedListPreviewEvent(
            sort: _sort,
            userId: widget.userId,
            token: widget.token,
            query: widget.query,
            refresh: false));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<RankedListCard>>(
      stream: _listsBloc.modelStateStream,
      builder:
          (BuildContext context, AsyncSnapshot<List<RankedListCard>> snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          return RefreshIndicator(
            onRefresh: () {
              return Future.delayed(Duration(milliseconds: 0), () {
                _listsBloc.addEvent(RankedListPreviewEvent(
                    sort: _sort,
                    userId: widget.userId,
                    token: widget.token,
                    query: widget.query,
                    refresh: true));
              });
            },
            child: ListView.builder(
                shrinkWrap: false,
                physics: const BouncingScrollPhysics(
                    parent: const AlwaysScrollableScrollPhysics()),
                controller: _scrollController,
                itemCount: snapshot.data.length + 1,
                itemBuilder: (context, index) {
                  if (snapshot.data.length == 0) {
                    return Center(
                        child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Text(
                              widget.emptyMessage,
                              style: Theme.of(context).textTheme.headline6,
                              textAlign: TextAlign.center,
                            )));
                  }

                  if (index >= snapshot.data.length && !_listsBloc.hitMax) {
                    return Column(children: [
                      SizedBox(
                        height: 10,
                      ),
                      const SpinKitWave(size: 50, color: hanPurple),
                      SizedBox(
                        height: 5,
                      )
                    ]);
                  } else if (index >= snapshot.data.length) {
                    return SizedBox();
                  }

                  return RankedListCardWidget(
                      shouldPushInfo: widget.listType != USER_LISTS &&
                          widget.listType != USER_LISTS_ALL &&
                          widget.listType != USER_TOP_LISTS,
                      listCard: snapshot.data[index],
                      key: ObjectKey(snapshot.data[index]));
                }),
          );
        } else if (snapshot.hasError) {
          WidgetsBinding.instance.addPostFrameCallback(
              (_) => Utils.showSB("Error getting lists", context));
          return Utils.getErrorImage();
        }

        return const SpinKitRipple(size: 50, color: hanPurple);
      },
    );
  }
}
