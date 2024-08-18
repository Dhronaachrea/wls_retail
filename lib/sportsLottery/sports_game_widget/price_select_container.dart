part of 'sports_game_widget.dart';

class PriceSelectContainer extends StatelessWidget {
  final int index;
  final int? selectedPriceContainerIndex;
  final double unitTicketPrice;
  final String currency;
  final double currencyMultiplier;
  final bool onOtherTap;
  final Function(double value) onChanged;
  final double maxTicketPrice;
  final double selectedPrice;

  const PriceSelectContainer({
    Key? key,
    required this.index,
    required this.selectedPriceContainerIndex,
    required this.unitTicketPrice,
    required this.currency,
    required this.currencyMultiplier,
    required this.onOtherTap,
    required this.onChanged,
    required this.maxTicketPrice,
    required this.selectedPrice,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Orientation orientation = MediaQuery.of(context).orientation;
    final bool isLandscape = (orientation == Orientation.landscape);

    return AnimatedContainer(
      width: context.screenWidth / 5.9 ?? 55,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(
          Radius.circular(10),
        ),
        border: Border.all(color: WlsPosColor.cherry, width: 1),
        color: selectedPriceContainerIndex == index
            ? WlsPosColor.cherry
            : Colors.white,
      ),
      duration: const Duration(milliseconds: 500),
      curve: Curves.bounceInOut,
      child: Center(
        child:
        // onOtherTap && index == 4
        //     ? Container(
        //         color: Colors.white,
        //         child: TextField(
        //           maxLength: 4,
        //           autofocus: true,
        //           keyboardType: TextInputType.number,
        //           inputFormatters: <TextInputFormatter>[
        //             // for below version 2 use this
        //             FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
        //             // for version 2 and greater you can also use this
        //             FilteringTextInputFormatter.digitsOnly,
        //             //deny first input as zero
        //             FilteringTextInputFormatter.deny(
        //               RegExp(r'^0+'),
        //             ),
        //           ],
        //           maxLines: 1,
        //           onChanged: (value) {
        //             // if (double.parse(value.isEmpty ? '0' : value ?? '0') >
        //             //     maxTicketPrice) {
        //             //   value = '0';
        //             // }
        //             onChanged(double.parse(value.isEmpty ? '0' : value ?? '0'));
        //           },
        //           decoration: const InputDecoration(
        //             isDense: true,
        //             contentPadding: EdgeInsets.zero,
        //             counterText: "",
        //           ),
        //         ),
        //       ).p4()
        //     :
          Text(
                index == 4
                    ? selectedPriceContainerIndex == 4 ? "$currency $selectedPrice" : "Others"
                    : "$currency ${currencyMultiplier * (index + 1)}",
                style: TextStyle(
                  color: selectedPriceContainerIndex == index
                      ? Colors.white
                      : WlsPosColor.cherry,
                  fontWeight: FontWeight.w400,
                  fontFamily: "Roboto",
                  fontStyle: FontStyle.normal,
                  fontSize: isLandscape ? 15 : 10.0,
                ),
                textAlign: TextAlign.center,
              ).p8(),
      ),
    ).p4();
  }
}
