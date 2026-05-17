import '../../data/models/report_model.dart';

abstract class ReportState {
  const ReportState();
}

class ReportInitial extends ReportState {
  const ReportInitial();
}

class ReportLoading extends ReportState {
  const ReportLoading();
}

class ReportByProductLoaded extends ReportState {
  final ReportByProductModel data;
  final String? startDate;
  final String? endDate;

  const ReportByProductLoaded({
    required this.data,
    this.startDate,
    this.endDate,
  });
}

class ReportByBranchLoaded extends ReportState {
  final ReportByBranchModel data;
  final String? startDate;
  final String? endDate;

  const ReportByBranchLoaded({
    required this.data,
    this.startDate,
    this.endDate,
  });
}

class ReportError extends ReportState {
  final String message;

  const ReportError(this.message);
}
