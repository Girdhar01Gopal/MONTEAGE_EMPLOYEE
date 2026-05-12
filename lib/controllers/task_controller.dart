import 'package:get/get.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;




// ─────────────────────────────────────────────────────────────────────────
// MODELS
// ─────────────────────────────────────────────────────────────────────────

class EmployeeModel {
  final int employeeId;
  final String employeeName;
  final String employeeCode;
  String projectId;
  String projectName;
  final String name;
  final bool isTeamLead;
  final String? teamLeadId;
  final List<EmployeeModel> juniors;

  EmployeeModel({
    required this.employeeId,
    required this.employeeName,
    required this.employeeCode,
    required this.projectId,
    required this.projectName,
    required this.name,
    required this.isTeamLead,
    this.teamLeadId,
    this.juniors = const [],
  });

 factory EmployeeModel.fromJson(Map<String, dynamic> j) => EmployeeModel(
        employeeId: j['EmployeeId'] as int,
        employeeName: j['EmployeeName'] ?? '',
        employeeCode: j['EmployeeCode'] ?? '',
        projectId: '',
        projectName: '',
        name: j['EmployeeName'] ?? '',
        isTeamLead: false,
        teamLeadId: null,
        juniors: const [],
      );
}

class RemarkModel {
  final String rejectedBy;
  final String remark;
  final String rejectedAt;

  RemarkModel({
    required this.rejectedBy,
    required this.remark,
    required this.rejectedAt,
  });

  factory RemarkModel.fromJson(Map<String, dynamic> j) => RemarkModel(
        rejectedBy: j['rejected_by'] ?? '',
        remark: j['remark'] ?? '',
        rejectedAt: j['rejected_at'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'rejected_by': rejectedBy,
        'remark': remark,
        'rejected_at': rejectedAt,
      };
}

class TaskModel {
  final String id;
  final String title;
  final String description;
  final String startDate;
  final String dueDate;
  final String priority;   // High | Medium | Low
  final String recurrence; // Daily | Weekly | Alternate | Monthly

  final String assignedById;
  final String assignedByName;
  final String teamLeadId;
  final String teamLeadName;
  final String? juniorId;
  final String? juniorName;

  // Status flow:
  // Pending → AwaitingLeadApproval → AwaitingAssignerApproval → Approved
  //                                ↘ LeadRejected
  //                                                           ↘ AssignerRejected
  final String overallStatus;
  final RemarkModel? leadRemark;
  final RemarkModel? assignerRemark;
  final bool isOverdue;
  final String? projectId;
  final String? projectName;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.startDate,
    required this.dueDate,
    required this.priority,
    required this.recurrence,
    required this.assignedById,
    required this.assignedByName,
    required this.teamLeadId,
    required this.teamLeadName,
    this.juniorId,
    this.juniorName,
    required this.overallStatus,
    this.leadRemark,
    this.assignerRemark,
    this.isOverdue = false,
    this.projectId,
    this.projectName,
  });

  factory TaskModel.fromJson(Map<String, dynamic> j) {
    final due = j['due_date'] ?? '';
    final status = j['overall_status'] ?? 'Pending';
    bool overdue = false;
    try {
      if (status != 'Approved') {
        overdue = DateTime.now().isAfter(DateTime.parse(due));
      }
    } catch (_) {}

    return TaskModel(
      id: j['id']?.toString() ?? '',
      title: j['title'] ?? '',
      description: j['description'] ?? '',
      startDate: j['start_date'] ?? '',

      dueDate: due,
      priority: j['priority'] ?? 'Medium',
      recurrence: j['recurrence'] ?? 'None',
      assignedById: j['assigned_by_id']?.toString() ?? '',
      assignedByName: j['assigned_by_name'] ?? '',
      teamLeadId: j['team_lead_id']?.toString() ?? '',
      teamLeadName: j['team_lead_name'] ?? '',
      juniorId: j['junior_id']?.toString(),
      juniorName: j['junior_name'],
      overallStatus: status,
      leadRemark: j['lead_remark'] != null
          ? RemarkModel.fromJson(j['lead_remark'])
          : null,
      assignerRemark: j['assigner_remark'] != null
          ? RemarkModel.fromJson(j['assigner_remark'])
          : null,
      isOverdue: overdue,
    );
  }

  TaskModel copyWith({
    String? overallStatus,
    RemarkModel? leadRemark,
    RemarkModel? assignerRemark,
    String? projectId,        
    String? projectName,
  }) =>
      TaskModel(
        id: id,
        title: title,
        description: description,
        startDate: startDate,
        dueDate: dueDate,
        priority: priority,
        recurrence: recurrence,
        assignedById: assignedById,
        assignedByName: assignedByName,
        teamLeadId: teamLeadId,
        teamLeadName: teamLeadName,
        juniorId: juniorId,
        juniorName: juniorName,
        overallStatus: overallStatus ?? this.overallStatus,
        leadRemark: leadRemark ?? this.leadRemark,
        assignerRemark: assignerRemark ?? this.assignerRemark,
        isOverdue: isOverdue,
        projectId: projectId ?? this.projectId,       
        projectName: projectName ?? this.projectName,
      );
}



// ─────────────────────────────────────────────────────────────────────────
// CONTROLLER
// ─────────────────────────────────────────────────────────────────────────

class TaskController extends GetxController {
  // ── Observable state ─────────────────────────────────────────────────────
  var isLoading        = true.obs;
  var activeTab        = 0.obs;        // 0 = Given  |  1 = Received
  var searchQuery      = ''.obs;
  var selectedFilter   = 'All'.obs;   // All | Pending | Approved | Overdue | Rejected
  var isSearchExpanded = false.obs;

  var allTasks  = <TaskModel>[].obs;
  var employees = <EmployeeModel>[].obs;

  static const String _apiBase =
      'https://montempep.eduagentapp.com/api/MonteageEmpErp';
  static const String _employeeBindingUrl = '$_apiBase/Appbindemployee';
  static const String _taskApiBase = '$_apiBase/AppTask'; // TODO: update once the task API endpoint is available

  // Logged-in user id — swap with your AuthController value
 final String _myId = "";
String get myId => _myId;

  // ── Derived lists ─────────────────────────────────────────────────────────

  List<TaskModel> get givenTasks =>
      allTasks.where((t) => t.assignedById == myId).toList();

  List<TaskModel> get receivedTasks => allTasks
      .where((t) =>
          t.assignedById != myId &&
          (t.juniorId == myId || t.teamLeadId == myId))
      .toList();

  List<TaskModel> get _activeTasks =>
      activeTab.value == 0 ? givenTasks : receivedTasks;

  List<TaskModel> get filteredTasks {
    var list = _activeTasks;

    // Filter chip
    switch (selectedFilter.value) {
      case 'Overdue':
        list = list.where((t) => t.isOverdue).toList();
        break;
      case 'Rejected':
        list = list
            .where((t) =>
                t.overallStatus == 'LeadRejected' ||
                t.overallStatus == 'AssignerRejected')
            .toList();
        break;
      case 'All':
        break;
      default:
        list = list.where((t) => t.overallStatus == selectedFilter.value).toList();
    }

    // Search by title or date
    final q = searchQuery.value.toLowerCase().trim();
    if (q.isNotEmpty) {
      list = list
          .where((t) =>
              t.title.toLowerCase().contains(q) || t.dueDate.contains(q))
          .toList();
    }

    return list;
  }

  // ── Stats ─────────────────────────────────────────────────────────────────
  int get totalCount    => _activeTasks.length;
  int get activeCount   => _activeTasks.where((t) => t.overallStatus != 'Pending' && t.overallStatus != 'Approved' && t.overallStatus != 'LeadRejected' && t.overallStatus != 'AssignerRejected').length;
  int get pendingCount  => _activeTasks.where((t) => t.overallStatus == 'Pending').length;
  int get approvedCount => _activeTasks.where((t) => t.overallStatus == 'Approved').length;
  int get overdueCount  => _activeTasks.where((t) => t.isOverdue).length;

  // ── Employee helpers ──────────────────────────────────────────────────────
  List<EmployeeModel> get teamLeads =>
      employees.where((e) => e.isTeamLead).toList();

  List<EmployeeModel> juniorsOf(String teamLeadId) =>
      employees.where((e) => e.employeeId.toString() != teamLeadId).toList();

  // ── Approval visibility ───────────────────────────────────────────────────
  bool canLeadApprove(TaskModel t) =>
      t.teamLeadId == myId && t.overallStatus == 'AwaitingLeadApproval';

  bool canAssignerApprove(TaskModel t) =>
      t.assignedById == myId && t.overallStatus == 'AwaitingAssignerApproval';

  bool canMarkDone(TaskModel t) =>
      t.juniorId == myId && t.overallStatus == 'Pending';

  // ── Lifecycle ─────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    fetchAll();
  }

  // ── API calls ─────────────────────────────────────────────────────────────

  /// Employee binding API.
  Future<void> fetchAll() async {
    try {
      isLoading(true);

      final response = await http.get(
        Uri.parse(_employeeBindingUrl),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode != 200) {
        throw Exception('Server error: ${response.statusCode}');
      }

      final jsonData = jsonDecode(response.body);
      employees.value = List<EmployeeModel>.from(
        (jsonData['data'] as List).map(
          (e) => EmployeeModel.fromJson(e),
        ),
      );

      // No dedicated task payload is available from the employee binding API.
      // Keep tasks empty until a proper task list endpoint is integrated.
      allTasks.clear();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load employees: $e');
    } finally {
      isLoading(false);
    }
  }

  /// Placeholder task creation. Replace with real task-submit API later.
  Future<void> assignTask({
    required List<String> teamLeadId,
    required String? juniorId,
    required String title,
    required String description,
    required String startDate,
    required String dueDate,
    required String priority,
    required String recurrence,
    String? projectId,
    String? projectName,
  }) async {
    Get.back();
    await fetchAll();
    Get.snackbar(
      'Pending',
      'Task submit API is not configured yet.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// Placeholder task update. Replace with the real endpoint once available.
  Future<void> updateTask(String taskId, Map<String, dynamic> body) async {
    Get.back();
    await fetchAll();
    Get.snackbar(
      'Pending',
      'Task update API is not configured yet.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// Placeholder delete action.
  Future<void> deleteTask(String taskId) async {
    allTasks.removeWhere((t) => t.id == taskId);
    Get.snackbar('Pending', 'Task delete API is not configured yet.',
        snackPosition: SnackPosition.BOTTOM);
  }

  /// Placeholder mark-done action.
  Future<void> markDone(String taskId) async {
    Get.snackbar('Pending', 'Mark-done API is not configured yet.',
        snackPosition: SnackPosition.BOTTOM);
  }

  /// Placeholder lead approve action.
  Future<void> leadApprove(String taskId) async {
    _patchLocal(taskId, 'AwaitingAssignerApproval');
    Get.snackbar('Pending', 'Lead approval API is not configured yet.',
        snackPosition: SnackPosition.BOTTOM);
  }

  /// Placeholder lead reject action.
  Future<void> leadReject(String taskId, String remark) async {
    _patchLocal(taskId, 'LeadRejected',
        leadRemark: RemarkModel(
            rejectedBy: 'Team Lead',
            remark: remark,
            rejectedAt: DateTime.now().toIso8601String()));
    Get.snackbar('Pending', 'Lead reject API is not configured yet.',
        snackPosition: SnackPosition.BOTTOM);
  }

  /// Placeholder assigner approve action.
  Future<void> assignerApprove(String taskId) async {
    _patchLocal(taskId, 'Approved');
    Get.snackbar('Pending', 'Assigner approval API is not configured yet.',
        snackPosition: SnackPosition.BOTTOM);
  }

  /// Placeholder assigner reject action.
  Future<void> assignerReject(String taskId, String remark) async {
    _patchLocal(taskId, 'AssignerRejected',
        assignerRemark: RemarkModel(
            rejectedBy: 'Assigner',
            remark: remark,
            rejectedAt: DateTime.now().toIso8601String()));
    Get.snackbar('Pending', 'Assigner reject API is not configured yet.',
        snackPosition: SnackPosition.BOTTOM);
  }

  // ── UI helpers ────────────────────────────────────────────────────────────
  void switchTab(int i) {
    activeTab.value      = i;
    selectedFilter.value = 'All';
    searchQuery.value    = '';
  }

  void setFilter(String f) => selectedFilter.value = f;
  void setSearch(String q) => searchQuery.value = q;
  void toggleSearch()      => isSearchExpanded.toggle();

  // ── Private ───────────────────────────────────────────────────────────────
  void _patchLocal(String taskId, String status,
      {RemarkModel? leadRemark, RemarkModel? assignerRemark}) {
    final i = allTasks.indexWhere((t) => t.id == taskId);
    if (i != -1) {
      allTasks[i] = allTasks[i].copyWith(
        overallStatus:  status,
        leadRemark:     leadRemark,
        assignerRemark: assignerRemark,
      );
      allTasks.refresh();
    }
  }
}