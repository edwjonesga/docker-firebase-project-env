#!/bin/bash

echo "Setting up Flutter application..."

# Define the root directory
ROOT_DIR=$(pwd)

# Check for firebase.json
if [ ! -f "$ROOT_DIR/firebase.json" ]; then
    echo "firebase.json not found. Please make sure you initialized Firebase correctly."
    exit 1
fi

# Check for hosting configuration
if ! grep -q '"hosting"' "$ROOT_DIR/firebase.json"; then
    echo "No hosting configuration found in firebase.json. Initializing now..."
    firebase init hosting
fi

# Create a new Flutter project
echo "Creating Flutter project in 'flutter_app' directory..."
flutter create flutter_app

# Navigate into the project directory to add the fireflutter dependency
cd flutter_app

# Add the fireflutter dependency
echo "Adding fireflutter dependency..."
flutter pub add fireflutter

# Go back to the root directory
cd "$ROOT_DIR"

# Configure firebase.json to use the 'public' directory for hosting
echo "Configuring firebase.json to use 'public' directory for hosting..."
if command -v jq &> /dev/null
then
    jq '.hosting.public = "public"' "$ROOT_DIR/firebase.json" > "$ROOT_DIR/firebase.json.tmp" && mv "$ROOT_DIR/firebase.json.tmp" "$ROOT_DIR/firebase.json"
else
    echo "Warning: jq is not installed. Cannot configure hosting directory automatically."
fi

# Create run-flutter.sh
echo "Creating run-flutter.sh..."
cat > "$ROOT_DIR/run-flutter.sh" <<'EOF'
#!/bin/bash
# This script starts the Firebase emulators and the Flutter dev server.
echo "Starting Firebase emulators in the background..."
firebase emulators:start --non-interactive &
EMULATOR_PID=$!

if [ -d "flutter_app" ]; then
  echo "Starting Flutter dev server..."
  (cd flutter_app && flutter run -d chrome)
else
  echo "flutter_app directory not found."
fi

# Kill the emulators when the script exits
kill $EMULATOR_PID
EOF
chmod +x "$ROOT_DIR/run-flutter.sh"

echo ""
echo "Flutter application setup complete!"
echo "You can run './run-flutter.sh' to start the dev server."
echo "Run './build.sh' to build your app for production."
