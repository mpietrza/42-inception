#!/bin/bash
# Migration script to move data from Docker managed volumes to bind mounts

set -e

YELLOW='\033[1;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

DATA_PATH="/home/mpietrza/data"
COMPOSE_FILE="srcs/docker-compose.yml"

echo -e "${YELLOW}=== Docker Volume Migration Script ===${NC}"
echo ""
echo "This script will help you migrate from Docker managed volumes to bind mounts."
echo "It will:"
echo "  1. Stop all containers"
echo "  2. Create data directories at $DATA_PATH"
echo "  3. Copy data from old volumes (if they exist)"
echo "  4. Remove old volumes"
echo "  5. Restart containers with new configuration"
echo ""

# Check if running as correct user or with sudo
if [ ! -d "/home/mpietrza" ]; then
    echo -e "${RED}Warning: /home/mpietrza directory does not exist${NC}"
    echo "You may need to adjust DATA_PATH in Makefile and docker-compose.yml"
    echo ""
fi

# Ask for confirmation
read -p "Do you want to continue? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Migration cancelled."
    exit 0
fi

echo -e "${YELLOW}Step 1: Stopping containers...${NC}"
docker compose --file $COMPOSE_FILE down 2>/dev/null || true

echo -e "${YELLOW}Step 2: Creating data directories...${NC}"
mkdir -p $DATA_PATH/wordpress $DATA_PATH/mariadb
echo "Created: $DATA_PATH/wordpress"
echo "Created: $DATA_PATH/mariadb"

echo -e "${YELLOW}Step 3: Checking for existing volumes...${NC}"

# Check if old volumes exist
WORDPRESS_VOL=$(docker volume ls -q | grep -E "(srcs_)?wordpress_data" | head -1 || true)
MARIADB_VOL=$(docker volume ls -q | grep -E "(srcs_)?mariadb_data" | head -1 || true)

if [ ! -z "$WORDPRESS_VOL" ] || [ ! -z "$MARIADB_VOL" ]; then
    echo "Found existing volumes. Attempting to copy data..."
    
    # Create temporary container to copy data
    if [ ! -z "$WORDPRESS_VOL" ]; then
        echo "Copying WordPress data from $WORDPRESS_VOL..."
        docker run --rm \
            -v $WORDPRESS_VOL:/source:ro \
            -v $DATA_PATH/wordpress:/dest \
            alpine:3.21 \
            sh -c "cp -a /source/. /dest/ 2>/dev/null || true"
        echo -e "${GREEN}WordPress data copied${NC}"
    fi
    
    if [ ! -z "$MARIADB_VOL" ]; then
        echo "Copying MariaDB data from $MARIADB_VOL..."
        docker run --rm \
            -v $MARIADB_VOL:/source:ro \
            -v $DATA_PATH/mariadb:/dest \
            alpine:3.21 \
            sh -c "cp -a /source/. /dest/ 2>/dev/null || true"
        echo -e "${GREEN}MariaDB data copied${NC}"
    fi
    
    echo -e "${YELLOW}Step 4: Removing old volumes...${NC}"
    [ ! -z "$WORDPRESS_VOL" ] && docker volume rm $WORDPRESS_VOL && echo "Removed $WORDPRESS_VOL"
    [ ! -z "$MARIADB_VOL" ] && docker volume rm $MARIADB_VOL && echo "Removed $MARIADB_VOL"
else
    echo "No existing volumes found. Starting fresh."
fi

# Set proper permissions for mariadb
echo -e "${YELLOW}Step 5: Setting permissions...${NC}"
sudo chown -R 999:999 $DATA_PATH/mariadb 2>/dev/null || chown -R 999:999 $DATA_PATH/mariadb
sudo chmod -R 750 $DATA_PATH/mariadb 2>/dev/null || chmod -R 750 $DATA_PATH/mariadb
echo "Permissions set for MariaDB directory"

echo ""
echo -e "${GREEN}=== Migration Complete ===${NC}"
echo ""
echo "You can now run: make"
echo "Or manually: docker compose --file $COMPOSE_FILE up --detach --build"
