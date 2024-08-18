part of 'sports_game_widget.dart';
class GameBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int index) onTap;

  const GameBottomNavigationBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      selectedFontSize: 10,
      unselectedFontSize: 8,
      type: BottomNavigationBarType.fixed,
      //backgroundColor: LongaColor.white_two,
      selectedItemColor: WlsPosColor.reddish_pink,
      onTap: (index) {
        onTap(index);
      },
      items: [
        BottomNavigationBarItem(
            icon: Image.asset(
                  "assets/icons/reset_icon.png",
              width: currentIndex == 0 ? 24 : 24,
              height: currentIndex == 0 ? 24 : 24,
            ),
            label: "Reset"),
        BottomNavigationBarItem(
          icon: Image.asset(
            "assets/icons/reset_icon.png",
            width: currentIndex == 1 ? 24 : 24,
            height: currentIndex == 1 ? 24 : 24,
          ),
          label: "No. Of Lines",
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            "assets/icons/reset_icon.png",
            width: currentIndex == 2 ? 24 : 22,
            height: currentIndex == 2 ? 24 : 22,
          ),
          label: "Bet Values",
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            "assets/icons/reset_icon.png",
            width: currentIndex == 3 ? 24 : 24,
            height: currentIndex == 3 ? 24 : 24,
          ),
          label: "Buy Now",
        ),
      ],
    );
  }
}