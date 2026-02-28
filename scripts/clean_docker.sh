#!/bin/bash
# clean_docker.sh - Reset Docker to a clean slate

echo "🧹 Docker Cleanup Utility"
echo "⚠️  WARNING: This will DESTROY ALL Docker containers, networks, images, and volumes."
echo "   Are you sure you want to proceed? (y/N)"
read -r response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    echo "🚨 Nuking Docker state..."
    # Stop all running containers
    CONTAINERS=$(docker ps -aq)
    if [ -n "$CONTAINERS" ]; then
        docker stop $CONTAINERS >/dev/null 2>&1 || true
    fi
    # Prune everything
    docker system prune -a --volumes -f
    echo "✅ Docker is completely clean."
else
    echo "🛑 Aborted."
fi
