import 'package:freezed_annotation/freezed_annotation.dart';

part 'allocation_template.freezed.dart';
part 'allocation_template.g.dart';

@freezed
class AllocationTemplate with _$AllocationTemplate {
  const factory AllocationTemplate({
    required int id,
    required String name,
    String? description,
    required double totalAmount,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _AllocationTemplate;

  const AllocationTemplate._();

  factory AllocationTemplate.fromJson(Map<String, dynamic> json) =>
      _$AllocationTemplateFromJson(json);
}
