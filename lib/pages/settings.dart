import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isGuest = true;
  String language = "English";
  bool chargingNotification = true;
  bool vibration = true;

  final List<String> languages = [
    "English",
    "Spanish",
    "Mandarin",
    "Arabic",
    "Portuguese",
    "Russian",
    "Japanese",
    "German",
  ];

  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  // ================= LOAD =================
  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      isGuest = prefs.getBool("isGuest") ?? true;
      language = prefs.getString("language") ?? "English";
      chargingNotification =
          prefs.getBool("chargingNotification") ?? true;
      vibration = prefs.getBool("vibration") ?? true;
    });
  }

  // ================= SAVE =================
  Future<void> saveSettings() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool("isGuest", isGuest);
    await prefs.setString("language", language);
    await prefs.setBool("chargingNotification", chargingNotification);
    await prefs.setBool("vibration", vibration);
  }

  // ================= ACTIONS =================
  void logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("isGuest");

    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  void deleteAccount() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  void resetBackpack() async {
    setState(() {
      chargingNotification = true;
      vibration = true;
    });

    await saveSettings();

    if (!mounted) return;
    Navigator.pop(context);
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Settings",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 20),

            // ACCOUNT
            buildSection(
              "Account",
              Column(
                children: [
                  buildRow("Status", isGuest ? "Guest" : "Logged In"),
                  const SizedBox(height: 10),
                  buildButton("Log Out", Colors.red, logout),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // APP SETTINGS
            buildSection(
              "App Settings",
              buildRow("Language", language,
                  onTap: showLanguageDialog),
            ),

            const SizedBox(height: 16),

            // BACKPACK SETTINGS
            buildSection(
              "Backpack Settings",
              Column(
                children: [
                  buildSwitch("Charging Notification",
                      chargingNotification, (val) async {
                    setState(() => chargingNotification = val);
                    await saveSettings();
                  }),

                  buildSwitch("Vibration", vibration, (val) async {
                    setState(() => vibration = val);
                    await saveSettings();
                  }),

                  const SizedBox(height: 10),

                  buildButton(
                    "Reset Backpack System",
                    Colors.orange,
                    showResetDialog,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // DANGER ZONE
            buildSection(
              "Danger Zone",
              buildButton(
                "Delete Account & Data",
                Colors.red,
                showDeleteDialog,
              ),
              titleColor: Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  // ================= WIDGET HELPERS =================
  Widget buildSection(String title, Widget child,
      {Color titleColor = Colors.white}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: titleColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget buildRow(String title, String value,
      {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF334155),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title,
                style: const TextStyle(color: Colors.white)),
            Row(
              children: [
                Text(value,
                    style: const TextStyle(color: Colors.grey)),
                if (onTap != null)
                  const Icon(Icons.chevron_right,
                      color: Colors.grey),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSwitch(
      String title, bool value, Function(bool) onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF334155),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: const TextStyle(color: Colors.white)),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget buildButton(
      String text, Color color, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(text),
      ),
    );
  }

  // ================= DIALOGS =================
    void showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          title: const Text(
            "Select Language",
            style: TextStyle(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: languages.map((lang) {
                return ListTile(
                  title: Text(
                    lang,
                    style: const TextStyle(color: Colors.white),
                  ),
                  onTap: () async {
                    setState(() => language = lang);
                    await saveSettings();

                    if (!context.mounted) return;
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  void showDeleteDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text("Delete Account",
            style: TextStyle(color: Colors.red)),
        content: const Text("This cannot be undone.",
            style: TextStyle(color: Colors.white)),
        actions: [
          TextButton(
              onPressed: deleteAccount,
              child: const Text("Delete")),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
        ],
      ),
    );
  }

  void showResetDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text("Reset Backpack",
            style: TextStyle(color: Colors.orange)),
        content: const Text("Reset all settings?",
            style: TextStyle(color: Colors.white)),
        actions: [
          TextButton(
              onPressed: resetBackpack,
              child: const Text("Reset")),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
        ],
      ),
    );
  }
}