import 'package:auto_updater/auto_updater.dart';

class AutoUpdater {
  initUpdate() async {
    String feedURL =
        'https://raw.githubusercontent.com/HankBoone/podswitch/master/appcast/appcast.xml';
    await autoUpdater.setFeedURL(feedURL);
    await autoUpdater.checkForUpdates(
      inBackground: true,
    );
    await autoUpdater.setScheduledCheckInterval(3600);
  }
}
