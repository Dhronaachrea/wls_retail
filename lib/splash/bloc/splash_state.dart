
import '../model/model/response/DefaultConfigData.dart';

abstract class SplashState {}

class SplashInitial extends SplashState {}


class DefaultConfigLoading extends SplashState {}

class  DefaultConfigSuccess extends SplashState{
  DefaultDomainConfigData response;

  DefaultConfigSuccess({required this.response});

}
class DefaultConfigError extends SplashState{
  String errorMessage;

  DefaultConfigError({required this.errorMessage});
}
