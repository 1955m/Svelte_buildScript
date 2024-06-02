#!/bin/bash

# Prompt the user for the GitHub link
read -p "Enter the GitHub link: " github_link

# Prompt the user for the server name
read -p "Enter the server name (leave blank for your-domain.com): " server_name

# Set the default server name if left blank
if [ -z "$server_name" ]; then
    server_name="your-domain.com"
fi

# Update the system and install necessary packages
sudo yum update -y
sudo yum install nodejs npm git -y

# Extract the repository name from the GitHub link
repo_name=$(echo $github_link | awk -F/ '{print $NF}' | sed 's/\.git$//')

# Clone the repository
git clone $github_link
cd $repo_name

# Install project dependencies
npm install

# Build the Svelte project
npm run build

# Create a systemd service file
sudo tee /etc/systemd/system/sveltekit.service > /dev/null <<EOF
[Unit]
Description=SvelteKit App
After=network.target

[Service]
User=$USER
Group=$USER
WorkingDirectory=$PWD
ExecStart=node $PWD/build/index.js
Environment=PORT=3000
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd daemon and start the service
sudo systemctl daemon-reload
sudo systemctl start sveltekit
sudo systemctl enable sveltekit

# Install and configure Nginx
sudo yum install nginx -y
sudo tee /etc/nginx/conf.d/sveltekit.conf > /dev/null <<EOF
upstream sveltekit {
    server localhost:3000;
}

server {
    listen 80;
    server_name $server_name;

    location / {
        proxy_pass http://sveltekit;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }
}
EOF

# Test Nginx configuration and restart the service
sudo nginx -t
sudo systemctl restart nginx
sudo systemctl enable nginx

# Create the update_sveltekit.sh script in the same directory as the script
tee update_sveltekit.sh > /dev/null <<EOF
#!/bin/bash

# Change to the project directory
cd $PWD/$repo_name

# Stop the SvelteKit service
sudo systemctl stop sveltekit

# Pull the latest changes from the GitHub repository
git pull origin main

# Install any new dependencies (if required)
npm install

# Rebuild the SvelteKit project
npm run build

# Start the SvelteKit service
sudo systemctl start sveltekit

echo "Code updated and SvelteKit service restarted."
EOF

# Make the update_sveltekit.sh script executable
chmod +x update_sveltekit.sh

echo "Svelte project setup completed successfully!"
echo "To update the project with new changes from Git, run: ./update_sveltekit.sh"