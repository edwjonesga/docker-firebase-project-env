#!/bin/bash

echo "Setting up Preact application..."

# Check for firebase.json
if [ ! -f "firebase.json" ]; then
    echo "firebase.json not found. Please make sure you initialized Firebase correctly."
    exit 1
fi

# Check for hosting configuration
if ! grep -q '"hosting"' firebase.json; then
    echo "No hosting configuration found in firebase.json. Initializing now..."
    firebase init hosting
fi

# Create preact-app directory
echo "Creating preact-app directory..."
mkdir preact-app
cd preact-app

# Initialize Vite Preact project
echo "Initializing Vite + Preact project..."
npm create vite@latest . -- --template preact

# Install dependencies
echo "Installing dependencies..."
npm install

# Install Firebase SDK and save it to package.json
echo "Installing Firebase SDK..."
npm install firebase --save

# Create vite.config.js
echo "Creating vite.config.js..."
cat > vite.config.js <<'EOF'
import { defineConfig } from 'vite'
import preact from '@preact/preset-vite'

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [preact()],
  build: {
    outDir: '../public',
    emptyOutDir: true,
    rollupOptions: {
        output: {
            entryFileNames: 'bundle.js',
            assetFileNames: 'assets/[name].[ext]'
        }
    }
  }
})
EOF

# Create firebase.js
echo "Creating src/firebase.js with emulator support..."
cat > src/firebase.js <<'EOF'
import { initializeApp } from "firebase/app";
import { getFirestore, connectFirestoreEmulator } from "firebase/firestore";
import { getFunctions, connectFunctionsEmulator } from "firebase/functions";
import { getAuth, connectAuthEmulator } from "firebase/auth";

// TODO: Replace with your web app's Firebase configuration.
// You can get this from the Firebase console, or by running:
// firebase apps:sdkconfig WEB <your-app-id>
const firebaseConfig = {
  apiKey: "your-api-key",
  authDomain: "your-auth-domain",
  projectId: "your-project-id",
  storageBucket: "your-storage-bucket",
  messagingSenderId: "your-messaging-sender-id",
  appId: "your-app-id"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);
const db = getFirestore(app);
const functions = getFunctions(app);
const auth = getAuth(app);

// Connect to emulators if running locally
if (window.location.hostname === "localhost") {
  console.log("Development mode: Connecting to local Firebase emulators...");
  connectFirestoreEmulator(db, 'localhost', 8080);
  connectFunctionsEmulator(functions, 'localhost', 5001);
  connectAuthEmulator(auth, 'http://localhost:9099');
} else {
  console.log("Production mode: Connecting to live Firebase services.");
}

export { app, db, functions, auth };
EOF

# Import firebase.js into main.jsx
echo "Importing firebase.js into src/main.jsx..."
echo "import './firebase.js';" | cat - src/main.jsx > temp && mv temp src/main.jsx

echo "Preact application setup complete!"
echo "You can run 'npm run dev' in the 'preact-app' directory to start the dev server."
echo "Run 'npm run build' to build your app for production."
cd ..

# Configure firebase.json to use the public directory for hosting
echo "Configuring firebase.json to use 'public' directory for hosting..."
if command -v jq &> /dev/null
then
    jq '.hosting.public = "public"' firebase.json > firebase.json.tmp && mv firebase.json.tmp firebase.json
else
    echo "Warning: jq is not installed. Cannot configure hosting directory automatically."
fi
