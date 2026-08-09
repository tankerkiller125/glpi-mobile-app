/// Connection settings for the live tests (`flutter test --run-skipped -t live`).
///
/// The defaults point at the disposable Docker dev instance this app was built
/// against — a throwaway GLPI on localhost whose admin password is `glpi` and
/// whose OAuth client secret is a fixed dev string. **They are worthless
/// anywhere else, and nothing resembling them should ever reach a real
/// server.** They live here, in one file, rather than being scattered through
/// four test files.
///
/// Point the tests at your own instance without editing anything:
///
/// ```sh
/// flutter test --run-skipped -t live \
///   --dart-define=GLPI_TEST_SERVER=https://glpi.example.com \
///   --dart-define=GLPI_TEST_CLIENT_ID=… \
///   --dart-define=GLPI_TEST_CLIENT_SECRET=… \
///   --dart-define=GLPI_TEST_USER=… \
///   --dart-define=GLPI_TEST_PASSWORD=…
/// ```
///
/// The client id/secret are for a `password`-grant OAuth client used only by
/// these tests. The app itself never uses one: it pairs by QR and holds no
/// secret (see `lib/core/auth/`).
library;

const liveServer = String.fromEnvironment(
  'GLPI_TEST_SERVER',
  defaultValue: 'http://localhost:8081',
);

const liveClientId = String.fromEnvironment(
  'GLPI_TEST_CLIENT_ID',
  defaultValue: 'glpi-mobile-dev-client',
);

const liveClientSecret = String.fromEnvironment(
  'GLPI_TEST_CLIENT_SECRET',
  defaultValue: 'glpi-mobile-dev-secret-0123456789abcdef',
);

const liveUsername = String.fromEnvironment(
  'GLPI_TEST_USER',
  defaultValue: 'glpi',
);

const livePassword = String.fromEnvironment(
  'GLPI_TEST_PASSWORD',
  defaultValue: 'glpi',
);
