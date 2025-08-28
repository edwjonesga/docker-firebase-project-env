# Firebase Project Environment

This directory contains a Docker-based environment for quickly setting up a new Firebase project. It includes all the necessary tools and scripts to get you started in minutes.

## How to Use This Template

Instead of cloning the entire repository, you can use `git sparse-checkout` to get only this template directory.

1.  **Create a new directory for your project and navigate into it:**
    ```bash
    mkdir my-new-firebase-project
    cd my-new-firebase-project
    ```

2.  **Initialize a git repository:**
    ```bash
    git init
    ```

3.  **Add the remote repository (replace with the actual URL):**
    ```bash
    git remote add origin https://github.com/edwjonesga/scholastic
    ```

4.  **Enable sparse checkout and pull the template directory:**
    ```bash
    git config core.sparseCheckout true
    echo "tools/docker-firebase-project-env/*" >> .git/info/sparse-checkout
    git pull origin main # Or the correct default branch
    ```

5.  **Move the contents to your project root:**
    ```bash
    mv tools/docker-firebase-project-env/* .
    rm -rf tools
    ```

Now you have a clean copy of the template in your project directory.

## Prerequisites

- [Docker](https://www.docker.com/get-started) must be installed on your system.

## Getting Started

Follow these steps to initialize a new Firebase project:

### 1. Build the Docker Image

First, build the Docker image by running the `build-container.sh` script:

```bash
./build-container.sh
```

This will create a Docker image named `firebase-project-env` with all the necessary dependencies.

### 2. Start the Docker Container

Next, start the Docker container using the `start-container.sh` script:

```bash
./start-container.sh
```

This will start an interactive shell inside the container. The current directory is mounted as a volume at `/app`, so any changes you make locally will be reflected inside the container, and vice-versa.

### 3. Initialize Your Firebase Project

Once you are inside the container's shell, run the `init.sh` script to begin the Firebase project setup:

```bash
./init.sh
```

This script will guide you through the Firebase login and initialization process. It will also ask if you want to set up a Preact application for your Firebase Hosting frontend. Follow the on-screen prompts to configure your project.

After the script finishes, it will generate a set of helper scripts in your project's root directory.

### 4. Generated Helper Scripts

The initialization script creates the following useful scripts in your project directory:

-   `build.sh`: Builds the Preact frontend application. It runs `npm install` and `npm run build` inside the `preact-app` directory.
-   `run.sh`: Starts the local Firebase emulators for testing your backend functions and rules.
-   `run-vite.sh`: A convenience script that starts the Firebase emulators in the background and then starts the Vite development server for your Preact app.
-   `deploy.sh`: Builds the frontend application and then deploys both your hosting and functions to the Firebase project you specify.

### 5. Happy Coding!

After the `init.sh` script is complete, your Firebase project will be set up in the current directory. You can now use the generated helper scripts or the `firebase` CLI directly to manage your project. For example:

- `firebase emulators:start` to start the local emulators.
- `firebase deploy` to deploy your project.

If you created a Preact app, you can `cd preact-app` and use `npm run dev` to start the development server.

Enjoy your new Firebase project environment!
