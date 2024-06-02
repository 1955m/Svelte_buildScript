# Svelte Project Setup Script

This script automates the setup process for a Svelte project on an EC2 instance running Amazon Linux. It clones a project from a GitHub repository, installs the necessary dependencies, builds the project, and sets up a systemd service and Nginx reverse proxy for running the Svelte application.

## Prerequisites

- EC2 instance running Amazon Linux
- GitHub repository URL for the Svelte project

## Usage

1. Connect to your EC2 instance via SSH.

2. Create a new file named `build.sh` using a text editor (e.g., `nano build.sh`).

3. Copy and paste the contents of the provided script into the `build.sh` file.

4. Save the file and exit the text editor.

5. Make the `build.sh` script executable by running the following command:
   ```bash
   chmod +x build.sh
   ```

6. Run the script with sudo privileges:
   ```bash
   sudo ./build.sh
   ```

7. When prompted, enter the GitHub link for your Svelte project repository.

8. Optionally, enter a custom server name for Nginx. If left blank, it will default to "your-domain.com".

9. The script will perform the following actions:
   - Update the system and install necessary packages (Node.js, npm, Git)
   - Clone the project repository from the provided GitHub link
   - Install project dependencies
   - Build the Svelte project
   - Create a systemd service for running the Svelte application
   - Install and configure Nginx as a reverse proxy
   - Create an `update_sveltekit.sh` script for updating the project with new changes from Git

10. Once the script finishes executing, your Svelte project will be set up and running on the EC2 instance.

## Updating the Project

To update the Svelte project with new changes from the Git repository, run the following command:
```bash
sudo ./update_sveltekit.sh
```

This script will:
- Stop the currently running Svelte application
- Pull the latest changes from the Git repository
- Install any new dependencies
- Rebuild the Svelte project
- Start the Svelte application again

## Customization

- If you want to use a different port for your Svelte application, modify the `PORT` environment variable in the systemd service file.
- Adjust the Nginx configuration in the `sveltekit.conf` file according to your requirements.
- Customize the `update_sveltekit.sh` script if you need to perform additional actions during the project update process.

## Note

- Make sure you have the necessary permissions to run the script with sudo privileges.
- The script assumes that the Svelte project's build output is located in the `build` directory. If your project uses a different build directory, modify the `WorkingDirectory` and `ExecStart` directives in the systemd service file accordingly.

For any further assistance or questions, please refer to the script comments or contact the script author.