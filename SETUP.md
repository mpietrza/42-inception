# 42 Inception Setup Instructions

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

1. Build and start all services:
   ```bash
   make
   ```

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

## Stopping and Cleaning

- Stop containers: `make stop`
- Stop and remove containers: `make down`
- Clean all Docker resources: `make clean`
- Clean everything including data: `make fclean`
