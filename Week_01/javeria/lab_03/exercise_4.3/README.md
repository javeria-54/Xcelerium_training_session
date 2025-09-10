# Automated Backup Script

### Problem Statement

1. Write a script that creates a backup of a specified directory
2. The backup should be a compressed tar file with the current date in its name
3. Implement error handling for cases where the directory doesn't exist


---

### Solution

1. **Define Backup Directory**

   * `backupdir="/mnt/d/training_session/training_session"`
   * Ensures all backups are stored in one place.

2. **Create Directory if Missing**

   * `mkdir -p "$backupdir"` creates the backup directory if it doesn’t already exist.

3. **Timestamp Generation**

   * `time=$(date +%F)` fetches the current date (YYYY-MM-DD format).
   * The backup file is named using this timestamp, e.g., `backup_2025-09-09.tar.gz`.

4. **Backup Creation**

   * `tar czf "${backupdir}/${backupfile}" "/mnt/d/training_session/training_session/Week_01"`
   * Compresses the target directory (`Week_01`) into a `.tar.gz` file.

5. **User Notification**

   * After backup creation, the script prints:

     ```
     backup created /mnt/d/training_session/training_session/backup_2025-09-09.tar.gz
     ```

---

### Result 
```bash
backup created /mnt/d/training_session/training_session/backup_2025-09-09.tar.gz
```

### How to run

Run the script in terminal:

```bash
chmod +x backup.sh
./backup.sh
```

### Sources
* https://www.geeksforgeeks.org/linux-unix/linux-shell-script-to-backup-files-and-directory/
* Chatgpt

