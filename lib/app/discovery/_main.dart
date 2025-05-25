import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:netease_music_api/netease_music_api.dart';
import 'package:zmusic/common/res.dart';
import 'package:zmusic/common/utils.dart';
import 'package:zmusic/widget/scroll_physics_ext.dart';

class DiscoveryMain extends StatefulWidget {
  @override
  _DiscoveryMainState createState() => _DiscoveryMainState();
}

class _DiscoveryMainState extends State<DiscoveryMain>
    with AutomaticKeepAliveClientMixin {
  var _indicator = new GlobalKey<RefreshIndicatorState>();

  BannerListWrap _bannerData = BannerListWrap();
  HomeDragonBallWrap _dragonBallData = HomeDragonBallWrap();
  HomeBlockPageWrap _blockPageData = HomeBlockPageWrap();

  _requestData(bool refresh) async {
    var api = NeteaseMusicApi();
    var bannerMetaData = api.homeBannerListDioMetaData();
    var dragonBallMetaData = api.homeDragonBallStaticDioMetaData();
    var blockPageMetaData = api.homeBlockPageDioMetaData(refresh: refresh);

    var data = await api
        .batchApi([bannerMetaData, dragonBallMetaData, blockPageMetaData]);

    setState(() {
      _bannerData =
          BannerListWrap.fromJson(data.findResponseData(bannerMetaData) ?? {});
      _dragonBallData = HomeDragonBallWrap.fromJson(
          data.findResponseData(dragonBallMetaData) ?? {});
      _blockPageData = HomeBlockPageWrap.fromJson(
          data.findResponseData(blockPageMetaData) ?? {});
    });
  }

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _indicator.currentState?.show(atTop: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    List<Widget> blockWidgets = [];
    final blocks = _blockPageData.data.blocks;
    blockWidgets.addAll(List.generate(blocks.length, (index) {
      var block = blocks[index];
      Widget bodyBlock;
      if (block.showType == 'HOMEPAGE_SLIDE_PLAYLIST') {
        bodyBlock = _BlockBodyStylePlaylist(block.creatives ?? []);
      } else {
        bodyBlock = Text('body showType: `${block.showType}`');
      }
      return Column(
        children: [_BlockHeader(block.uiElement), bodyBlock],
      );
    }));
    return RefreshIndicator(
      key: _indicator,
      onRefresh: () {
        return _requestData(true);
      },
      child: ListView(
        children: [
          Padding(padding: EdgeInsets.only(top: 5)),
          _Banner(_bannerData),
          _DragonBall(_dragonBallData)
        ]..addAll(blockWidgets),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class _Banner extends StatefulWidget {
  final BannerListWrap _bannerData;

  _Banner(this._bannerData);

  @override
  _BannerState createState() => _BannerState();
}

class _BannerState extends State<_Banner> {
  @override
  Widget build(BuildContext context) {
    return Container(
      // 长宽比 2.65
      height: (MediaQuery.of(context).size.width - 15 * 2) / 2.65,
      child: PageView.builder(
          itemCount: widget._bannerData.banners.length,
          itemBuilder: (BuildContext context, int index) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  widget._bannerData.banners[index].pic,
                  fit: BoxFit.fill,
                ),
              ),
            );
          }),
    );
  }
}

class _DragonBall extends StatefulWidget {
  final HomeDragonBallWrap _dragonBallData;

  _DragonBall(this._dragonBallData);

  @override
  _DragonBallState createState() => _DragonBallState();
}

class _DragonBallState extends _FixedSizePageScrollState<_DragonBall> {
  _DragonBallState()
      : super(appIconCount: 5.5, appIconWidth: 40, appIconUnusedWidth: 15);

  @override
  Widget build(BuildContext context) {
    final HomeDragonBallWrap _dragonBallData = widget._dragonBallData;
    super.build(context);
    return Container(
      height: 83,
      padding: EdgeInsets.only(left: appIconUnusedWidth, top: 15),
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: FixedSizePageScrollPhysics(
            parent: const BouncingScrollPhysics(),
            itemDimension: iconDimension,
          ),
          itemCount: _dragonBallData.data.length,
          itemBuilder: (BuildContext context, int index) {
            var ballItem = _dragonBallData.data[index];
            Widget iconWidget = Image.network(
              ballItem.iconUrl,
              width: appIconWidth,
              height: appIconWidth,
            );
            // 每日推荐 日期
            if (ballItem.id == -1) {
              iconWidget = Stack(
                alignment: Alignment.center,
                children: [
                  iconWidget,
                  Transform.translate(
                    offset: Offset(0, 2),
                    child: Text(
                      '${DateTime.now().day}',
                      style: TextStyle(
                          color: color_primary_shallow,
                          fontSize: 10,
                          fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              );
            }
            if (ballItem.skinSupport ?? false) {
              iconWidget = DecoratedBox(
                decoration: BoxDecoration(
                    color: color_secondary,
                    borderRadius:
                        BorderRadius.all(Radius.circular(appIconWidth / 2))),
                child: iconWidget,
              );
            }
            return Container(
              width: appIconWidth,
              margin: EdgeInsets.only(right: iconMarginRight),
              child: Column(
                children: [
                  iconWidget,
                  Text(
                    ballItem.name ?? "",
                    style: TextStyle(fontSize: 10, color: color_text_primary),
                  )
                ],
              ),
            );
          }),
    );
  }
}

class _BlockHeader extends StatefulWidget {
  final HomeBlockPageUiElement _uiElement;

  _BlockHeader(this._uiElement);

  @override
  _BlockHeaderState createState() => _BlockHeaderState();
}

class _BlockHeaderState extends State<_BlockHeader> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      margin: EdgeInsets.symmetric(horizontal: 15),
      child: Flex(
        direction: Axis.horizontal,
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Text(widget._uiElement.subTitle?.title ?? "",
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          ),
          SizedBox(
            width: 62,
            height: 22,
            child: TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.white,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: color_text_hint),
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
              onPressed: () {},
              child: Text(
                widget._uiElement.button?.text ?? "",
                style: TextStyle(fontSize: 11),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BlockBodyStylePlaylist extends StatefulWidget {
  final List<HomeBlockPageCreative> _creatives;

  _BlockBodyStylePlaylist(this._creatives);

  @override
  _BlockBodyStylePlaylistState createState() => _BlockBodyStylePlaylistState();
}

class _BlockBodyStylePlaylistState
    extends _FixedSizePageScrollState<_BlockBodyStylePlaylist> {
  _BlockBodyStylePlaylistState()
      : super(appIconCount: 3.15, appIconWidth: 100.66, appIconUnusedWidth: 15);

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      height: 134,
      padding: EdgeInsets.only(left: appIconUnusedWidth),
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: FixedSizePageScrollPhysics(
              parent: const BouncingScrollPhysics(),
              itemDimension: iconDimension),
          itemCount: widget._creatives.length,
          itemBuilder: (BuildContext context, int index) {
            var creative = widget._creatives[index];
            Widget imgWidget = Stack(
              children: [
                Image.network(
                  creative.uiElement.image!.imageUrl,
                  width: appIconWidth,
                  height: appIconWidth,
                ),
                Positioned(
                    right: 2,
                    top: 1,
                    child: Row(
                      children: [
                        Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 11,
                        ),
                        Text(
                            '${convergenceAmountUnit(creative.resources[0].resourceExtInfo.playCount ?? 0)}',
                            style: TextStyle(fontSize: 11, color: Colors.white))
                      ],
                    ))
              ],
            );
            return Container(
              width: appIconWidth,
              margin: EdgeInsets.only(right: iconMarginRight),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  imgWidget,
                  Text(
                    creative.uiElement.mainTitle?.title ?? "",
                    maxLines: 2,
                    style: TextStyle(fontSize: 11, color: color_text_primary),
                  )
                ],
              ),
            );
          }),
    );
  }
}

abstract class _FixedSizePageScrollState<T extends StatefulWidget>
    extends State<T> {
  // 显示个数
  final double appIconCount;

  // 条目使用宽度
  final double appIconWidth;

  // 忽略宽度
  final double appIconUnusedWidth;

  @protected
  double iconMarginRight = 0;

  @protected
  double iconDimension = 0;

  _FixedSizePageScrollState(
      {required this.appIconCount,
      required this.appIconWidth,
      required this.appIconUnusedWidth});

  @override
  Widget build(BuildContext context) {
    iconMarginRight = (MediaQuery.of(context).size.width -
            appIconUnusedWidth -
            appIconWidth * appIconCount) /
        appIconCount.floor();
    iconDimension = appIconWidth + iconMarginRight;
    return Container();
  }
}
