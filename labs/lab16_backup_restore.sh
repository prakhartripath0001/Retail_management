#!/usr/bin/env bash
# ============================================================================
# LAB 16: BACKUP AND RESTORE UTILITY
# THEORY:
# Logical backups export SQL DDL and INSERT statements via mysqldump.
# Crucial production flags:
#   --single-transaction: Produces consistent snapshot without locking tables (InnoDB)
#   --routines: Includes stored procedures and functions
#   --triggers: Includes database triggers
#   --set-gtid-purged=OFF: Avoids replication GTID issues during cross-host restore
# ============================================================================

set -euo pipefail

DB_NAME="retail_management_db"
DB_USER="${DB_USER:-root}"
DB_HOST="${DB_HOST:-127.0.0.1}"
DB_PORT="${DB_PORT:-3306}"
BACKUP_DIR="./backups"
TIMESTAMP="$(date +'%Y%m%d_%H%M%S')"
BACKUP_FILE="${BACKUP_DIR}/${DB_NAME}_${TIMESTAMP}.sql"

mkdir -p "${BACKUP_DIR}"

backup() {
    echo "Starting backup of database '${DB_NAME}'..."
    mysqldump \
        --host="${DB_HOST}" \
        --port="${DB_PORT}" \
        --user="${DB_USER}" \
        -p \
        --single-transaction \
        --quick \
        --routines \
        --triggers \
        --databases "${DB_NAME}" > "${BACKUP_FILE}"
    echo "Backup completed successfully: ${BACKUP_FILE}"
}

restore() {
    TARGET_FILE="${1:-}"
    if [[ -z "${TARGET_FILE}" || ! -f "${TARGET_FILE}" ]]; then
        echo "Error: Please specify a valid backup file to restore."
        echo "Usage: $0 restore <path_to_backup.sql>"
        exit 1
    fi
    echo "Restoring database from '${TARGET_FILE}'..."
    mysql \
        --host="${DB_HOST}" \
        --port="${DB_PORT}" \
        --user="${DB_USER}" \
        -p < "${TARGET_FILE}"
    echo "Restore completed successfully."
}

case "${1:-backup}" in
    backup)
        backup
        ;;
    restore)
        restore "${2:-}"
        ;;
    *)
        echo "Usage: $0 {backup|restore <file>}"
        exit 1
        ;;
esac

