import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:rank_ten/components/rank_item_view_card.dart';
import 'package:rank_ten/misc/app_theme.dart';
import 'package:rank_ten/misc/utils.dart';
import 'package:rank_ten/models/ranked_list_card.dart';
import 'package:rank_ten/providers/dark_theme_provider.dart';
import 'package:rank_ten/providers/main_user_provider.dart';
import 'package:rank_ten/routes/ranked_list_view_screen.dart';
import 'package:rank_ten/routes/user_info_screen.dart';

import 'choose_pic.dart';

void launchRankListViewScreen(
    {@required BuildContext context, @required RankedListCard listCard}) {
  var mainUserName =
      Provider.of<MainUserProvider>(context, listen: false).mainUser.userName;
  Navigator.pushNamed(context, '/ranked_list_view',
      arguments: RankedListViewScreenArgs(
          listTitle: listCard.title,
          listId: listCard.id,
          isMain: mainUserName == listCard.userName));
}

class RankedListCardWidget extends StatelessWidget {
  final RankedListCard listCard;
  final bool shouldPushInfo;

  const RankedListCardWidget(
      {Key key, @required this.listCard, this.shouldPushInfo = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var userProvider = Provider.of<MainUserProvider>(context, listen: false);
    var isLiked = userProvider.mainUser.likedLists.contains(listCard.id);

    var hasThree = listCard.numItems > 3;
    var remainingLabel = "";
    if (hasThree && listCard.numItems == 4) {
      remainingLabel = "View 1 more item";
    } else if (hasThree) {
      remainingLabel = "View ${listCard.numItems - 3} more items";
    }

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(left: 10, right: 10, bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      child: Container(
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CardHeader(
                shouldPushInfo: shouldPushInfo,
                userName: listCard.userName,
                profPicUrl: listCard.profPic,
                dateCreated: listCard.dateCreated),
            GestureDetector(
              onTap: () => launchRankListViewScreen(
                  context: context, listCard: listCard),
              child: Text(listCard.title,
                  style: Theme.of(context).textTheme.headline4,
                  textAlign: TextAlign.center),
            ),
            const SizedBox(height: 10),
            listCard.picture.isNotEmpty
                ? GestureDetector(
                onTap: () =>
                    launchRankListViewScreen(
                        context: context, listCard: listCard),
                child: RankItemImage(imageUrl: listCard.picture))
                : SizedBox(),
            GestureDetector(
                onTap: () =>
                    launchRankListViewScreen(
                        context: context, listCard: listCard),
                child: RankPreviewItems(previewItems: listCard.rankList)),
            hasThree
                ? GestureDetector(
              onTap: () =>
                  launchRankListViewScreen(
                      context: context, listCard: listCard),
              child: Text(remainingLabel,
                  style: Theme
                      .of(context)
                      .textTheme
                      .headline6
                      .copyWith(
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.bold)),
            )
                : SizedBox(),
            CardFooter(
                numLikes: listCard.numLikes,
                isLiked: isLiked,
                id: listCard.id,
                isList: true),
            listCard.commentPreview != null
                ? CommentPreviewCard(
                    commentPreview: listCard.commentPreview,
                    numComments: listCard.numComments)
                : SizedBox()
          ],
        ),
      ),
    );
  }
}

class CardHeader extends StatelessWidget {
  final int dateCreated;
  final String userName;
  final String profPicUrl;
  final bool shouldPushInfo;

  CardHeader(
      {@required this.dateCreated,
      @required this.userName,
      @required this.profPicUrl,
      this.shouldPushInfo = true});

  @override
  Widget build(BuildContext context) {
    var isDark = Provider.of<DarkThemeProvider>(context).isDark;
    var textTheme = Theme.of(context)
        .textTheme
        .headline6
        .copyWith(color: isDark ? white : secondText);
    return GestureDetector(
      onTap: () {
        if (userName ==
            Provider.of<MainUserProvider>(context, listen: false)
                .mainUser
                .userName) {
          Scaffold.of(context).showSnackBar(Utils.getSB("That's you!"));
          return;
        }

        if (shouldPushInfo) {
          Navigator.pushNamed(context, '/user_info_screen',
              arguments: UserInfoScreenArgs(name: userName));
        }
      },
      child: Padding(
        padding: const EdgeInsets.only(top: 14, left: 14, right: 20, bottom: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: [
            Row(children: [
              CircleImage(profPicUrl: profPicUrl, userName: userName),
              const SizedBox(width: 8),
              Text(userName, style: textTheme)
            ]),
            Text(Utils.getTimeDiff(dateCreated), style: textTheme)
          ],
        ),
      ),
    );
  }
}

class CircleImage extends StatelessWidget {
  final String profPicUrl;
  final String userName;
  final double size, textSize;

  CircleImage(
      {@required this.profPicUrl,
      @required this.userName,
      this.size = 60.0,
      this.textSize = 26});

  @override
  Widget build(BuildContext context) {
    var profPic = profPicUrl.isEmpty
        ? Container(
        width: size,
        height: size,
        child: Center(
          child: Text(userName[0],
              textAlign: TextAlign.center,
              style: Theme
                  .of(context)
                  .textTheme
                  .headline5
                  .copyWith(color: Colors.black, fontSize: textSize)),
        ),
        decoration: new BoxDecoration(
          shape: BoxShape.circle,
          color: Utils.getRandomColor(),
        ))
        : Container(
        width: size,
        height: size,
        decoration: new BoxDecoration(
            shape: BoxShape.circle,
            image: new DecorationImage(
                fit: BoxFit.fill, image: new NetworkImage(profPicUrl))));

    return profPic;
  }
}

class RankPreviewItem extends StatelessWidget {
  final int rank;
  final String rankItemTitle;

  RankPreviewItem({Key key, @required this.rank, @required this.rankItemTitle})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var isDark = Provider
        .of<DarkThemeProvider>(context, listen: false)
        .isDark;
    return Row(
      children: [
        RankCircle(rank: rank),
        const SizedBox(width: 10),
        Expanded(
            child: Text(rankItemTitle,
                style: Theme
                    .of(context)
                    .textTheme
                    .headline5
                    .copyWith(
                    fontSize: 26, color: isDark ? white : Colors.black)))
      ],
    );
  }
}

class CardFooter extends StatefulWidget {
  final int numLikes;
  final bool isLiked, isList;
  final String id;

  CardFooter({
    @required this.numLikes,
    @required this.id,
    @required this.isLiked,
    this.isList = true,
  });

  @override
  _CardFooterState createState() => _CardFooterState();
}

class _CardFooterState extends State<CardFooter> {
  int _numLikes;
  bool _isLiked;
  Future<String> likeFuture;

  @override
  void initState() {
    super.initState();
    _numLikes = widget.numLikes;
    _isLiked = widget.isLiked;
    likeFuture = Future.delayed(Duration(milliseconds: 5), () => "INIT");
  }

  @override
  Widget build(BuildContext context) {
    var loading = Padding(
        padding: const EdgeInsets.all(15),
        child: SpinKitFoldingCube(size: 30, color: hanPurple));
    var userProvider = Provider.of<MainUserProvider>(context, listen: false);

    return FutureBuilder<String>(
        future: likeFuture,
        key: UniqueKey(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            bool liked;
            if (snapshot.data == "INIT") {
              liked = _isLiked;
            } else if (snapshot.data == "LIKED") {
              liked = true;
              _numLikes += 1;
            } else if (snapshot.data == "UNLIKED") {
              liked = false;
              _numLikes -= 1;
            } else {
              return loading;
            }

            if (_numLikes < 0) {
              _numLikes = 0;
            }

            return Padding(
              padding: const EdgeInsets.only(left: 30, right: 30, bottom: 20),
              child: Column(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      IconButton(
                        splashColor: Colors.transparent,
                        icon: Icon(
                            liked ? Icons.favorite : Icons.favorite_border,
                            color: Colors.red,
                            size: 55),
                        onPressed: () {
                          setState(() {
                            likeFuture = widget.isList
                                ? userProvider.likeList(widget.id)
                                : userProvider.likeComment(widget.id);
                          });
                        },
                      ),
                      Column(children: [
                        SizedBox(
                          height: 20,
                        ),
                        GestureDetector(
                          onTap: () => showLikedUsers(
                              context: context, listId: widget.id),
                          child: Text(
                            "$_numLikes likes",
                            style: Theme.of(context).textTheme.headline5,
                          ),
                        )
                      ])
                    ],
                  ),
                  SizedBox(height: 10)
                ],
              ),
            );
          }

          return loading;
        });

    /*return Padding(
      padding: const EdgeInsets.only(left: 30, right: 30, bottom: 20),
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                splashColor: Colors.transparent,
                icon: Icon(_isLiked ? Icons.favorite : Icons.favorite_border,
                    color: Colors.red, size: 55),
                onPressed: () async {
                  if (true) {
                    _liking = true;
                    var action;
                    try {
                      action = await widget.likePressed();
                    } catch (e) {
                      print(e);
                    }


                    if (action) {
                      setState(() {
                        _numLikes++;
                        _isLiked = true;
                      });
                    } else {
                      setState(() {
                        _numLikes--;
                        _isLiked = false;
                      });
                    }
                    //Future.delayed(
                    //    Duration(milliseconds: 1500), () => _liking = false);
                  } else {
                    Scaffold.of(context).hideCurrentSnackBar();
                    Scaffold.of(context)
                        .showSnackBar(Utils.getSB('Please wait'));
                  }
                },
              ),
              Column(children: [
                SizedBox(
                  height: 20,
                ),
                Text(
                  "$_numLikes likes",
                  style: Theme
                      .of(context)
                      .textTheme
                      .headline5,
                )
              ])
            ],
          ),
          SizedBox(height: 10)
        ],
      ),
    );*/
  }
}

class RankPreviewItems extends StatelessWidget {
  final List<RankItemPreview> previewItems;

  RankPreviewItems({@required this.previewItems});

  @override
  Widget build(BuildContext context) {
    var colChildren = List<Widget>();
    previewItems.forEach((item) {
      colChildren.add(RankPreviewItem(
          rank: item.rank, rankItemTitle: item.itemName, key: ObjectKey(item)));
    });

    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(children: colChildren));
  }
}

class CommentPreviewCard extends StatelessWidget {
  final CommentPreview commentPreview;
  final int numComments;

  CommentPreviewCard(
      {@required this.commentPreview, @required this.numComments});

  @override
  Widget build(BuildContext context) {
    final isDark = Provider
        .of<DarkThemeProvider>(context)
        .isDark;

    return Card(
        color: isDark ? hanPurple : palePurple,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        child: Container(
          width: MediaQuery
              .of(context)
              .size
              .width,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CardHeader(
                  dateCreated: commentPreview.dateCreated,
                  userName: commentPreview.userName,
                  profPicUrl: commentPreview.profPic),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  commentPreview.comment,
                  textAlign: TextAlign.start,
                  style: Theme
                      .of(context)
                      .textTheme
                      .headline6,
                ),
              ),
              const SizedBox(height: 10),
              numComments > 1
                  ? Text("View all $numComments comments",
                  style: Theme
                      .of(context)
                      .textTheme
                      .headline6
                      .copyWith(
                      fontSize: 14,
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.bold))
                  : SizedBox(),
              numComments > 1 ? SizedBox(height: 10) : SizedBox()
            ],
          ),
        ));
  }
}
