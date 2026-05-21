import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:core/network/api_error.dart';
import '../../domain/repositories/i_report_repository.dart';
import 'report_state.dart';

class ReportCubit extends Cubit<ReportState> {
  final IReportRepository _repo;

  ReportCubit(this._repo) : super(const ReportInitial());

  @override
  void emit(ReportState state) {
    if (!isClosed) super.emit(state);
  }

  Future<void> loadByProduct({
    String? startDate,
    String? endDate,
  }) async {
    emit(const ReportLoading());
    try {
      final data = await _repo.getReportByProduct(
        startDate: startDate,
        endDate: endDate,
      );
      emit(ReportByProductLoaded(
        data: data,
        startDate: startDate,
        endDate: endDate,
      ));
    } on ApiError catch (e) {
      emit(ReportError(e.message));
    } catch (_) {
      emit(const ReportError('Rapor yüklenemedi'));
    }
  }

  Future<void> loadByBranch({
    String? startDate,
    String? endDate,
  }) async {
    emit(const ReportLoading());
    try {
      final data = await _repo.getReportByBranch(
        startDate: startDate,
        endDate: endDate,
      );
      emit(ReportByBranchLoaded(
        data: data,
        startDate: startDate,
        endDate: endDate,
      ));
    } on ApiError catch (e) {
      emit(ReportError(e.message));
    } catch (_) {
      emit(const ReportError('Rapor yüklenemedi'));
    }
  }
}
