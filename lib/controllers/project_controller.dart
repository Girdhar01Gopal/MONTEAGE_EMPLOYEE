import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import '../models/project_model.dart';

class ProjectController extends GetxController {
  final box = GetStorage();

  final isLoading = true.obs;
  final allProjects = <ProjectModel>[].obs;
  final selectedFilter = 'All'.obs;
  final searchQuery = ''.obs;
  final isSearchExpanded = false.obs;

  // ── Role check ────────────────────────────────────────────────────────
  // Change this to match how you store role after login
  String get userRole {
    final raw = (box.read('Designation') ?? box.read('designation') ?? '').toString();
    return raw.toLowerCase();
  }

  bool get isManager => userRole == 'project manager';

  // ── API ───────────────────────────────────────────────────────────────
  final String projectsApi =
      'https://montempep.eduagentapp.com/api/MonteageEmpErp/AppPMAssignProjectList/4';

  String get _accessToken =>
      (box.read('access_token') ?? '').toString().trim();

  @override
  void onInit() {
    super.onInit();
    fetchProjects();
  }

  Future<void> fetchProjects() async {
    try{
      isLoading(true);

      final res = await http.get(
        Uri.parse('https://montempep.eduagentapp.com/api/MonteageEmpErp/AppPMAssignProjectList/4'),
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Accept': 'application/json',
        },
      );

      debugPrint('Projects API Response: ${res.statusCode}');
      debugPrint('Projects API Body: ${res.body}');

      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        final list = decoded['data'] as List?;
        if (list != null) {
          allProjects.value = list
      .map<ProjectModel>((e) => ProjectModel.fromJson(e))
      .toList();
          debugPrint('Loaded ${allProjects.length} projects');
        } else {
          Get.snackbar('Error', 'No projects data found',
              snackPosition: SnackPosition.BOTTOM);
        }
      }
        else {
          Get.snackbar('Error', 'Failed to load projects: ${res.statusCode}',
              snackPosition: SnackPosition.BOTTOM);
        }
    } catch (e) {
      debugPrint('Projects API Error: $e');
      Get.snackbar('Error', 'Failed to load projects: $e',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading(false);
    }
  }

  // ── Filtered projects ─────────────────────────────────────────────────
  List<ProjectModel> get filteredProjects {
    var list = allProjects.toList();

    if (selectedFilter.value != 'All') {
      list = list
          .where((p) => p.projectStatus == selectedFilter.value)
          .toList();
    }

    final q = searchQuery.value.toLowerCase().trim();
    if (q.isNotEmpty) {
      list = list
          .where((p) =>
              p.projectName.toLowerCase().contains(q) ||
              p.clientName.toLowerCase().contains(q))
          .toList();
    }

    return list;
  }

  // ── Stats ─────────────────────────────────────────────────────────────
  int get totalCount => allProjects.length;
  int get runningCount =>
      allProjects.where((p) => p.projectStatus == 'Running').length;
  int get completedCount =>
      allProjects.where((p) => p.projectStatus == 'Complete').length;
  int get onHoldCount =>
      allProjects.where((p) => p.projectStatus == 'On Hold').length;

  void setFilter(String f) => selectedFilter.value = f;
  void setSearch(String q) => searchQuery.value = q;
  void toggleSearch() => isSearchExpanded.toggle();
}


