// ignore_for_file: public_member_api_docs, sort_constructors_first
abstract class Failer {
  String errorMessage;
  Failer({
    required this.errorMessage,
  });
}

class ServerFailer extends Failer {
  @override
  final String errorMessage;

  ServerFailer(this.errorMessage) : super(errorMessage: '');
}
