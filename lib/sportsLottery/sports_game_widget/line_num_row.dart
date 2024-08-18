part of 'sports_game_widget.dart';

class LineNumRow extends StatelessWidget {
  final int index;
  final String? venueName;
  final String? startTime;
  final String? gameName;
  final String? eventGameName;

  const LineNumRow(
      {Key? key,
      required this.index,
      required this.venueName,
      required this.startTime,
      this.gameName,
      this.eventGameName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return gameName == "PICK4"
        ? Column(
            children: [
              Text(
                eventGameName! ?? '',
                style: TextStyle(
                  // color: WlsPosColor.white,
                  fontWeight: FontWeight.w400,
                  fontFamily: "Roboto",
                  fontStyle: FontStyle.normal,
                  fontSize: 14.0,
                ),
              ).pOnly(bottom: 2, top: 5),
              Text(
                '$eventGameName Probabilities',
                style: TextStyle(
                  color: WlsPosColor.navy_blue,
                  fontWeight: FontWeight.bold,
                  fontFamily: "Roboto",
                  fontStyle: FontStyle.normal,
                  fontSize: 12.0,
                ),
              ).pOnly(bottom: 5),
            ],
          )
        : Row(
            children: [
              Container(
                decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    color: WlsPosColor.marine),
                child: Text(
                  "${index + 1}",
                  style: const TextStyle(
                      color: WlsPosColor.white,
                      fontWeight: FontWeight.w500,
                      fontFamily: "Roboto",
                      fontStyle: FontStyle.normal,
                      fontSize: 9.0),
                  textAlign: TextAlign.left,
                ).pSymmetric(v: 5, h: 5),
              ),
              Text(venueName ?? "African League, Madagascar",
                      style: const TextStyle(
                          color: WlsPosColor.brownish_grey,
                          fontWeight: FontWeight.w400,
                          fontFamily: "Roboto",
                          fontStyle: FontStyle.normal,
                          fontSize: 10.0),
                      textAlign: TextAlign.left)
                  .pSymmetric(h: 10),
              const Spacer(),
              Text(
                  formatDate(
                    date: startTime ?? '14:30',
                    inputFormat: Format.apiDateFormat2,
                    outputFormat: Format.dateFormat11,
                  ),
                  style: const TextStyle(
                      color: WlsPosColor.brownish_grey,
                      fontWeight: FontWeight.w400,
                      fontFamily: "Roboto",
                      fontStyle: FontStyle.normal,
                      fontSize: 10.0),
                  textAlign: TextAlign.left)
            ],
          );
  }
}
