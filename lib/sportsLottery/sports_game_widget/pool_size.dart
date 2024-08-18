part of 'sports_game_widget.dart';

class PoolSize extends StatelessWidget {
  final double minimumPoolAmount;
  final double totalSaleTillNow;
  final double prizePayoutPercentage;
  final Color color;

  const PoolSize({
    Key? key,
    required this.minimumPoolAmount,
    required this.totalSaleTillNow,
    required this.prizePayoutPercentage,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return
        // Container(
        // height: 35,
        // decoration: const BoxDecoration(
        //   color: WlsPosColor.yellow_orange_three,
        // ),
        // child:
        Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Text(
        //   "Pool Size: ",
        //   style: TextStyle(
        //       color: color,
        //       fontWeight: FontWeight.w400,
        //       fontFamily: "Roboto",
        //       fontStyle: FontStyle.normal,
        //       fontSize: 12.0),
        // ),
        Text(
          "${getDefaultCurrency(getLanguage())} ${getMaxOf(
                minimumPoolAmount,
                totalSaleTillNow,
                prizePayoutPercentage,
              ) ?? 0.0}",
          style: const TextStyle(
              color: WlsPosColor.marine,
              fontWeight: FontWeight.w500,
              fontFamily: "Roboto",
              fontStyle: FontStyle.normal,
              fontSize: 12.0),
        ),
      ],
    );
    // );
  }

  getMaxOf(double minimumPoolAmount, double totalSaleTillNow,
      double prizePayoutPercentage) {
    double max = (minimumPoolAmount >= totalSaleTillNow)
        ? minimumPoolAmount
        : totalSaleTillNow;
    double percentage = max * prizePayoutPercentage / 100;
    double maxValue = percentage > minimumPoolAmount
        ? percentage
        : minimumPoolAmount;
    return maxValue.toStringAsFixed(2);
  }
}
