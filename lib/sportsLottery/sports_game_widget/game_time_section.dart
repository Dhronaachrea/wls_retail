part of 'sports_game_widget.dart';

class GameTimeSection extends StatelessWidget {
  final String? marketName;
  final String? gameName;

  const GameTimeSection({Key? key, required this.marketName, this.gameName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: WlsPosColor.brownish_grey_six,
        boxShadow: [
          BoxShadow(
            color: WlsPosColor.brownish_grey_six.withOpacity(0.5),
            blurRadius: 4.0,
          ),
        ],
      ),
      child: gameName == "PICK4"
          ? Column(
              children: [
                Text(
                  "Race",
                  style: const TextStyle(
                    color: WlsPosColor.white,
                    fontWeight: FontWeight.w500,
                    fontFamily: "Roboto",
                    fontStyle: FontStyle.normal,
                    fontSize: 14.0,
                  ),
                ).pOnly(bottom: 2),
                Text(
                  "Horse Number",
                  style: const TextStyle(
                    color: WlsPosColor.white,
                    fontWeight: FontWeight.w500,
                    fontFamily: "Roboto",
                    fontStyle: FontStyle.normal,
                    fontSize: 14.0,
                  ),
                )
              ],
            ).pSymmetric(v: 5)
          : Center(
              child: Text(
                marketName ?? "",
                style: const TextStyle(
                  color: WlsPosColor.white,
                  fontWeight: FontWeight.w500,
                  fontFamily: "Roboto",
                  fontStyle: FontStyle.normal,
                  fontSize: 14.0,
                ),
              ).pSymmetric(v: 5),
            ),
    ).pOnly(bottom: 5);
  }
}
