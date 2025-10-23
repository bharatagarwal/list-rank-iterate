.PHONY: ios android web clean clean-ios clean-android clean-web test help

# Run on iOS simulator
ios:
	flutter run -d ios

# Run on Android emulator
android:
	flutter run -d android

# Run on web (Chrome)
web:
	flutter run -d chrome

# Run all tests
test:
	flutter test

# Clean all build artifacts
clean:
	flutter clean

# Clean iOS-specific build artifacts
clean-ios:
	rm -rf ios/build
	rm -rf ios/Pods
	rm -rf ios/.symlinks
	rm -rf ios/Flutter/Flutter.framework
	rm -rf ios/Flutter/Flutter.podspec

# Clean Android-specific build artifacts
clean-android:
	rm -rf android/build
	rm -rf android/app/build
	rm -rf android/.gradle

# Clean web-specific build artifacts
clean-web:
	rm -rf build/web

# Display available commands
help:
	@echo "Available targets:"
	@echo "  make ios           - Run app on iOS simulator"
	@echo "  make android       - Run app on Android emulator"
	@echo "  make web           - Run app on Chrome browser"
	@echo "  make test          - Run all tests"
	@echo "  make clean         - Clean all build artifacts"
	@echo "  make clean-ios     - Clean iOS-specific build artifacts"
	@echo "  make clean-android - Clean Android-specific build artifacts"
	@echo "  make clean-web     - Clean web-specific build artifacts"
	@echo "  make help          - Display this help message"
