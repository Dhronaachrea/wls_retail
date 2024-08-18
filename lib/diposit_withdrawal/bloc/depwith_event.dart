part of 'depwith_bloc.dart';

abstract class DepWithEvent {}

class GetDepWith extends DepWithEvent {
  BuildContext context;
  String fromDate;
  String toDate;

  GetDepWith({required this.context, required this.fromDate, required this.toDate});
}
