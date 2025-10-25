.PHONY: ios android web build-ios build-android build-web clean test format lint ci help

# Run on iOS simulator
ios:
	flutter run -d ios

# Run on Android emulator
android:
	flutter run -d android

# Run on web (Chrome) with WASM on fixed port for localStorage persistence
web:
	flutter run -d chrome --wasm --web-hostname localhost --web-port 5050

# Build iOS release
build-ios:
	flutter build ios --release

# Build Android APK
build-android:
	flutter build apk --release

# Build web with WASM
build-web:
	flutter build web --wasm

# Run all tests
test:
	flutter test

# --- Local CI/CD Targets ---

# Format all Dart files in the project
format:
	@echo "Formatting code..."
	@dart format .
	@echo "Code formatted."

# Run the linter/static analyzer
lint:
	@echo "Analyzing code..."
	@flutter analyze
	@echo "Linter passed."

# Run all CI checks: format, lint, and test
ci: format lint test
	@echo "All CI checks passed successfully!"

# --- Clean Targets ---

# Clean all build artifacts
clean:
	flutter clean

# Display available commands
help:
	@echo "Available targets:"
	@echo "  make ios           - Run app on iOS simulator"
	@echo "  make android       - Run app on Android emulator"
	@echo "  make web           - Run app on Chrome browser with WASM (localhost:5050)"
	@echo "  make build-ios     - Build iOS release"
	@echo "  make build-android - Build Android APK release"
	@echo "  make build-web     - Build web release with WASM"
	@echo "  make test          - Run all tests"
	@echo "  --- CI/CD ---"
	@echo "  make format        - Format all Dart code"
	@echo "  make lint          - Run static analysis linter"
	@echo "  make ci            - Run all local CI checks (format, lint, test)"
	@echo "  ---"
	@echo "  make clean         - Clean all build artifacts"
	@echo "  make help          - Display this help message"
