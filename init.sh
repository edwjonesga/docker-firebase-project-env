#!/bin/bash

echo "Welcome to the Firebase Project Initializer!"
echo "This script will guide you through setting up a new Firebase project."
echo ""

# Login to Firebase
echo "First, let's log in to Firebase."
firebase login --no-localhost

# Initialize Firebase
echo ""
echo "Now, let's initialize your Firebase project."
echo "Please follow the prompts from the Firebase CLI."
echo ""
firebase init

# Configure emulator hosts to be accessible outside the container
if [ -f "firebase.json" ]; then
    echo "Configuring emulator hosts in firebase.json to use 0.0.0.0 for external access..."
    # Use jq to add or update the host for every emulator defined.
    # This ensures the emulators are accessible from the host machine.
    if command -v jq &> /dev/null
    then
        # This command robustly modifies the firebase.json file.
        # It iterates over all values in the .emulators object.
        # If a value is an object (i.e., a configurable emulator), it adds/updates its host.
        # If a value is not an object (e.g., "ui": true), it is ignored.
        jq 'if .emulators then .emulators |= map_values(if type == "object" then . + {"host": "0.0.0.0"} else . end) else . end' firebase.json > firebase.json.tmp && mv firebase.json.tmp firebase.json
    else
        echo "Warning: jq is not installed. Cannot configure emulator hosts automatically."
    fi
fi

# Completion message
echo ""
echo "Firebase project initialization is complete!"
echo ""

# Check for flags
if [[ "$1" == "--preact" ]]
then
    ./init-preact.sh
elif [[ "$1" == "--flutter" ]]
then
    ./init-flutter.sh
fi

echo ""
echo "Generating helper scripts..."

# Create build.sh
cat > build.sh <<'EOF'
#!/bin/bash
# This script builds the frontend application(s).

# Clear the public directory
rm -rf public/*

# Build Preact app if it exists
if [ -d "preact-app" ]; then
  echo "Building Preact app..."
  (cd preact-app && npm install && npm run build)
  echo "Preact build complete. The output is in the 'public' directory."
fi

# Build Flutter app if it exists
if [ -d "flutter_app" ]; then
  echo "Building Flutter app..."
  (cd flutter_app && flutter build web)
  # Copy the Flutter web build to the public directory
  cp -r flutter_app/build/web/* public/
  echo "Flutter build complete. The output has been copied to the 'public' directory."
fi
EOF
chmod +x build.sh

# Create run.sh
cat > run.sh <<'EOF'
#!/bin/bash
# This script starts the Firebase emulators.
echo "Starting Firebase emulators..."
firebase emulators:start
EOF
chmod +x run.sh

# Create deploy.sh
cat > deploy.sh <<'EOF'
#!/bin/bash
# This script builds the frontend and deploys to Firebase.

# Prompt for the project to deploy to
read -p "Enter the Firebase project ID to deploy to: " project_id
if [ -z "$project_id" ]; then
  echo "Project ID cannot be empty."
  exit 1
fi

echo "Building the frontend app first..."
./build.sh

echo "Deploying to Firebase project: $project_id"
firebase deploy --only functions,hosting --project $project_id
EOF
chmod +x deploy.sh

echo "Helper scripts created successfully."

echo ""
echo "You can now use the Firebase CLI and the generated scripts to manage your project."
echo "For example, run './run.sh' to start the emulators."
echo "Or run './deploy.sh' to deploy your project."
echo ""
echo "Happy coding!"
