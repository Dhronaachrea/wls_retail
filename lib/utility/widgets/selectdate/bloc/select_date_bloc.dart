import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meta/meta.dart';
import 'package:wls_pos/utility/date_format.dart';
import 'package:wls_pos/utility/utils.dart';

part 'select_date_event.dart';

part 'select_date_state.dart';

class SelectDateBloc extends Bloc<SelectDateEvent, SelectDateState> {
  SelectDateBloc() : super(SelectDateInitial()) {
    on<PickFromDate>(_onPickFromDate);
    on<PickToDate>(_onPickToDate);
  }

  String fromDate = formatDate(
    date: DateTime.now().subtract(const Duration(days: 30)).toString(),
    inputFormat: Format.apiDateFormat2,
    outputFormat: Format.dateFormat9,
  );

  String toDate = formatDate(
    date: DateTime.now().toString(),
    inputFormat: Format.apiDateFormat2,
    outputFormat: Format.dateFormat9,
  );

  String fromGameDate = formatDate(
    date: DateTime.now().subtract(const Duration(days: 30)).toString(),
    inputFormat: Format.apiDateFormat2,
    outputFormat: Format.apiDateFormat3,
  );

  String toGameDate = formatDate(
    date: DateTime.now().toString(),
    inputFormat: Format.apiDateFormat2,
    outputFormat: Format.apiDateFormat3,
  );

  FutureOr<void> _onPickFromDate(
      PickFromDate event, Emitter<SelectDateState> emit) async {
    BuildContext context = event.context;
    DateTime? pickedDate = await showCalendar(
        context,
        DateFormat(Format.dateFormat9).parse(fromDate),
        null,
        DateTime.now());
    if (pickedDate != null && fromDateValid(pickedDate) ) {
      fromDate = formatDate(
        date: DateFormat(Format.calendarFormat).format(pickedDate),
        inputFormat: Format.calendarFormat,
        outputFormat: Format.dateFormat9,
      );

      fromGameDate = formatDate(
        date: DateFormat(Format.calendarFormat).format(pickedDate),
        inputFormat: Format.calendarFormat,
        outputFormat: Format.apiDateFormat3,
      );

      emit(DateUpdated(toDate: toGameDate, fromDate: fromGameDate));
    } else if(pickedDate != null) {
      log("Please Select Valid Date");
      //SnackbarGlobal.show("Please Select Valid Date");
      if(context.mounted){
        WlsSnackBar.show("Please Select Valid Date", context);
      } else {
        SnackbarGlobal.show("Please Select Valid Date");
      }
    }
  }

  FutureOr<void> _onPickToDate(
      PickToDate event, Emitter<SelectDateState> emit) async {
    BuildContext context = event.context;
    DateTime? pickedDate =
        await showCalendar(context, DateTime.now(), null, DateTime.now());
    if (pickedDate != null && toDateValid(pickedDate) ) {
      toDate = formatDate(
        date: DateFormat(Format.calendarFormat).format(pickedDate),
        inputFormat: Format.calendarFormat,
        outputFormat: Format.dateFormat9,
      );

      toGameDate = formatDate(
        date: DateFormat(Format.calendarFormat).format(pickedDate),
        inputFormat: Format.calendarFormat,
        outputFormat: Format.apiDateFormat3,
      );

      emit(DateUpdated(toDate: toGameDate, fromDate: fromGameDate));
    } else if(pickedDate != null ) {
      log("Please Select Valid to Date");
      if(context.mounted){
        WlsSnackBar.show("Please Select Valid Date", context);
      } else {
        SnackbarGlobal.show("Please Select Valid Date");
      }
    }
  }

  bool fromDateValid(DateTime pickedDate) {
    // String newPickedDate = formatDate(
    //   date: toDate,
    //   inputFormat: Format.calendarFormat,
    //   outputFormat: Format.dateFormat9,
    // );
    // return DateTime.parse(newPickedDate).isBefore(DateTime.parse(fromDate));
    DateTime formattedToDate = DateFormat(Format.dateFormat9).parse(toDate);
    String newPickedDate = formatDate(
      date: DateFormat(Format.calendarFormat).format(pickedDate),
      inputFormat: Format.calendarFormat,
      outputFormat: Format.dateFormat9,
    );
    DateTime formattedNewPickedDate = DateFormat(Format.dateFormat9).parse(newPickedDate);
    bool valueToReturn = formattedNewPickedDate.isBefore(formattedToDate) || formattedNewPickedDate.isAtSameMomentAs(formattedToDate);
    return valueToReturn;
  }

  bool toDateValid(DateTime pickedDate) {
    DateTime formattedFromDate = DateFormat(Format.dateFormat9).parse(fromDate);
    String newPickedDate = formatDate(
      date: DateFormat(Format.calendarFormat).format(pickedDate),
      inputFormat: Format.calendarFormat,
      outputFormat: Format.dateFormat9,
    );
    DateTime formattedNewPickedDate = DateFormat(Format.dateFormat9).parse(newPickedDate);
    bool valueToReturn = formattedNewPickedDate.isAfter(formattedFromDate) || formattedNewPickedDate.isAtSameMomentAs(formattedFromDate);
    return valueToReturn;
  }
}
