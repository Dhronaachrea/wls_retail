part of 'sports_game_widget.dart';

class DrawSelector extends StatelessWidget {
  final DrawData? drawData;
  final ScrollController drawController;
  final Function(int) onTap;
  final int drawGameSelectedIndex;
  final ResponseData? responseData;

  const DrawSelector({
    Key? key,
    required this.drawData,
    required this.drawController,
    required this.onTap,
    required this.drawGameSelectedIndex,
    required this.responseData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 65,
      padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
      child: getDrawOption(drawDataP: drawData!),
    );
  }

  Widget getDrawOption({required DrawData drawDataP}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: WlsPosColor.tangerine,
        boxShadow: [
          BoxShadow(
            color: WlsPosColor.black.withOpacity(0.5),
            blurRadius: 4.0,
          ),
        ],
        border: Border.all(
          color: WlsPosColor.black,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            drawDataP.drawName ?? '',
            style: const TextStyle(
                color: WlsPosColor.marine,
                fontWeight: FontWeight.w500,
                fontFamily: "Roboto",
                fontStyle: FontStyle.normal,
                fontSize: 14.0),
            textAlign: TextAlign.center,
          ),
          const HeightBox(5),
          PoolSize(
              minimumPoolAmount: drawDataP.minimumPoolAmount,
              totalSaleTillNow: drawDataP.totalSaleTillNow,
              prizePayoutPercentage: responseData?.prizePayoutPercentage,
              color: WlsPosColor.white
              // : WlsPosColor.tangerine,
              ),
        ],
      ),
    );
  }
}
