# WSO2 API Manager 3.1.0 Distributed Setup

🚀 **Complete automation for WSO2 API Manager distributed deployment with MySQL database integration**

## 📋 Overview

This setup provides a complete automated solution for deploying WSO2 API Manager 3.1.0 in distributed mode with:
- **Automated MySQL database setup** with Docker
- **Configurable database settings** via `.env` file
- **Smart port management** and availability checking
- **Distributed profile creation** and configuration
- **Integrated TOML configuration management**
- **Cross-platform support** (Linux, macOS, Windows)

## 🎯 Quick Start

### 1. One-Command Complete Setup
```bash
# Setup MySQL database with Docker
./scripts/setup-mysql-docker.sh

# Setup all WSO2 profiles with database integration
./scripts/setup-distributed-profiles.sh

# Update TOML files with database configuration
./scripts/update-toml-db-config.sh

# Start all profiles
./scripts/start-distributed-profiles.sh
```

### 2. Management Commands
```bash
# Check service status
./scripts/status-distributed-profiles.sh

# Stop all profiles (force kill - immediate)
./scripts/stop-distributed-profiles.sh
```

## 🗂️ Project Structure

### **Repository Structure (Clean - Before Setup):**
```
wso2am-3.1.0-distributed-setup/
├── README.md                           # This comprehensive guide
├── .env                               # Configuration file (tracked in Git)
├── .gitignore                          # Git ignore rules
├── docker-compose.yaml                 # Docker Compose configuration
├── conf/
│   ├── mysql-connector-j-9.2.0.jar   # MySQL connector
│   └── toml/                          # Profile-specific configurations
│       ├── km_deployment.toml
│       ├── tm_deployment.toml
│       ├── dev_deployment.toml
│       ├── pub_deployment.toml
│       └── gw_deployment.toml
└── scripts/                            # Automation scripts
    ├── setup-mysql-docker.sh          # MySQL Docker setup
    ├── setup-mysql-databases.sh       # Database initialization
    ├── update-toml-db-config.sh       # TOML configuration sync
    ├── setup-distributed-profiles.sh  # Profile setup
    ├── start-distributed-profiles.sh  # Start all profiles
    └── stop-distributed-profiles.sh   # Stop all profiles
```

### **After Adding WSO2 Pack and Running Setup:**
```
wso2am-3.1.0-distributed-setup/
├── wso2am-3.1.0.zip                   # ← PLACE YOUR DOWNLOAD HERE
├── wso2am-3.1.0/                      # ← Auto-extracted by scripts
├── components/                         # ← Auto-created distributed profiles
│   ├── wso2am-km/                     # Key Manager
│   ├── wso2am-tm/                     # Traffic Manager
│   ├── wso2am-dev/                    # Developer Portal
│   ├── wso2am-pub/                    # Publisher
│   └── wso2am-gw/                     # Gateway
├── logs/                              # ← Auto-created startup logs
│   ├── startup-km.log
│   ├── startup-tm.log
│   ├── startup-dev.log
│   ├── startup-pub.log
│   └── startup-gw.log
└── ...existing files...
```

**🔒 Note:** The `.gitignore` file ensures that:
- WSO2 packs and extracted directories are NOT tracked
- Generated profiles in `components/` are NOT tracked  
- Log files are NOT tracked
- Only the automation scripts and configuration templates are version controlled

## ⚙️ Configuration

### Database and Environment Configuration (`.env`)
All configuration is centralized in the root `.env` file:

```bash
# MySQL Docker Configuration
MYSQL_PORT=3326                    # Configurable MySQL port
MYSQL_ROOT_PASSWORD=my-secret      # MySQL root password
CONTAINER_NAME=wso2am-mysql        # Docker container name

# Database Configuration
APIM_DB_NAME=apim_db310           # API Manager database name
SHARED_DB_NAME=shared_db310       # Shared database name
APIM_DB_USER=apimadmin           # API Manager database user
APIM_DB_PASSWORD=apimadmin123    # API Manager database password
SHARED_DB_USER=sharedadmin       # Shared database user
SHARED_DB_PASSWORD=sharedadmin123 # Shared database password
```

**📝 Note:** The `.env` file contains default, non-sensitive values and is tracked in Git for easy setup.

### Profile Port Configuration
- **Traffic Manager**: 9711 (offset: 0)
- **Key Manager**: 9443 (offset: 1)
- **Publisher**: 9445 (offset: 2)
- **Developer Portal**: 9446 (offset: 3)
- **Gateway**: 8284, 8247 (offset: 4)

## 🛠️ Scripts Reference

### 1. `setup-mysql-docker.sh` 🐳
**Smart MySQL Docker setup with intelligent container management**

**Features:**
- ✅ **Smart Container Detection**: Recognizes existing containers
- ✅ **Port Conflict Resolution**: Handles port conflicts intelligently
- ✅ **Database Auto-Creation**: Creates databases and users automatically
- ✅ **Schema Initialization**: Runs WSO2 SQL scripts automatically
- ✅ **Health Monitoring**: Waits for MySQL to be ready

**Usage:**
```bash
./scripts/setup-mysql-docker.sh     # Full setup
```

**Behavior:**
- **First run**: Creates new MySQL container and databases
- **Subsequent runs**: Detects existing container, skips creation
- **Port conflicts**: Distinguishes between our container vs. other processes

### 2. `update-toml-db-config.sh` 🔄
**Synchronizes `.env` database settings with all TOML configuration files**

**Features:**
- ✅ **Reads from `.env`**: Uses centralized configuration
- ✅ **Updates all TOML files**: Syncs 5 profile configurations
- ✅ **Creates backups**: Preserves original files (.bak)
- ✅ **Validates changes**: Shows updated configurations

**Usage:**
```bash
./scripts/update-toml-db-config.sh
```

**Updated Files:**
- `dev_deployment.toml` (Developer Portal)
- `pub_deployment.toml` (Publisher)
- `km_deployment.toml` (Key Manager)
- `gw_deployment.toml` (Gateway)
- `tm_deployment.toml` (Traffic Manager)

### 3. `setup-distributed-profiles.sh` 📁
**Creates distributed WSO2 profile copies with proper configurations**

**Features:**
- ✅ **Auto-Detection**: Finds WSO2AM installation or extracts from ZIP
- ✅ **Profile Creation**: Creates 5 distinct profiles
- ✅ **MySQL Connector**: Installs MySQL connector in each profile
- ✅ **TOML Configuration**: Applies profile-specific settings
- ✅ **Backup Creation**: Preserves original configurations

**Profiles Created:**
- `wso2am-km` (Key Manager)
- `wso2am-tm` (Traffic Manager)
- `wso2am-dev` (Developer Portal)
- `wso2am-pub` (Publisher)
- `wso2am-gw` (Gateway)

### 4. `start-distributed-profiles.sh` ▶️
**Starts all profiles in correct distributed deployment order**

**Features:**
- ✅ **Ordered Startup**: TM → KM → PUB → DEV → GW
- ✅ **Port Validation**: Checks port availability before starting
- ✅ **Health Monitoring**: Verifies each service starts properly
- ✅ **PID Tracking**: Creates PID files for process management
- ✅ **Logging**: Individual startup logs for each profile

**Startup Order:**
1. Traffic Manager (9711)
2. Key Manager (9443)
3. Publisher (9443 + offset 2)
4. Developer Portal (9446)
5. Gateway (8280, 8243)

### 5. `stop-distributed-profiles.sh` ⏹️
**Force stops all profiles immediately in reverse order**

**Features:**
- ✅ **Immediate Termination**: Force kills all WSO2 processes (SIGKILL)
- ✅ **Reverse Order**: GW → DEV → PUB → KM → TM
- ✅ **Multiple Detection**: Finds processes by PID files, patterns, and port usage
- ✅ **PID Cleanup**: Removes stale PID files
- ✅ **Final Verification**: Confirms all processes are terminated

**Usage:**
```bash
./scripts/stop-distributed-profiles.sh           # Force stop (immediate)
./scripts/stop-distributed-profiles.sh --help    # Show help
```

### 6. `status-distributed-profiles.sh` 📊
**Check the status of all WSO2 API Manager profiles**

**Features:**
- ✅ **Process Status**: Shows PID and process state
- ✅ **Port Status**: Checks if services are listening on expected ports
- ✅ **Service Count**: Summary of running vs. stopped services
- ✅ **Quick URLs**: Shows service URLs when all are running

**Usage:**
```bash
./scripts/status-distributed-profiles.sh
```

### 7. `setup-mysql-databases.sh` 💾
**Direct MySQL database setup (alternative to Docker setup)**

**Features:**
- ✅ **Direct MySQL Setup**: For existing MySQL installations
- ✅ **Database Creation**: Creates APIM and Shared databases
- ✅ **User Management**: Creates database users with proper permissions
- ✅ **Schema Initialization**: Runs WSO2 SQL scripts
- ✅ **Multiple Modes**: Force, preserve, and interactive modes

**Usage:**
```bash
./scripts/setup-mysql-databases.sh          # Force recreate (default)
./scripts/setup-mysql-databases.sh --preserve   # Preserve existing data
./scripts/setup-mysql-databases.sh --interactive  # Ask before dropping
```

## 🔧 Advanced Usage

### Changing MySQL Port
```bash
# 1. Edit .env file in root directory
nano .env
# Change: MYSQL_PORT=3327

# 2. Update TOML configurations
./scripts/update-toml-db-config.sh

# 3. Recreate MySQL container
./scripts/setup-mysql-docker.sh
```

### Database Backup and Restore
```bash
# Backup databases
docker exec wso2am-mysql mysqldump -uroot -pmy-secret --all-databases > backup.sql

# Restore databases
docker exec -i wso2am-mysql mysql -uroot -pmy-secret < backup.sql
```

### Viewing Logs
```bash
# MySQL container logs
docker logs wso2am-mysql

# WSO2 startup logs
tail -f logs/startup-*.log

# Individual profile logs
tail -f components/wso2am-km/repository/logs/wso2carbon.log
```

## 🔍 Troubleshooting

### Common Issues

**❌ Port Already in Use**
```bash
# Check what's using the port
lsof -i :3326

# Kill the process (if not our container)
sudo kill $(lsof -t -i:3326)

# Or change port in .env file
MYSQL_PORT=3327
```

**❌ Permission Denied**
```bash
# Make scripts executable
chmod +x scripts/*.sh
```

**❌ MySQL Connection Failed**
```bash
# Check container status
docker ps -a | grep wso2am-mysql

# View container logs
docker logs wso2am-mysql

# Test database connection
mysql -h127.0.0.1 -P3326 -uroot -pmy-secret -e "SHOW DATABASES;"
```

**❌ WSO2 Profile Won't Start**
```bash
# Check port conflicts
netstat -tulpn | grep :9443

# Check logs
tail -f logs/startup-km.log
tail -f components/wso2am-km/repository/logs/wso2carbon.log
```

### Database Connection URLs

**Development:**
```
APIM DB: jdbc:mysql://localhost:3326/apim_db310?autoReconnect=true&useSSL=false&allowPublicKeyRetrieval=true
Shared DB: jdbc:mysql://localhost:3326/shared_db310?autoReconnect=true&useSSL=false&allowPublicKeyRetrieval=true
```

**Credentials:**
- APIM DB: `apimadmin / apimadmin123`
- Shared DB: `sharedadmin / sharedadmin123`
- Root: `root / my-secret`

## 🌍 Cross-Platform Support

### Linux/macOS
All scripts work natively with bash shell.

### Windows (WSL)
Use Windows Subsystem for Linux (WSL) to run the bash scripts in a Linux environment. This is the recommended approach for Windows users.

```bash
# In WSL terminal
./scripts/setup-mysql-docker.sh
./scripts/setup-distributed-profiles.sh
```

## 📋 Prerequisites

### Required Software
- **Docker**: For MySQL container management
- **Java 8/11**: For WSO2 API Manager
- **Disk Space**: ~5GB for all profiles
- **Memory**: 8GB+ RAM recommended

### **🚨 IMPORTANT: WSO2 API Manager Pack Setup**

**Before running any scripts, you MUST download and place the WSO2 API Manager pack in the root directory:**

1. **Download WSO2 API Manager 3.1.0:**
   - Go to [WSO2 API Manager Downloads](https://wso2.com/api-manager/)
   - Download: `wso2am-3.1.0.zip`

2. **Place the ZIP file in the root directory:**
   ```
   wso2am-3.1.0-distributed-setup/
   ├── wso2am-3.1.0.zip          # ← PLACE ZIP FILE HERE
   ├── scripts/
   ├── conf/
   └── README.md
   ```

3. **File Naming Requirements:**
   - File must be named exactly: `wso2am-3.1.0.zip`
   - Place it in the root directory (same level as `scripts/` folder)
   - Do NOT extract it manually - scripts will handle extraction

**⚠️ The setup scripts will automatically:**
- Detect the ZIP file
- Extract it to `wso2am-3.1.0/` directory
- Create distributed profile copies in `components/` directory

### Network Ports
Ensure these ports are available:
- **3326**: MySQL (configurable)
- **9711**: Traffic Manager
- **9443-9446**: Management consoles
- **8280, 8243**: Gateway endpoints

## 🎓 Getting Started Tutorial

### Step 1: Download WSO2 API Manager Pack ⚡ **REQUIRED FIRST STEP**
```bash
# Download WSO2 API Manager 3.1.0 from https://wso2.com/api-manager/
# Place wso2am-3.1.0.zip in the root directory

# Verify the file is in place
ls -la wso2am-3.1.0.zip
```

### Step 2: Initial Setup
```bash
# Clone or download this setup
cd wso2am-3.1.0-distributed-setup

# Make scripts executable (Linux/macOS)
chmod +x scripts/*.sh
```

### Step 3: Configure Database
```bash
# Edit database settings (optional)
nano .env

# Setup MySQL with Docker
./scripts/setup-mysql-docker.sh
```

### Step 4: Setup Profiles
```bash
# Create distributed profiles (will auto-extract WSO2 pack)
./scripts/setup-distributed-profiles.sh

# Sync database configuration
./scripts/update-toml-db-config.sh
```

### Step 5: Start Services
```bash
# Start all profiles
./scripts/start-distributed-profiles.sh

# Verify services are running
curl http://localhost:8280/services/
```

### Step 6: Access Services
- **Publisher**: https://localhost:9443/publisher
- **Developer Portal**: https://localhost:9446/devportal
- **Admin Portal**: https://localhost:9443/admin
- **Gateway**: http://localhost:8280, https://localhost:8243

### Step 7: Shutdown
```bash
# Graceful shutdown
./scripts/stop-distributed-profiles.sh
```

## 🔒 Security Notes

- Change default passwords in `.env` file
- Use secure passwords for database users
- Configure SSL certificates for production
- Restrict network access to management ports
- Enable firewall rules for production deployment

## 📄 License

This setup is provided as-is for WSO2 API Manager distributed deployment automation. Please refer to WSO2's official licensing for the API Manager software.

## 🆘 Support

For issues and questions:
1. Check the troubleshooting section above
2. Review the logs in `logs/` directory
3. Check MySQL container status: `docker ps -a | grep wso2am-mysql`
4. Refer to [WSO2 API Manager documentation](https://apim.docs.wso2.com/)

---

**🎉 Happy API Management with WSO2!**
