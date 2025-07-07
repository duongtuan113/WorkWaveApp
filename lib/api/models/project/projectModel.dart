import 'package:flutter/foundation.dart'; // Import để sử dụng @immutable

// Thêm @immutable là một thói quen tốt cho các lớp model
// để đảm bảo các thuộc tính của chúng không bị thay đổi sau khi tạo.
@immutable
class Project {
  final String projectId;
  final String name;
  final String? description;

  const Project({
    required this.projectId,
    required this.name,
    this.description,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      projectId: json['projectId'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
    );
  }

  // ✅ BƯỚC 1: Ghi đè toán tử so sánh (==)
  // DropdownButton sẽ dùng toán tử này để tìm item khớp với value.
  // Chúng ta định nghĩa rằng hai đối tượng Project là "bằng nhau"
  // nếu chúng có cùng giá trị projectId.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Project && other.projectId == projectId;
  }

  // ✅ BƯỚC 2: Ghi đè hashCode
  // Bất cứ khi nào bạn ghi đè toán tử ==, bạn cũng PHẢI ghi đè hashCode.
  // Một quy tắc tốt là dùng hashCode của các thuộc tính mà bạn đã dùng để so sánh.
  @override
  int get hashCode => projectId.hashCode;
}
