// import 'dart:convert';
//
// import 'package:http/http.dart' as http;
// import 'package:project/api/models/team/teamModel.dart';
//
// class TeamService {
//   final String baseUrl = 'http://localhost:8080/users';
//
//   Future<List<Team>> fetchTeamByProjectId(String projectId) async {
//     final url = Uri.parse('$baseUrl/team/project/$projectId');
//     final response = await http.get(url);
//
//     if (response.statusCode == 200) {
//       final jsonData = json.decode(response.body);
//       // Lấy danh sách các team từ JSON
//       List<Team> teams = (jsonData['data'] as List)
//           .map((teamJson) => Team.fromJson(teamJson))
//           .toList();
//       return teams;
//     } else {
//       print('Error: ${response.statusCode}');
//       return [];
//     }
//   }
// }
