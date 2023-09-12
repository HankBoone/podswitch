import 'package:auto_updater/auto_updater.dart';

class AutoUpdater {
  initUpdate() async {
    String feedURL = 'https://hankboone.github.io/podswitch/appcast.xml';
    await autoUpdater.setFeedURL(feedURL);
    await autoUpdater.checkForUpdates(
      inBackground: true,
    );
    await autoUpdater.setScheduledCheckInterval(3600);
  }
}
