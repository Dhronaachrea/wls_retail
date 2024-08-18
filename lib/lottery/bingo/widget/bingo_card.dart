part of 'bingo_widget.dart';

class BingoCard extends StatelessWidget {
  final bool isSelected;
  final CardModel cardModel;
  final VoidCallback onCardTap;
  final bool onPurchase;
  final VoidCallback? onDelete;

  const BingoCard(
      {Key? key,
      required this.isSelected,
      required this.cardModel,
      required this.onCardTap,
      this.onPurchase = false,
      this.onDelete})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var numberBorder = const BorderSide(
      color: WlsPosColor.white,
      width: 1.0,
    );
    var cardColor = isSelected
        ? WlsPosColor.marine_two
        : WlsPosColor.periwinkle_blue; // on selected
    return InkWell(
      onTap: () {
        onCardTap();
      },
      child: Stack(
        children: [
          Container(
            margin: const EdgeInsets.all(5),
            padding: const EdgeInsets.all(5),
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
              color: WlsPosColor.white_two,
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(16)),
              child: Container(
                decoration: BoxDecoration(
                  color: cardColor,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "BINGO",
                      style: TextStyle(
                          color: WlsPosColor.white,
                          fontWeight: FontWeight.w700,
                          fontFamily: "Roboto",
                          fontStyle: FontStyle.normal,
                          fontSize: 20.0),
                      textAlign: TextAlign.left,
                    ).pSymmetric(h: 10, v: 5),
                    Container(
                      color: WlsPosColor.white,
                      child: GridView.builder(
                        itemCount: cardModel.cardNumberList.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 5,
                        ),
                        itemBuilder: (context, numberIndex) {
                          int numberPosition = numberIndex + 1;
                          return InkWell(
                            child: Container(
                              // margin: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: cardColor,
                                border: Border(
                                  top: numberPosition == 1 ||
                                          numberPosition == 2 ||
                                          numberPosition == 3 ||
                                          numberPosition == 4 ||
                                          numberPosition == 5
                                      ? BorderSide.none
                                      : numberBorder,
                                  bottom: (numberPosition ~/ 5 == 4 &&
                                              numberPosition != 20) ||
                                          numberPosition ~/ 5 == 5
                                      ? BorderSide.none
                                      : numberBorder,
                                  left: numberPosition % 5 == 1
                                      ? BorderSide.none
                                      : numberBorder,
                                  right: numberPosition % 5 == 0 &&
                                          numberIndex != 0
                                      ? BorderSide.none
                                      : numberBorder,
                                ),
                              ),
                              child: Center(
                                child: FittedBox(
                                  child: Text(
                                      cardModel.cardNumberList[numberIndex] ==
                                              'X'
                                          ? "FREE"
                                          : cardModel
                                              .cardNumberList[numberIndex],
                                      style: const TextStyle(
                                          color: WlsPosColor.white_two,
                                          fontWeight: FontWeight.w400,
                                          fontFamily: "Roboto",
                                          fontStyle: FontStyle.normal,
                                          fontSize: 15.0),
                                      textAlign: TextAlign.center),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          cardColor == WlsPosColor.periwinkle_blue
              ? Container()
              : Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: onPurchase ? WlsPosColor.white : WlsPosColor.golden_rod,
                      shape: BoxShape.circle,
                    ),
                    child: onPurchase
                        ? InkWell(
                            onTap: () {
                              if (onDelete != null) {
                                onDelete!();
                              }
                            },
                            child: const Icon(Icons.delete,
                                color: WlsPosColor.reddish_pink))
                        : const Icon(Icons.check, color: WlsPosColor.white),
                  ),
                )
        ],
      ),
    );
  }
}
