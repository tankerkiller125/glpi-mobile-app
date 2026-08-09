# Use flutter from PATH, falling back to the local SDK install.
FLUTTER ?= $(shell command -v flutter 2>/dev/null || echo $(HOME)/sdk/flutter/bin/flutter)

.PHONY: check format analyze test l10n run-dev apk

check: format analyze test

format:
	dart format --set-exit-if-changed lib test

analyze:
	$(FLUTTER) analyze

test:
	$(FLUTTER) test

l10n:
	$(FLUTTER) gen-l10n

# Run against the dev-env GLPI from an Android emulator (10.0.2.2 = host).
# Auth is by QR pairing (My Settings > Mobile app); no client id/secret needed.
run-dev:
	$(FLUTTER) run --dart-define=DEV_SERVER=http://10.0.2.2:8081

# Run as a Linux desktop app (needs: apt install clang cmake ninja-build libgtk-3-dev).
run-linux:
	$(FLUTTER) run -d linux --dart-define=DEV_SERVER=http://localhost:8081

# Run on a USB-attached phone: the device must reach this machine over LAN.
run-device:
	$(FLUTTER) run --dart-define=DEV_SERVER=http://$$(hostname -I | awk '{print $$1}'):8081

apk:
	$(FLUTTER) build apk --debug
