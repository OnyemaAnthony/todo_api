#!/bin/bash

# Parse arguments
DIRECTION=""
COUNT=1
FORCE_VERSION=""

while [[ "$#" -gt 0 ]]; do
    case $1 in
        -direction) DIRECTION="$2"; shift ;;
        -count) COUNT="$2"; shift ;;
        -force) FORCE_VERSION="$2"; shift ;;
    esac
    shift
done

# Load environment variables from .env file
if [ -f "../.env" ]; then
    export $(grep -v '^#' ../.env | xargs)
fi

# Ensure DATABASE_URL is found
if [ -z "$DATABASE_URL" ]; then
    echo "❌ Error: DATABASE_URL is not set in your .env file."
    exit 1
fi

# Handle force command first if requested (Fixed Syntax)
if [ -n "$FORCE_VERSION" ]; then
    echo "🔧 Forcing database version to $FORCE_VERSION to clear dirty state..."
    migrate -path ../migrations -database "$DATABASE_URL" force "$FORCE_VERSION"
    exit 0
fi

# Run the migration based on direction
if [ "$DIRECTION" == "up" ]; then
    echo "🔄 Running up migrations..."
    migrate -path ../migrations -database "$DATABASE_URL" up
elif [ "$DIRECTION" == "down" ]; then
    read -p "⚠️ Are you sure you want to roll back $COUNT migration(s)? (y/N): " CONFIRM
    if [[ "$CONFIRM" =~ ^[Yy]$ ]]; then
        echo "🛑 Rolling back migrations..."
        migrate -path ../migrations -database "$DATABASE_URL" down "$COUNT"
    else
        echo "❌ Migration rollback cancelled."
    fi
else
    echo "ℹ️ Usage: ./migrate.sh -direction [up|down] -count [number] OR ./migrate.sh -force [version]"
fi
