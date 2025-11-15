# 42 Inception Setup Instructions

## Quick Start (for existing installations)

If you're updating from an older configuration and getting volume mismatch errors:

```bash
./migrate-volumes.sh
```

## Prerequisites

### 1. Configure /etc/hosts

You need to add the domain name to your `/etc/hosts` file to access the website locally.

Add this line to `/etc/hosts`:
```
127.0.0.1   mpietrza.42.fr
```

On Linux/Mac:
```bash
sudo sh -c 'echo "127.0.0.1   mpietrza.42.fr" >> /etc/hosts'
```

On Windows (as Administrator):
```cmd
echo 127.0.0.1   mpietrza.42.fr >> C:\Windows\System32\drivers\etc\hosts
```

### 2. Environment Variables

Copy the example environment file and customize it:

```bash
cp srcs/.env.example srcs/.env
```

Then edit `srcs/.env` to set your own values. **Important**: Use strong passwords for production!

### 3. Data Directory

The project will create persistent data directories at:
- `/home/mpietrza/data/mariadb` - MariaDB database files
- `/home/mpietrza/data/wordpress` - WordPress files

These directories will be created automatically when you run `make`.

## Running the Project

### First Time Setup or After Configuration Changes

If you have previously run the project and are now applying these configuration changes, you have two options:

**Option 1: Migrate existing data (recommended if you want to keep data)**
```bash
./migrate-volumes.sh
```
This script will automatically copy your existing data from Docker volumes to the new bind mount directories.

**Option 2: Fresh start (all data will be lost)**
```bash
make fclean
```
This will remove all containers, images, volumes, and data directories.

### Normal Startup

1. Build and start all services:
   ```bash
   make
   ```
   
   **Note**: If you see a prompt about volume recreation:
   - If you already ran `migrate-volumes.sh`, answer 'y'
   - If you want to keep old data, answer 'n' and run `migrate-volumes.sh` first

2. Check the status of containers:
   ```bash
   make ps
   ```

3. View logs:
   ```bash
   make logs
   ```

4. Access the website:
   - Open your browser and navigate to: `https://mpietrza.42.fr/`
   - You will see a security warning because of the self-signed SSL certificate
   - Click "Advanced" and proceed to the site

## Troubleshooting

### Volume Configuration Conflict

If you see a message like "Volume exists but doesn't match configuration", it means you have old Docker volumes from a previous configuration. You have two options:

**Option 1: Clean slate (recommended)**
```bash
make fclean
make
```

**Option 2: Answer 'y' when prompted**
When Docker asks to recreate the volume, type 'y' and press Enter. This will recreate the volumes with the new bind mount configuration.

### Website Not Accessible

If the website is not accessible:

1. Verify containers are running:
   ```bash
   make ps
   ```

2. Check logs for errors:
   ```bash
   make logs
   ```

3. Verify /etc/hosts entry:
   ```bash
   cat /etc/hosts | grep mpietrza
   ```

4. Test if nginx is responding:
   ```bash
   curl -k https://localhost:443
   ```

5. Check if data directories exist and have correct permissions:
   ```bash
   ls -la /home/mpietrza/data/
   ```

## Stopping and Cleaning

- Stop containers: `make stop`
- Stop and remove containers: `make down`
- Clean all Docker resources: `make clean`
- Clean everything including data: `make fclean`
