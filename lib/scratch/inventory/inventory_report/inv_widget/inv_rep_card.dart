part of 'inv_widget.dart';

class InvRepCard extends StatefulWidget {
  final List<GameWiseBookDetailList>? gameWiseBookDetailList;
  final int cardIndex;

  const InvRepCard(
      {Key? key, required this.gameWiseBookDetailList, required this.cardIndex})
      : super(key: key);

  @override
  State<InvRepCard> createState() => _InvRepCardState();
}

class _InvRepCardState extends State<InvRepCard> {
  @override
  Widget build(BuildContext context) {
    var gameWiseBookDetailList = widget.gameWiseBookDetailList;
    int cardIndex = widget.cardIndex;

    var divider = const Divider(
      color: WlsPosColor.warm_grey_four,
      thickness: 1,
      height: 15,
    );

    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        border: Border.all(color: WlsPosColor.white_seven, width: 1),
        boxShadow: const [
          BoxShadow(
              color: WlsPosColor.black_16,
              offset: Offset(0, 3),
              blurRadius: 6,
              spreadRadius: 0)
        ],
        color: WlsPosColor.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const HeightBox(10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Game Number",
                style: TextStyle(
                  color: WlsPosColor.warm_grey_four,
                  fontWeight: FontWeight.w400,
                  fontStyle: FontStyle.normal,
                  fontSize: 12.0,
                ),
              ),
              Text(
                "${gameWiseBookDetailList![cardIndex].gameNumber}",
                style: const TextStyle(
                    color: WlsPosColor.tomato,
                    fontWeight: FontWeight.w700,
                    fontSize: 18.0),
              ),
            ],
          ),
          divider,
          const Text(
            "Game Name",
            style: TextStyle(
                color: WlsPosColor.warm_grey_four,
                fontWeight: FontWeight.w400,
                fontStyle: FontStyle.normal,
                fontSize: 12.0),
          ),
          const HeightBox(10),
          FittedBox(
            child: Text(
              "${gameWiseBookDetailList[cardIndex].gameName}",
              style: const TextStyle(
                  color: WlsPosColor.black_four,
                  fontWeight: FontWeight.w500,
                  fontSize: 15.0),
            ),
          ),
          divider,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "In-Transit",
                style: TextStyle(
                  color: WlsPosColor.warm_grey_four,
                  fontWeight: FontWeight.w400,
                  fontStyle: FontStyle.normal,
                  fontSize: 12.0,
                ),
              ),
              Text(
                gameWiseBookDetailList[cardIndex].inTransitPacksList != null &&
                        gameWiseBookDetailList[cardIndex]
                            .inTransitPacksList!
                            .isNotEmpty
                    ? "${gameWiseBookDetailList[cardIndex].inTransitPacksList?.length}"
                    : "0",
              ),
            ],
          ),
          const HeightBox(10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Received",
                style: TextStyle(
                  color: WlsPosColor.warm_grey_four,
                  fontWeight: FontWeight.w400,
                  fontStyle: FontStyle.normal,
                  fontSize: 12.0,
                ),
              ),
              Text(
                gameWiseBookDetailList[cardIndex].receivedPacksList != null &&
                        gameWiseBookDetailList[cardIndex]
                            .receivedPacksList!
                            .isNotEmpty
                    ? "${gameWiseBookDetailList[cardIndex].receivedPacksList?.length}"
                    : "0",
              ),
            ],
          ),
          const HeightBox(10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Activated",
                style: TextStyle(
                  color: WlsPosColor.warm_grey_four,
                  fontWeight: FontWeight.w400,
                  fontStyle: FontStyle.normal,
                  fontSize: 12.0,
                ),
              ),
              Text(
                gameWiseBookDetailList[cardIndex].activatedPacksList != null &&
                        gameWiseBookDetailList[cardIndex]
                            .activatedPacksList!
                            .isNotEmpty
                    ? "${gameWiseBookDetailList[cardIndex].activatedPacksList?.length}"
                    : "0",
              ),
            ],
          ),
          const HeightBox(10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "In-Voice",
                style: TextStyle(
                  color: WlsPosColor.warm_grey_four,
                  fontWeight: FontWeight.w400,
                  fontStyle: FontStyle.normal,
                  fontSize: 12.0,
                ),
              ),
              Text(
                gameWiseBookDetailList[cardIndex].invoicedPacksList != null &&
                    gameWiseBookDetailList[cardIndex]
                        .invoicedPacksList!
                        .isNotEmpty
                    ? "${gameWiseBookDetailList[cardIndex].invoicedPacksList?.length}"
                    : "0",
              ),
            ],
          ),

          const HeightBox(10),
        ],
      ),
    );
  }
}
