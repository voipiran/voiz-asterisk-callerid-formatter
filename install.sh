#!/bin/bash
set -e
set -o pipefail


clear
# Colorize output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
MAGENTA='\033[1;35m'
BOLD='\033[1m'
NC='\033[0m' # No color
echo -e "${MAGENTA}###############################################################${NC}"
echo -e "${CYAN}██╗   ██╗ ██████╗ ██╗██████╗ ██╗██████╗  █████╗ ███╗   ██╗${NC}"
echo -e "${CYAN}██║   ██║██╔═══██╗██║██╔══██╗██║██╔══██╗██╔══██╗████╗  ██║${NC}"
echo -e "${CYAN}██║   ██║██║   ██║██║██████╔╝██║██████╔╝███████║██╔██╗ ██║${NC}"
echo -e "${CYAN}╚██╗ ██╔╝██║   ██║██║██╔═══╝ ██║██╔══██╗██╔══██║██║╚██╗██║${NC}"
echo -e "${CYAN} ╚████╔╝ ╚██████╔╝██║██║     ██║██║  ██║██║  ██║██║ ╚████║${NC}"
echo -e "${CYAN}  ╚═══╝   ╚═════╝ ╚═╝╚═╝     ╚═╝╚══╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝${NC}"
echo -e "${MAGENTA}###############################################################${NC}"
echo -e "${MAGENTA}                    https://voipiran.io                    ${NC}"
echo -e "${MAGENTA}###############################################################${NC}"

echo "Install VOIPIRAN CallerID Formatter"
echo "VOIPIRAN.io"
echo "VOIPIRAN Panel 1.0"
sleep 1

#############################ThePanel


#-----------------------------
# Paths
#-----------------------------
CUSTOM_CONF="/etc/asterisk/extensions_custom.conf"
SRC_FILE="extensions_voipiran_numberformatter.conf"
DEST_FILE="/etc/asterisk/$SRC_FILE"
BACKUP_DIR="/etc/asterisk/backup_voipiran_$(date +%Y%m%d_%H%M%S)"

#-----------------------------
# Ensure script runs as root
#-----------------------------
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Please run as root or with sudo${NC}"
    exit 1
fi

#-----------------------------
# Ensure [to-cidformatter] context does not already exist
#-----------------------------
if grep -q "^\[to-cidformatter\]" "$CUSTOM_CONF"; then
    echo -e "${RED}Error: The context [to-cidformatter] already exists in $CUSTOM_CONF.${NC}"
    echo -e "${RED}Please check the file manually and remove or modify it before running this script again.${NC}"
    exit 1
fi

#-----------------------------
# Ensure number formatter file exists
#-----------------------------
if [ ! -f "$SRC_FILE" ]; then
    echo -e "${RED}Error: $SRC_FILE not found in current directory!${NC}"
    exit 1
fi

#-----------------------------
# Backup
#-----------------------------
mkdir -p "$BACKUP_DIR"
echo "Creating backup..."
cp -f "$CUSTOM_CONF" "$BACKUP_DIR/extensions_custom.conf.bak"
if [ -f "$DEST_FILE" ]; then
    cp -f "$DEST_FILE" "$BACKUP_DIR/extensions_voipiran_numberformatter.conf.bak"
fi
echo -e "${GREEN}Backup completed in $BACKUP_DIR${NC}"
sleep 1

#-----------------------------
# Copy NumberFormatter file
#-----------------------------
cp -f "$SRC_FILE" "$DEST_FILE"
chown asterisk:asterisk "$DEST_FILE"
chmod 644 "$DEST_FILE"
echo -e "${GREEN}Copied $SRC_FILE to $DEST_FILE${NC}"

#-----------------------------
# Add #include at top if missing
#-----------------------------
if ! grep -q "^#include $SRC_FILE" "$CUSTOM_CONF"; then
    TMP_FILE=$(mktemp)
    echo "#include $SRC_FILE" > "$TMP_FILE"
    cat "$CUSTOM_CONF" >> "$TMP_FILE"
    mv "$TMP_FILE" "$CUSTOM_CONF"
    chown asterisk:asterisk "$CUSTOM_CONF"
    chmod 644 "$CUSTOM_CONF"
    echo -e "${GREEN}Added #include $SRC_FILE at the top of $CUSTOM_CONF${NC}"
else
    echo -e "${GREEN}Include line already exists in $CUSTOM_CONF${NC}"
fi

#-----------------------------
# Ensure [from-internal-custom] context exists
#-----------------------------
if ! grep -q "^\[from-internal-custom\]" "$CUSTOM_CONF"; then
    echo -e "\n[from-internal-custom]" >> "$CUSTOM_CONF"
    echo -e "${GREEN}Added [from-internal-custom] context${NC}"
else
    echo -e "${GREEN}[from-internal-custom] context already exists${NC}"
fi

#-----------------------------
# Ensure [to-cidformatter] context exists
#-----------------------------
if ! grep -q "^\[to-cidformatter\]" "$CUSTOM_CONF"; then
    cat <<'EOF' >> "$CUSTOM_CONF"

;; voipiran.io
[to-cidformatter]
exten => _.,1,Set(IS_PSTN_CALL=1)
exten => _.,n,Set(SAVED_DID=${EXTEN})
exten => _.,n,NoOp(start-from-pstn)
exten => _.,n,Gosub(numberformatter,s,1)
exten => _.,n,NoOp(end-from-pstn)
exten => _.,n,Goto(from-pstn,${SAVED_DID},1)
;exten => _.,n,Goto(ext-did,s,1)
EOF
    echo -e "${GREEN}Added [to-cidformatter] context${NC}"
    echo -e "${YELLOW}Note: You should change the trunk incoming context to context=to-cidformatter${NC}"
else
    echo -e "${YELLOW}[to-cidformatter] context already exists.${NC}"
    echo -e "${YELLOW}Please check the file manually and run the script again if needed.${NC}"
    exit 1
fi

#-----------------------------
# Reload Asterisk safely
#-----------------------------
if systemctl is-active --quiet asterisk; then
    systemctl reload asterisk
    echo -e "${GREEN}Asterisk reloaded successfully.${NC}"
else
    echo -e "${YELLOW}Asterisk service is not active. Please start it manually.${NC}"
fi