import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rank_ten/events/user_events.dart';
import 'package:rank_ten/misc/app_theme.dart';
import 'package:rank_ten/misc/utils.dart';
import 'package:rank_ten/models/ranked_list_card.dart';
import 'package:rank_ten/providers/dark_theme_provider.dart';
import 'package:rank_ten/providers/main_user_provider.dart';

import 'choose_pic.dart';

class RankedListCardWidget extends StatelessWidget {
  final RankedListCard listCard;

  const RankedListCardWidget({Key key, @required this.listCard})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var userProvider = Provider.of<MainUserProvider>(context);
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
                userName: listCard.userName,
                profPicUrl: listCard.profPic,
                dateCreated: listCard.dateCreated),
            Text("Best Shows!",
                style: Theme.of(context).textTheme.headline4,
                textAlign: TextAlign.center),
            const SizedBox(height: 10),
            listCard.picture.isNotEmpty
                ? RankItemImage(imageUrl: listCard.picture)
                : SizedBox(),
            RankPreviewItems(previewItems: listCard.rankList),
            hasThree
                ? Text(remainingLabel,
                    style: Theme.of(context).textTheme.headline6.copyWith(
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.bold))
                : SizedBox(),
            CardFooter(
              numLikes: listCard.numLikes,
              isLiked: isLiked,
              likePressed: () {
                userProvider.addUserEvent(LikeListEvent(
                    id: listCard.id, token: userProvider.jwtToken));
              },
            ),
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

  CardHeader({@required this.dateCreated,
    @required this.userName,
    @required this.profPicUrl});

  @override
  Widget build(BuildContext context) {
    var isDark = Provider
        .of<DarkThemeProvider>(context)
        .isDark;
    var textTheme = Theme
        .of(context)
        .textTheme
        .headline6
        .copyWith(color: isDark ? white : secondText);
    return Padding(
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
    );
  }
}

class CircleImage extends StatelessWidget {
  final String profPicUrl;
  final String userName;

  CircleImage({@required this.profPicUrl, @required this.userName});

  @override
  Widget build(BuildContext context) {
    var profPic = profPicUrl.isEmpty
        ? Container(
        width: 60.0,
        height: 60.0,
        color: Utils.getRandomColor(),
        child: Text(userName[0],
            style: Theme
                .of(context)
                .textTheme
                .headline2
                .copyWith(color: Colors.black)),
        decoration: new BoxDecoration(shape: BoxShape.circle))
        : Container(
        width: 60.0,
        height: 60.0,
        decoration: new BoxDecoration(
            shape: BoxShape.circle,
            image: new DecorationImage(
                fit: BoxFit.fill, image: new NetworkImage(profPicUrl))));

    return profPic;
  }
}

class RankPreviewItem extends StatelessWidget {
  final String rank;
  final String rankItemTitle;

  RankPreviewItem({Key key, @required this.rank, @required this.rankItemTitle})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
            margin: const EdgeInsets.all(12),
            child: Center(
                child: Text(
                  rank,
                  textAlign: TextAlign.center,
                  style:
                  Theme
                      .of(context)
                      .textTheme
                      .headline4
                      .copyWith(color: white),
                )),
            width: 85.0,
            height: 85.0,
            decoration:
            new BoxDecoration(shape: BoxShape.circle, color: lavender)),
        const SizedBox(width: 10),
        Expanded(
            child: Text(rankItemTitle,
                style: Theme
                    .of(context)
                    .textTheme
                    .headline4))
      ],
    );
  }
}

class CardFooter extends StatefulWidget {
  final int numLikes;
  final bool isLiked;
  final VoidCallback likePressed;

  CardFooter({@required this.numLikes,
    @required this.isLiked,
    @required this.likePressed});

  @override
  _CardFooterState createState() => _CardFooterState();
}

class _CardFooterState extends State<CardFooter> {
  int _numLikes;
  bool _isLiked,
      _liking = false;

  @override
  void initState() {
    super.initState();
    _numLikes = widget.numLikes;
    _isLiked = widget.isLiked;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 18, bottom: 20),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            icon: Icon(_isLiked ? Icons.favorite : Icons.favorite_border,
                color: Colors.red, size: 60),
            onPressed: () {
              setState(() {
                if (_liking) {
                  return;
                } else {
                  if (_isLiked) {
                    _numLikes--;
                  } else {
                    _numLikes++;
                  }
                  _isLiked = !_isLiked;

                  widget.likePressed();
                  _liking = true;
                  Future.delayed(
                      Duration(milliseconds: 1500), () => _liking = false);
                }
              });
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
                  .headline6,
            )
          ])
        ],
      ),
    );
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
          rank: item.rank.toString(),
          rankItemTitle: item.itemName,
          key: ObjectKey(item)));
    });

    return Column(children: colChildren);
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
        elevation: 2,
        margin: const EdgeInsets.all(10),
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
              Text("View all $numComments comments",
                  style: Theme
                      .of(context)
                      .textTheme
                      .headline6
                      .copyWith(
                      fontSize: 14,
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 10)
            ],
          ),
        ));
  }
}
