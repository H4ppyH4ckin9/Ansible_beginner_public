#!/bin/bash
# user needs sudo rights with NOPASSWD

# color codings ############ BEGIN ############
RED='\033[0;31m'
RED_BLINKING_BG='\033[5;41m'

GREEN='\033[0;32m'
YELLOW='\033[0;33m'
ORANGE='\033[38;5;208m'

WHITE='\033[1;37m'
NC='\033[0m'

FAT_B='\e[1m'
FAT_E='\e[0m'
# color codings ############ END ############

# get data ############ BEGIN ############
NAME=$(hostname)
OS=$(cat /etc/os-release | awk -F "=" '/PRETTY_NAME/ {gsub(/"/, "", $2); print $2}')

UPTIME_NUM=$(LANG="en_US.UTF-8" uptime | tr -d ',' | awk '{print $3}')
UPTIME_UNIT=$(LANG="en_US.UTF-8" uptime | tr -d ',' | awk '{print $4}')
DATE=$(date)

TIMEZONE=$(date +%Z)
TIMESYNC=$(timedatectl | awk '/System/ {print $4}')

LOAD=$(awk '{printf "5min: %-6s 10min: %-6s 15min: %-6s", $1, $2, $3}' /proc/loadavg)
MEMORY_TOTAL=$(free -h --si | awk '/^Mem:/ {print $2}')
MEMORY_USAGE=$(free | awk '/^Mem:/ {printf "%.1f%%", $3/$2*100}')
SWAP_USAGE=$(free | awk '/^Swap:/ {printf "%.1f%%", $3/$2*100}')

USAGE_ON_ROOT=$(df -h / | awk 'NR==2 {print $5}')
NUMBER_OF_RISKS=$(df -h | grep -E '[8-9][0-9]%' | awk '{printf "%s %s\n", $1, $5}' | wc -l)

ACCESS_RIGHTS=$(mount | grep '/dev/*(ro,')
LOCAL_USERS=$(who | wc -l)
PROCESSES=$(ps ax | wc -l)

CLUSTER_STATUS_SLES=$(sudo crm status 2>/dev/null)
CLUSTER_STATUS_RHEL=$(sudo pcs status 2>/dev/null)

SuseBaseProd=$(grep '<name>.*</name>' /etc/products.d/baseproduct 2>/dev/null| awk -F'[<>]' '{print $3}' | sed -n 2p)
# get data ############ END ############

# determine if SuseBaseProduct in SLES or SLES for SAP ############ BEGIN ############
if [[ "$SuseBaseProd" == *"SAP"* ]]; then
    BaseProd=$(echo -e "$FAT_B$SuseBaseProd$FAT_E")
else
    BaseProd=$(echo -e "$SuseBaseProd")
fi
# determine if SuseBaseProduct is SLES or SLES for SAP ############ END ############

# determine if timezone/timsync is right or not ############ BEGIN ############
if [[ "$TIMEZONE" == 'CEST' || "$TIMEZONE" == 'CET' ]]; then
    TIME=$(echo -e "${GREEN}our timezone${NC}")
else 
    TIME=$(echo -e "${RED}${TIMEZONE}${NC}")
fi
if [[ "$TIMESYNC" == 'yes' ]]; then
    SYNC=$(echo -e "${GREEN}ntp works${NC}")
else 
    SYNC=$(echo -e "${RED}check ntp${NC}")
fi
# determine if timezone is right or not ############ END ############

# uptime specific for supported OS ############ BEGIN ############
UPTIME_COLOR=${GREEN}

if ! [[ "$UPTIME_UNIT" =~ day ]]; then
    UPTIME_COLOR=${RED}
elif [[ "$UPTIME_NUM" -gt 90 ]]; then
    UPTIME_COLOR=${RED}
elif [[ "$UPTIME_NUM" -gt 30 ]]; then
    UPTIME_COLOR=${YELLOW}
fi

UPTIME_COLOR=$(echo -e "${UPTIME_COLOR}${UPTIME_NUM} ${UPTIME_UNIT}${NC}")
# uptime specific for supported OS ############ END ############

# colorize FS rights ############ BEGIN ############
if [[ "$ACCESS_RIGHTS" -gt 1 ]]; then
    ACCESS=$(echo -e "${RED_BLINKING_BG}${WHITE}THERE ARE READ-ONLY FS${NC}")
else
    ACCESS=$(echo -e "${GREEN}no read-only FS${NC}")
fi
# colorize FS rights ############ END ############

# colorize root FS usage ############ BEGIN ############
if [[ "$USAGE_ON_ROOT" < 80% ]]; then
    ROOT=$(echo -e "${GREEN}${USAGE_ON_ROOT}${NC}")
else
    ROOT=$(echo -e "${RED}${USAGE_ON_ROOT}${NC}")
fi
# colorize root FS usage ############ END ############

# calculate FS at risk ############ BEGIN ############
if [[ "$NUMBER_OF_RISKS" -lt 1 ]]; then
    RISKS=$(echo -e "${GREEN}no FS over 80%${NC}")
else
    RISKS=$(echo -e "${RED_BLINKING_BG}${WHITE}one or more FS are over 80%${NC}")
fi
# calculate FS at risk ############ END ############

# colorize OS according to Distribution ############ BEGIN ############
if [[ "$OS" == *"Red Hat"* || "$OS" == *"AlmaLinux"* || "$OS" == *"OracleLinux"* || "$OS" == *"Rocky Linux"* ]]; then
    COLOR=${RED}
elif [[ "$OS" == *"SUSE"* ]]; then
    COLOR=${GREEN}
elif [[ "$OS" == *"Ubuntu"* || "$OS" == *"Debian"* ]]; then
    COLOR=${ORANGE}
fi

NAME="${COLOR}${NAME}${NC}"
OS="${COLOR}${OS}${NC}"
# colorize OS according to Distribution ############ END ############

# Patch status ############ BEGIN ############
PATCH_STATUS=0
PATCH_STATUS_MESSAGE=""

if [[ "$OS" =~ Red\ Hat|CentOS|Fedora ]]; then
  # RHEL-based
  PATCH_STATUS=$(LANG=en sudo yum list updates 2>/dev/null | grep -c 'Available Upgrades')
elif [[ "$OS" =~ Debian|Ubuntu ]]; then
  # Debian-based
  PATCH_STATUS=$(LANG=en sudo apt list --upgradeable 2>/dev/null | grep -v '^Listing' | wc -l)
elif [[ "$OS" =~ SUSE|openSUSE ]]; then
  # SUSE-based
  PATCH_STATUS=$(LANG=en sudo zypper patch-check | grep -c 'available')
else
  PATCH_STATUS_MESSAGE="Unsupported OS"
fi

# Create patch status message
if [[ -z "$PATCH_STATUS_MESSAGE" ]]; then
  if [ "$PATCH_STATUS" -gt 0 ]; then
    PATCH_STATUS_MESSAGE="${RED}patches available${NC}"
  else
    PATCH_STATUS_MESSAGE="${GREEN}system is up-to-date${NC}"
  fi
fi
# Patch status ############ END ############

# Output & Formating ############ BEGIN ############
echo -e "${FAT_B}${OS}${FAT_E}"
echo    ""
echo -e "System uptime: ${UPTIME_COLOR}\t\t\tHostname: ${NAME}"
echo -e "System timezone: ${TIME}\t\t\tSystem status: ${PATCH_STATUS_MESSAGE}"
if [[ -n "$SuseBaseProd" && "$SuseBaseProd" != "0" ]]; then
    echo -e "System timesync: ${SYNC}\t\t\tProduct: ${BaseProd}"
else
    echo -e "System timesync: ${SYNC}"
fi
echo -e "===================================================================================="
echo -e "Memory Total:   ${MEMORY_TOTAL}\t\t\tUsage On /: ${ROOT}"
echo -e "Memory Usage:   ${MEMORY_USAGE}\t\t\tUsage on risk: ${RISKS}"
echo -e "Swap Usage:     ${SWAP_USAGE}\t\t\tAccess Rights: ${ACCESS}"
echo -e "Local Users:    ${LOCAL_USERS}\t\t\tLoad: ${LOAD}"
echo -e "Processes:      ${PROCESSES}\t\t\t"

echo -e "\nInterface               IP Address              DNS-Eintrag"
echo -e "==========              ==================      =============="

# Print each interface and its IP address
for iface in $(ip -o -f inet addr show | awk '{print $2}'); do
    if [[ "$iface" != "lo" ]]; then  # Ignore the loopback interface
        IP=$(ip -o -f inet addr show $iface | awk '{print $4}' | cut -d '/' -f 1)
        DNS_NAME=$(getent hosts $IP | awk '{print $2}' | xargs)
        echo -e "${iface}\t\t\t${IP}\t\t${DNS_NAME}"
    fi
done
# Output & Formating ############ END ############

# Cluster status if possible ############ BEGIN ############
if [[ -n "$CLUSTER_STATUS_SLES" ]]; then
    cluster_info="$CLUSTER_STATUS_SLES"
    echo -e "\n====================================== ${GREEN}${FAT_B}CLUSTER${FAT_E}${NC} ======================================"
    echo -e "${cluster_info}"
else
    if [[ -n "$CLUSTER_STATUS_RHEL" ]]; then
        cluster_info="$CLUSTER_STATUS_RHEL"
        echo -e "\n====================================== ${GREEN}${FAT_B}CLUSTER${FAT_E}${NC} ======================================"
        echo -e "${cluster_info}"
    else
        cluster_info="No cluster information available."
    fi
fi
# Cluster status if possible ############ END ############
