part of 'sports_game_widget.dart';

class GameTypeSelector extends StatelessWidget {
  final GameType gameType;
  final VoidCallback onGameTap;
  final VoidCallback onTossTap;

  const GameTypeSelector(
      {Key? key,
      required this.gameType,
      required this.onGameTap,
      required this.onTossTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        InkWell(
          onTap: () {
            onGameTap();
          },
          child: AnimatedContainer(
            decoration: BoxDecoration(
                border: Border.all(color: WlsPosColor.brownish_grey_six),
                color: gameType == GameType.game
                    ? WlsPosColor.cherry
                    : WlsPosColor.white,
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(10),
                )),
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeInOut,
            child: Text(
              "GAME",
              style: TextStyle(
                color: gameType == GameType.game
                    ? WlsPosColor.white
                    : WlsPosColor.cherry,
              ),
            ).pSymmetric(h: 32, v: 8),
          ),
        ),
        InkWell(
          onTap: () {
            onTossTap();
          },
          child: Container(
            decoration: BoxDecoration(
                border: Border.all(color: WlsPosColor.brownish_grey_six),
                color: gameType == GameType.toss
                    ? WlsPosColor.cherry
                    : WlsPosColor.white,
                borderRadius: const BorderRadius.horizontal(
                  right: Radius.circular(10),
                )),
            child: Text(
              "TOSS",
              style: TextStyle(
                color: gameType == GameType.toss
                    ? WlsPosColor.white
                    : WlsPosColor.cherry,
              ),
            ).pSymmetric(h: 32, v: 8),
          ),
        ),
      ],
    ).pOnly(left: 8, right: 8, top: 8);
  }
}
