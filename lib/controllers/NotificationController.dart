import 'package:get/get.dart';
import 'package:intl/intl.dart';

class NotificationController extends GetxController {
  // SHOP INFO
  var shopName = "ATTENDANCE APP".obs;
  var gstNumber = "***********".obs;
  var mobileNumber = "********".obs;

  var todayBillsCount = 0.obs;
  var todayAmount = 0.0.obs;

  // NOTIFICATION LIST
  var notifications = <Map<String, dynamic>>[].obs;
  var filteredNotifications = <Map<String, dynamic>>[].obs; // Store filtered notifications
  var isSearching = false.obs; // Track whether the user is searching

  @override
  void onInit() {
    super.onInit();
    loadNotifications();
  }



  void loadNotifications() {
    var now = DateTime.now();
    var formatter = DateFormat('dd/MM/yyyy');
    String formattedDate = formatter.format(now);

    notifications.value = [
      {
        "title": "New *********",
        "message": "************",
        "time": formattedDate,
      },
      {
        "title": "NOTIFICATION",
        "message": "************",
        "time": "09/05/2021",
      },
      {
        "title": "NOTIFICATION",
        "message": "*************",
        "time": "08/05/2021",
      },
    ];

    // Sort notifications alphabetically by title
    notifications.sort((a, b) => a['title'].compareTo(b['title']));

    filteredNotifications.value = List.from(notifications); // Initialize with all notifications
  }

  void toggleSearch() {
    isSearching.value = !isSearching.value;
    if (!isSearching.value) {
      // Reset to all notifications when search is closed
      filteredNotifications.value = List.from(notifications);
    }
  }

  void filterNotifications(String query) {
    if (query.isEmpty) {
      filteredNotifications.value = List.from(notifications);
    } else {
      filteredNotifications.value = notifications.where((notif) {
        return notif['title'].toLowerCase().contains(query.toLowerCase()) ||
            notif['message'].toLowerCase().contains(query.toLowerCase());
      }).toList();
    }
  }
}
