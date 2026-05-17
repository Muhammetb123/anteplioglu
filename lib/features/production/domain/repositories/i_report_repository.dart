import '../../data/models/report_model.dart';

abstract class IReportRepository {
  Future<ReportByProductModel> getReportByProduct({
    String? startDate,
    String? endDate,
  });

  Future<ReportByBranchModel> getReportByBranch({
    String? startDate,
    String? endDate,
  });
}
