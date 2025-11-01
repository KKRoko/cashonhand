import 'package:freezed_annotation/freezed_annotation.dart';
import '../enums/bucket_type.dart';

part 'allocation_template_item.freezed.dart';
part 'allocation_template_item.g.dart';

@freezed
class AllocationTemplateItem with _$AllocationTemplateItem {
  const factory AllocationTemplateItem({
    required int id,
    required int templateId,
    required int categoryId,
    required double allocatedAmount,
    required BucketType bucketType,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? categoryName, // Optional, for display purposes
  }) = _AllocationTemplateItem;

  const AllocationTemplateItem._();

  factory AllocationTemplateItem.fromJson(Map<String, dynamic> json) =>
      _$AllocationTemplateItemFromJson(json);
}
