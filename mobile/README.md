# Run Dhahabu on a physical Android device

1. Connect the phone and development computer to the same Wi-Fi network.
2. Start Django from `backend` with `python manage.py runserver 0.0.0.0:8000`.
3. From this directory, run `./run-on-device.ps1`. It detects the computer's LAN IP and configures Flutter's API URL automatically.

If the wrong network adapter is selected, pass the computer's Wi-Fi IPv4 address, for example `./run-on-device.ps1 -ApiHost 192.168.1.20`.

The Android app includes internet permission and permits HTTP for local development. For an Android emulator, use `flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000/api` instead. The phone and computer must stay on the same network; Windows Firewall must allow Python on private networks.
