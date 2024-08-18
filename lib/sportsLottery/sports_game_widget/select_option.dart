part of 'sports_game_widget.dart';

class SelectOption extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback onTap;
  final dynamic probability;

  const SelectOption(
      {Key? key,
      required this.title,
      required this.selected,
      required this.onTap,
      required this.probability})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onTap();
      },
      child: probability == null
          ? AnimatedContainer(
              decoration: BoxDecoration(
                color:
                    selected ? WlsPosColor.cherry : WlsPosColor.white_six_new,
                border: Border.all(
                  color: WlsPosColor.warm_grey_three,
                ),
              ),
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              child: Text(title,
                      style: TextStyle(
                          color: selected
                              ? WlsPosColor.white
                              : WlsPosColor.brownish_grey,
                          fontWeight: FontWeight.w500,
                          fontFamily: "Roboto",
                          fontStyle: FontStyle.normal,
                          fontSize: 12.0),
                      textAlign: TextAlign.center)
                  .pSymmetric(v: 5),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AnimatedContainer(
                  decoration: BoxDecoration(
                    color: selected
                        ? WlsPosColor.cherry
                        : WlsPosColor.white_six_new,
                    border: Border.all(
                      color: WlsPosColor.warm_grey_three,
                    ),
                  ),
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  child: Text(title,
                          style: TextStyle(
                              color: selected
                                  ? WlsPosColor.white
                                  : WlsPosColor.brownish_grey,
                              fontWeight: FontWeight.w500,
                              fontFamily: "Roboto",
                              fontStyle: FontStyle.normal,
                              fontSize: 12.0),
                          textAlign: TextAlign.center)
                      .pSymmetric(v: 5),
                ),
                const SizedBox(
                  height: 5.0,
                ),
                Text("$probability % ",
                    style: TextStyle(
                        color: selected
                            ? WlsPosColor.cherry
                            : WlsPosColor.brownish_grey,
                        fontWeight: FontWeight.w500,
                        fontFamily: "Roboto",
                        fontStyle: FontStyle.normal,
                        fontSize: 12.0),
                    textAlign: TextAlign.center)
              ],
            ),
    );
  }
}
