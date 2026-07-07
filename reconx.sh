#!/bin/bash
###############################################################################
# ReconX - Version 1
# Bash-based Information Gathering / Recon Automation Tool
# Developed by: Gehna Maheshwari
#
# Use ONLY on systems/domains you own or have explicit authorization to test.
###############################################################################

# ---------------------------- Colors -----------------------------------------
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
CYAN="\e[36m"
MAGENTA="\e[35m"
BOLD="\e[1m"
NC="\e[0m"

VERSION="1.0"
AUTHOR="Gehna Maheshwari"
REPORT_DIR="reports"
mkdir -p "$REPORT_DIR"

TOTAL_MODULES=13

# ---------------------------- Banner ------------------------------------------
banner() {
    clear
    echo -e "${CYAN}${BOLD}"
    cat << "EOF"
============================================================
   ____                       __  __
  |  _ \ ___  ___ ___  _ __  \ \/ /
  | |_) / _ \/ __/ _ \| '_ \  \  /
  |  _ <  __/ (_| (_) | | | | /  \
  |_| \_\___|\___\___/|_| |_|/_/\_\

           Information Gathering Tool
============================================================
EOF
    echo -e "${NC}"
    echo -e "${YELLOW}   Version       : ${VERSION}${NC}"
    echo -e "${YELLOW}   Developed by  : ${AUTHOR}${NC}"
    echo -e "${CYAN}============================================================${NC}"
}

pause() {
    echo ""
    read -rp "Press Enter to continue..." _
}

# ---------------------------- Progress Bar ------------------------------------
# usage: progress_bar current total label
progress_bar() {
    local current=$1
    local total=$2
    local label=$3
    local width=40
    local filled=$(( current * width / total ))
    local empty=$(( width - filled ))
    local percent=$(( current * 100 / total ))

    local bar="["
    if [ "$filled" -gt 0 ]; then
        bar+=$(printf '#%.0s' $(seq 1 $filled))
    fi
    if [ "$empty" -gt 0 ]; then
        bar+=$(printf '.%.0s' $(seq 1 $empty))
    fi
    bar+="]"

    printf "\r${GREEN}%-30s${NC} %s %3d%%" "$label" "$bar" "$percent"
    if [ "$current" -eq "$total" ]; then
        echo ""
    fi
}

# ---------------------------- Dependency Checker / Installer ------------------
REQUIRED_TOOLS=(ping nslookup whois nmap curl openssl dig whatweb)
declare -A TOOL_PACKAGE=(
    [ping]="iputils-ping"
    [nslookup]="dnsutils"
    [whois]="whois"
    [nmap]="nmap"
    [curl]="curl"
    [openssl]="openssl"
    [dig]="dnsutils"
    [whatweb]="whatweb"
)

check_deps() {
    echo -e "${YELLOW}[*] Checking required tools...${NC}"
    missing=()
    for d in "${REQUIRED_TOOLS[@]}"; do
        if ! command -v "$d" >/dev/null 2>&1; then
            missing+=("$d")
        fi
    done

    if [ ${#missing[@]} -eq 0 ]; then
        echo -e "${GREEN}[+] All dependencies are installed.${NC}"
    else
        echo -e "${RED}[!] Missing tools: ${missing[*]}${NC}"
        echo -e "${YELLOW}[*] Use Menu Option 1 (Install Requirements) to install everything automatically.${NC}"
    fi
}

install_tools() {
    banner
    echo -e "${CYAN}${BOLD}Installing / Updating all required tools and dependencies...${NC}"
    echo ""

    packages=""
    for tool in "${REQUIRED_TOOLS[@]}"; do
        pkg="${TOOL_PACKAGE[$tool]}"
        if [[ "$packages" != *"$pkg"* ]]; then
            packages+=" $pkg"
        fi
    done

    echo -e "${YELLOW}[*] Running: sudo apt update${NC}"
    sudo apt update

    echo -e "${YELLOW}[*] Installing packages:${NC}$packages"
    sudo apt install -y $packages

    echo ""
    echo -e "${GREEN}[+] Installation complete. Verifying...${NC}"
    check_deps
    pause
}

# ---------------------------- HTML helpers -------------------------------------
html_escape() {
    sed -e 's/&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g'
}

# ---------------------------- Recon Modules (capture output into variables) ---
# Each module sets a global variable OUT_<name> with escaped HTML-ready text

run_recon_for_target() {
    local TARGET="$1"
    local step=0
    local TXT_REPORT="$REPORT_DIR/report_${TARGET//\//_}_$(date +%Y%m%d_%H%M%S).txt"

    echo "ReconX Report for $TARGET" > "$TXT_REPORT"
    echo "Generated: $(date)" >> "$TXT_REPORT"
    echo "Developed by: $AUTHOR" >> "$TXT_REPORT"
    echo "========================================" >> "$TXT_REPORT"

    RESOLVED_IP=""

    echo ""
    echo -e "${MAGENTA}${BOLD}Scanning target: $TARGET${NC}"

    step=$((step+1)); progress_bar $step $TOTAL_MODULES "Ping"
    OUT_PING=$(ping -c 4 "$TARGET" 2>&1)
    echo "[Ping]" >> "$TXT_REPORT"; echo "$OUT_PING" >> "$TXT_REPORT"

    step=$((step+1)); progress_bar $step $TOTAL_MODULES "DNS Lookup"
    OUT_DNS=$(nslookup "$TARGET" 2>&1)
    echo "[DNS Lookup]" >> "$TXT_REPORT"; echo "$OUT_DNS" >> "$TXT_REPORT"

    step=$((step+1)); progress_bar $step $TOTAL_MODULES "DNS Records"
    OUT_DNSREC=""
    for rtype in A AAAA MX TXT NS; do
        OUT_DNSREC+="-- $rtype --"$'\n'
        OUT_DNSREC+="$(dig +short "$TARGET" "$rtype" 2>&1)"$'\n'
    done
    echo "[DNS Records]" >> "$TXT_REPORT"; echo "$OUT_DNSREC" >> "$TXT_REPORT"

    step=$((step+1)); progress_bar $step $TOTAL_MODULES "IP Resolution"
    RESOLVED_IP=$(dig +short "$TARGET" | head -n1)
    OUT_IP="Resolved IP: ${RESOLVED_IP:-N/A}"
    echo "[IP Resolution]" >> "$TXT_REPORT"; echo "$OUT_IP" >> "$TXT_REPORT"

    step=$((step+1)); progress_bar $step $TOTAL_MODULES "GeoIP Lookup"
    if [ -n "$RESOLVED_IP" ]; then
        OUT_GEOIP=$(curl -s "https://ipinfo.io/${RESOLVED_IP}/json" 2>/dev/null)
    else
        OUT_GEOIP="No IP resolved."
    fi
    echo "[GeoIP]" >> "$TXT_REPORT"; echo "$OUT_GEOIP" >> "$TXT_REPORT"

    step=$((step+1)); progress_bar $step $TOTAL_MODULES "WHOIS"
    OUT_WHOIS=$(whois "$TARGET" 2>&1 | grep -Ei "domain name|registrar:|creation date|registry expiry|updated date|name server|dnssec" | sort -u)
    echo "[WHOIS]" >> "$TXT_REPORT"; echo "$OUT_WHOIS" >> "$TXT_REPORT"

    step=$((step+1)); progress_bar $step $TOTAL_MODULES "Port Scan"
    OUT_PORTS=$(nmap -F -sV "$TARGET" 2>&1)
    echo "[Port Scan]" >> "$TXT_REPORT"; echo "$OUT_PORTS" >> "$TXT_REPORT"

    step=$((step+1)); progress_bar $step $TOTAL_MODULES "HTTP Headers"
    OUT_HEADERS=$(curl -s -I -L "https://$TARGET" 2>/dev/null)
    echo "[HTTP Headers]" >> "$TXT_REPORT"; echo "$OUT_HEADERS" >> "$TXT_REPORT"

    step=$((step+1)); progress_bar $step $TOTAL_MODULES "Security Headers"
    OUT_SECHEADERS=""
    for h in "Strict-Transport-Security" "Content-Security-Policy" "X-Frame-Options" "X-Content-Type-Options" "Referrer-Policy"; do
        if echo "$OUT_HEADERS" | grep -qi "$h"; then
            OUT_SECHEADERS+="[PRESENT] $h"$'\n'
        else
            OUT_SECHEADERS+="[MISSING] $h"$'\n'
        fi
    done
    echo "[Security Headers]" >> "$TXT_REPORT"; echo "$OUT_SECHEADERS" >> "$TXT_REPORT"

    step=$((step+1)); progress_bar $step $TOTAL_MODULES "HTTP Status"
    OUT_STATUS="HTTP Status: $(curl -s -o /dev/null -w '%{http_code}' -L "https://$TARGET")"
    echo "[HTTP Status]" >> "$TXT_REPORT"; echo "$OUT_STATUS" >> "$TXT_REPORT"

    step=$((step+1)); progress_bar $step $TOTAL_MODULES "robots.txt"
    OUT_ROBOTS=$(curl -s -L "https://$TARGET/robots.txt" 2>/dev/null)
    echo "[robots.txt]" >> "$TXT_REPORT"; echo "$OUT_ROBOTS" >> "$TXT_REPORT"

    step=$((step+1)); progress_bar $step $TOTAL_MODULES "SSL Certificate"
    OUT_SSL=$(echo | openssl s_client -connect "$TARGET:443" -servername "$TARGET" 2>/dev/null | openssl x509 -noout -issuer -subject -dates 2>/dev/null)
    echo "[SSL Certificate]" >> "$TXT_REPORT"; echo "$OUT_SSL" >> "$TXT_REPORT"

    step=$((step+1)); progress_bar $step $TOTAL_MODULES "Technology Detection"
    if command -v whatweb >/dev/null 2>&1; then
        OUT_TECH=$(whatweb "$TARGET" 2>&1)
    else
        OUT_TECH="whatweb not installed."
    fi
    echo "[Technology Detection]" >> "$TXT_REPORT"; echo "$OUT_TECH" >> "$TXT_REPORT"

    echo -e "\n${GREEN}[+] Finished: $TARGET  (Text report: $TXT_REPORT)${NC}"

    # Build this target's HTML block and append to global array (via temp file)
    build_html_block "$TARGET" >> "$HTML_BODY_FILE"
}

build_html_block() {
    local TARGET="$1"
    cat << HTMLBLOCK
<div class="target-card">
  <h2>Target: $(echo "$TARGET" | html_escape)</h2>

  <div class="category network">
    <h3>Network Information</h3>
    <details open><summary>Ping</summary><pre>$(echo "$OUT_PING" | html_escape)</pre></details>
    <details><summary>IP Resolution</summary><pre>$(echo "$OUT_IP" | html_escape)</pre></details>
    <details><summary>GeoIP</summary><pre>$(echo "$OUT_GEOIP" | html_escape)</pre></details>
  </div>

  <div class="category dns">
    <h3>DNS Information</h3>
    <details><summary>DNS Lookup</summary><pre>$(echo "$OUT_DNS" | html_escape)</pre></details>
    <details><summary>DNS Records</summary><pre>$(echo "$OUT_DNSREC" | html_escape)</pre></details>
    <details><summary>WHOIS</summary><pre>$(echo "$OUT_WHOIS" | html_escape)</pre></details>
  </div>

  <div class="category web">
    <h3>Web Information</h3>
    <details><summary>HTTP Headers</summary><pre>$(echo "$OUT_HEADERS" | html_escape)</pre></details>
    <details><summary>HTTP Status Code</summary><pre>$(echo "$OUT_STATUS" | html_escape)</pre></details>
    <details><summary>robots.txt</summary><pre>$(echo "$OUT_ROBOTS" | html_escape)</pre></details>
    <details><summary>Technology Detection</summary><pre>$(echo "$OUT_TECH" | html_escape)</pre></details>
  </div>

  <div class="category security">
    <h3>Security Information</h3>
    <details open><summary>Security Headers</summary><pre>$(echo "$OUT_SECHEADERS" | html_escape)</pre></details>
    <details><summary>SSL Certificate</summary><pre>$(echo "$OUT_SSL" | html_escape)</pre></details>
    <details><summary>Port Scan</summary><pre>$(echo "$OUT_PORTS" | html_escape)</pre></details>
  </div>
</div>
HTMLBLOCK
}

generate_html_report() {
    local HTML_REPORT="$REPORT_DIR/ReconX_Report_$(date +%Y%m%d_%H%M%S).html"

    cat > "$HTML_REPORT" << HTMLHEAD
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>ReconX Report</title>
<style>
  body { font-family: 'Segoe UI', Arial, sans-serif; background:#0f1117; color:#e6e6e6; margin:0; padding:20px; }
  .header { text-align:center; padding:20px; border-bottom:2px solid #2dd4bf; margin-bottom:30px; }
  .header h1 { color:#2dd4bf; margin:0; }
  .header p { color:#9ca3af; margin:5px 0; }
  .target-card { background:#161a23; border:1px solid #2a2f3a; border-radius:10px; padding:20px; margin-bottom:25px; }
  .target-card h2 { color:#38bdf8; border-bottom:1px solid #2a2f3a; padding-bottom:8px; }
  .category { margin:15px 0; padding:12px; border-radius:8px; }
  .category h3 { margin-top:0; }
  .network h3 { color:#facc15; }
  .dns h3 { color:#a78bfa; }
  .web h3 { color:#34d399; }
  .security h3 { color:#f87171; }
  details { background:#0f1117; border:1px solid #2a2f3a; border-radius:6px; margin:8px 0; padding:8px 12px; }
  summary { cursor:pointer; font-weight:bold; color:#e6e6e6; }
  pre { white-space:pre-wrap; word-wrap:break-word; color:#cbd5e1; font-size:13px; margin-top:8px; }
  .footer { text-align:center; color:#6b7280; margin-top:30px; font-size:13px; }
</style>
</head>
<body>
<div class="header">
  <h1>ReconX - Version ${VERSION} Recon Report</h1>
  <p>Generated: $(date)</p>
  <p>Developed by: ${AUTHOR}</p>
</div>
HTMLHEAD

    cat "$HTML_BODY_FILE" >> "$HTML_REPORT"

    cat >> "$HTML_REPORT" << HTMLFOOT
<div class="footer">ReconX Version ${VERSION} &mdash; Developed by ${AUTHOR} &mdash; For authorized use only.</div>
</body>
</html>
HTMLFOOT

    echo -e "${GREEN}${BOLD}[+] HTML report generated: $HTML_REPORT${NC}"
}

# ---------------------------- Recon Flow ---------------------------------------
start_recon() {
    banner
    echo -e "${CYAN}${BOLD}Recon Mode${NC}"
    echo " 1) Single Target (domain or IP)"
    echo " 2) Multiple Targets (from a file, one per line)"
    echo " 0) Back to Main Menu"
    echo ""
    read -rp "Select option: " rchoice

    targets=()

    case $rchoice in
        1)
            read -rp "Enter target domain or IP: " single_target
            targets+=("$single_target")
            ;;
        2)
            read -rp "Enter path to file containing URLs/domains (one per line): " filepath
            if [ ! -f "$filepath" ]; then
                echo -e "${RED}[!] File not found: $filepath${NC}"
                pause
                return
            fi
            while IFS= read -r line || [ -n "$line" ]; do
                line=$(echo "$line" | sed -e 's/^https\?:\/\///' -e 's/\/$//' | xargs)
                [ -z "$line" ] && continue
                [[ "$line" == \#* ]] && continue
                targets+=("$line")
            done < "$filepath"
            ;;
        0) return ;;
        *) echo -e "${RED}Invalid option.${NC}"; pause; return ;;
    esac

    if [ ${#targets[@]} -eq 0 ]; then
        echo -e "${RED}[!] No valid targets found.${NC}"
        pause
        return
    fi

    # sort targets alphabetically for a categorized/organized report
    IFS=$'\n' sorted_targets=($(sort <<<"${targets[*]}")); unset IFS

    HTML_BODY_FILE=$(mktemp)

    echo -e "${YELLOW}[*] Starting recon on ${#sorted_targets[@]} target(s)...${NC}"
    for t in "${sorted_targets[@]}"; do
        run_recon_for_target "$t"
    done

    generate_html_report
    rm -f "$HTML_BODY_FILE"

    pause
}

# ---------------------------- Main Menu -----------------------------------------
main_menu() {
    while true; do
        banner
        check_deps
        echo ""
        echo -e "${CYAN}${BOLD}Main Menu${NC}"
        echo " 1) Install Requirements / Tools"
        echo " 2) Start Recon (Single or Multiple Targets)"
        echo " 3) View Saved Reports"
        echo " 0) Exit"
        echo ""
        read -rp "Select an option: " mchoice

        case $mchoice in
            1) install_tools ;;
            2) start_recon ;;
            3)
                banner
                echo -e "${CYAN}Saved Reports in '$REPORT_DIR':${NC}"
                ls -la "$REPORT_DIR" 2>/dev/null
                pause
                ;;
            0) echo -e "${YELLOW}Goodbye. Recon responsibly.${NC}"; exit 0 ;;
            *) echo -e "${RED}Invalid option.${NC}"; sleep 1 ;;
        esac
    done
}

main_menu
