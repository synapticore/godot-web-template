#!/bin/bash
# Build and push the Godot 4.6 Docker image to GitHub Container Registry

set -e

# Configuration
REGISTRY="ghcr.io"
USERNAME="${GITHUB_USERNAME:-synapticore}"
IMAGE_NAME="godot-4.6-headless"
TAG="${DOCKER_TAG:-web}"
DOCKERFILE="ci/docker/godot-4.6-headless.Dockerfile"

# Full image name
FULL_IMAGE_NAME="${REGISTRY}/${USERNAME}/${IMAGE_NAME}:${TAG}"

echo "==========================================="
echo "Building Godot 4.6 Headless Docker Image"
echo "==========================================="
echo "Image: ${FULL_IMAGE_NAME}"
echo "Dockerfile: ${DOCKERFILE}"
echo ""

# Build the image
echo "Building Docker image..."
docker build -t "${FULL_IMAGE_NAME}" -f "${DOCKERFILE}" .

if [ $? -eq 0 ]; then
    echo ""
    echo "✓ Build successful!"
    echo ""
    echo "To push to GitHub Container Registry:"
    echo "  1. Login: echo \$GITHUB_TOKEN | docker login ghcr.io -u ${USERNAME} --password-stdin"
    echo "  2. Push: docker push ${FULL_IMAGE_NAME}"
    echo ""
    echo "Don't forget to update .github/workflows/export-web.yml with the correct image name!"
else
    echo ""
    echo "✗ Build failed!"
    exit 1
fi
