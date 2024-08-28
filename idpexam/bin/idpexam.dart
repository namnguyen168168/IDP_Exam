import 'package:idpexam/idpexam.dart' as idpexam;
import 'dart:convert';
import 'dart:io';

class Student {
  String id;
  String name;
  List<Course> courses;

  Student({required this.id, required this.name, required this.courses});

  factory Student.fromJson(Map<String, dynamic> json) {
    var list = json['courses'] as List;
    List<Course> courseList = list.map((i) => Course.fromJson(i)).toList();

    return Student(
      id: json['id'],
      name: json['name'],
      courses: courseList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'courses': courses.map((course) => course.toJson()).toList(),
    };
  }
}

class Course {
  String courseName;
  List<String> grades;

  Course({required this.courseName, required this.grades});

  factory Course.fromJson(Map<String, dynamic> json) {
    var list = json['grades'] as List;
    List<String> gradesList = list.map((i) => i.toString()).toList();

    return Course(
      courseName: json['course_name'],
      grades: gradesList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'course_name': courseName,
      'grades': grades,
    };
  }
}
Future<List<Student>> loadStudents() async {
  final file = File('Student.json');
  final contents = await file.readAsString();
  final jsonData = jsonDecode(contents) as List;
  return jsonData.map((e) => Student.fromJson(e)).toList();
}

Future<void> saveStudents(List<Student> students) async {
  final file = File('Student.json');
  final jsonData = students.map((e) => e.toJson()).toList();
  await file.writeAsString(jsonEncode(jsonData));
}
Future<void> displayAllStudents() async {
  final students = await loadStudents();
  for (var student in students) {
    print('ID: ${student.id}, Name: ${student.name}');
    for (var course in student.courses) {
      print('  Course: ${course.courseName}, Grades: ${course.grades}');
    }
  }
}

Future<void> addStudent(Student newStudent) async {
  final students = await loadStudents();
  students.add(newStudent);
  await saveStudents(students);
}

Future<void> updateStudent(String id, Student updatedStudent) async {
  final students = await loadStudents();
  final index = students.indexWhere((s) => s.id == id);
  if (index != -1) {
    students[index] = updatedStudent;
    await saveStudents(students);
  }
}

Future<Student> searchStudentById(String id) async {
  final students = await loadStudents();
  return students.firstWhere((s) => s.id == id);
}

Future<Student> searchStudentByName(String name) async {
  final students = await loadStudents();
  return students.firstWhere((s) => s.name.toLowerCase() == name.toLowerCase());
}




void main() async {
  while (true) {
    print('1. Display all students');
    print('2. Add student');
    print('3. Update student');
    print('4. Search student by ID');
    print('5. Search student by Name');
    print('0. Exit');
    stdout.write('Choose an option: ');

    final choice = stdin.readLineSync();
    switch (choice) {
      case '1':
        await displayAllStudents();
        break;
      case '2':
        stdout.write('Enter ID: ');
        final id = stdin.readLineSync()!;
        stdout.write('Enter Name: ');
        final name = stdin.readLineSync()!;
        // Add more fields if necessary
        final newStudent = Student(id: id, name: name, courses: []);
        await addStudent(newStudent);
        print('Student added.');
        break;
      case '3':
        stdout.write('Enter ID of the student to update: ');
        final id = stdin.readLineSync()!;
        final student = await searchStudentById(id);
        if (student != null) {
          stdout.write('Enter new Name: ');
          final newName = stdin.readLineSync()!;
          student.name = newName;
          // Update more fields if necessary
          await updateStudent(id, student);
          print('Student updated.');
        } else {
          print('Student not found.');
        }
        break;
      case '4':
        stdout.write('Enter ID: ');
        final id = stdin.readLineSync()!;
        final student = await searchStudentById(id);
        if (student != null) {
          print('ID: ${student.id}, Name: ${student.name}');
          for (var course in student.courses) {
            print('  Course: ${course.courseName}, Grades: ${course.grades}');
          }
        } else {
          print('Student not found.');
        }
        break;
      case '5':
        stdout.write('Enter Name: ');
        final name = stdin.readLineSync()!;
        final student = await searchStudentByName(name);
        if (student != null) {
          print('ID: ${student.id}, Name: ${student.name}');
          for (var course in student.courses) {
            print('  Course: ${course.courseName}, Grades: ${course.grades}');
          }
        } else {
          print('Student not found.');
        }
        break;
      case '0':
        exit(0);
      default:
        print('Invalid option, please try again.');
    }
  }
}
