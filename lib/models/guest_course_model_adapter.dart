import 'package:hive/hive.dart';
import 'guest_course_model.dart';

class GuestCourseModelAdapter extends TypeAdapter<GuestCourseModel> {
  @override
  final int typeId = 0;

  @override
  GuestCourseModel read(BinaryReader reader) {
    return GuestCourseModel(
      id: reader.readString(),
      name: reader.readString(),
      creditHours: reader.readInt(),
      grade: reader.readString(),
      gradePoint: reader.readDouble(),
    );
  }

  @override
  void write(BinaryWriter writer, GuestCourseModel obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.name);
    writer.writeInt(obj.creditHours);
    writer.writeString(obj.grade);
    writer.writeDouble(obj.gradePoint);
  }
}
