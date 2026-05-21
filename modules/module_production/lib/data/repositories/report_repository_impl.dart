import 'package:dio/dio.dart';

import 'package:core/network/api_service.dart';
import 'package:core/network/api_error.dart';
import '../../domain/repositories/i_report_repository.dart';
import '../models/report_model.dart';

class ReportRepositoryImpl implements IReportRepository {
  final ApiService api;

  ReportRepositoryImpl({required this.api});

  @override
  Future<ReportByProductModel> getReportByProduct({
    String? startDate,
    String? endDate,
  }) async {
    try {
      final query = <String, dynamic>{};
      if (startDate != null) query['startDate'] = startDate;
      if (endDate != null) query['endDate'] = endDate;
      final res = await api.get(
        'stock/reports/by-product',
        queryParameters: query,
      );
      return ReportByProductModel.fromJson(
          Map<String, dynamic>.from(res.data as Map));
    } on DioException catch (e) {
      throw ApiError.fromDio(e);
    }
  }

  @override
  Future<ReportByBranchModel> getReportByBranch({
    String? startDate,
    String? endDate,
  }) async {
    try {
      final query = <String, dynamic>{};
      if (startDate != null) query['startDate'] = startDate;
      if (endDate != null) query['endDate'] = endDate;
      final res = await api.get(
        'stock/reports/by-branch',
        queryParameters: query,
      );
      return ReportByBranchModel.fromJson(
          Map<String, dynamic>.from(res.data as Map));
    } on DioException catch (e) {
      throw ApiError.fromDio(e);
    }
  }
}
