part of 'sports_game_widget.dart';

class TeamRow extends StatelessWidget {
  final int index;
  final String? homeTeam;
  final String? awayTeam;

  const TeamRow({
    Key? key,
    required this.index,
    required this.homeTeam,
    required this.awayTeam,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(homeTeam ?? "Broomwich Albion",
              style: const TextStyle(
                  color: Color(0xff012161),
                  fontWeight: FontWeight.w500,
                  fontFamily: "Roboto",
                  fontStyle: FontStyle.normal,
                  fontSize: 12.0),
              textAlign: TextAlign.left),
        ),
        Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: const Size(100, 3),
              painter: CurvePainter(),
            ),
            Container(
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: WlsPosColor.cherry, width: 1),
                  color: WlsPosColor.cherry),
              child: const Text(
                "vs",
                style: TextStyle(
                    color: WlsPosColor.white,
                    fontWeight: FontWeight.w400,
                    fontFamily: "Roboto",
                    fontStyle: FontStyle.normal,
                    fontSize: 9.0),
                textAlign: TextAlign.center,
              ).p4(),
            ),
          ],
        ),
        Expanded(
          child: Text(awayTeam ?? "Manchester United",
              style: const TextStyle(
                  color: WlsPosColor.marine_two,
                  fontWeight: FontWeight.w500,
                  fontFamily: "Roboto",
                  fontStyle: FontStyle.normal,
                  fontSize: 12.0),
              textAlign: TextAlign.right),
        ),
      ],
    );
  }
}
