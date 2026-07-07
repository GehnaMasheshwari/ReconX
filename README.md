<h1 align="center">RECONX v1.0</h1>

<p align="center">
  <b>Bash Based Information Gathering & Reconnaissance Automation Framework</b><br>
  <i>Fast • Lightweight • Automated • Organized • Ethical Security Research Focused</i>
</p>

<p align="center">
  <img src="assets/reconx-cover.png" alt="ReconX Cover">
</p>

<p align="center">
  <img alt="Version" src="https://img.shields.io/badge/version-v1.0-red.svg">
  <img alt="Platform" src="https://img.shields.io/badge/platform-Kali%20Linux-black.svg">
  <img alt="Language" src="https://img.shields.io/badge/Bash-Script-success.svg">
  <img alt="Status" src="https://img.shields.io/badge/status-Active-brightgreen.svg">
  <img alt="License" src="https://img.shields.io/badge/license-Educational-blue.svg">
</p>

---

# Overview

**ReconX v1.0** is a lightweight and powerful **Bash-based Information Gathering and Recon Automation Tool** built for:

- Security Researchers
- Ethical Hackers
- Penetration Testers
- Students
- Bug Bounty Hunters

ReconX automates the initial reconnaissance phase by collecting important information about authorized targets and generating clean reports automatically.

Instead of running multiple commands manually, ReconX combines essential recon tasks into a single workflow.

---

# Features

## Network Information

- ICMP Ping Testing
- Target Reachability Check
- Packet Loss Detection
- Response Time Analysis

---

## DNS Information

- DNS Lookup
- DNS Record Enumeration
- A Record Collection
- AAAA Record Collection
- MX Record Collection
- TXT Record Collection
- NS Record Collection

---

## IP Intelligence

- IP Resolution
- GeoIP Lookup
- ISP Information Collection
- Location Information Gathering

---

## Domain Intelligence

- WHOIS Lookup
- Registrar Information
- Domain Creation Date
- Domain Expiry Date
- Name Server Collection
- DNSSEC Detection

---

## Web Information

- HTTP Header Collection
- HTTP Status Code Detection
- robots.txt Retrieval
- Technology Fingerprinting

---

## Security Analysis

- Security Header Analysis
- SSL/TLS Certificate Inspection
- Fast Port Scanning
- Service Detection

---

## Report Generation

ReconX automatically generates:

- HTML Reports
- TXT Reports
- Categorized Results
- Organized Output

---

# Modules Included

ReconX currently includes **13 automated modules**:

1. Ping Scan
2. DNS Lookup
3. DNS Record Enumeration
4. IP Resolution
5. GeoIP Lookup
6. WHOIS Lookup
7. Port Scan
8. HTTP Header Collection
9. Security Header Analysis
10. HTTP Status Detection
11. robots.txt Retrieval
12. SSL Certificate Analysis
13. Technology Detection

---

# Installation

## Clone Repository

```bash
git clone https://github.com/YOUR_USERNAME/ReconX.git
```

---

## Move into Directory

```bash
cd ReconX
```

---

## Give Execute Permission

```bash
chmod +x reconx.sh
```

---

## Run ReconX

```bash
./reconx.sh
```

---

# Dependency Installation

ReconX automatically installs required packages.

Required tools include:

- ping
- nslookup
- whois
- nmap
- curl
- openssl
- dig
- whatweb

Simply select:

```text
1) Install Requirements / Tools
```

and ReconX will handle the rest automatically.

---

# Main Menu

When ReconX starts you will see:

```text
1) Install Requirements / Tools
2) Start Recon (Single or Multiple Targets)
3) View Saved Reports
0) Exit
```

---

# Usage

## Scan Single Target

Choose:

```text
2) Start Recon
```

Then:

```text
1) Single Target
```

Example:

```text
example.com
```

---

## Scan Multiple Targets

Choose:

```text
2) Start Recon
```

Then:

```text
2) Multiple Targets
```

Create a file:

```text
targets.txt
```

Example:

```text
example.com
example.org
example.net
```

Run the scan and ReconX will process all targets automatically.

---

# Generated Reports

ReconX creates a dedicated reports directory:

```text
reports/

├── report_example_20260707_192000.txt
├── report_example_20260707_192000.html
└── ReconX_Report_20260707_192000.html
```

---

# HTML Report Features

- Modern Dark Theme
- Organized Categories
- Expandable Sections
- Easy Navigation
- Multiple Target Support
- Professional Layout

---

# Supported Platforms

- Kali Linux
- Parrot OS
- Ubuntu
- Debian Based Distributions

---

# Why ReconX?

✔ Lightweight  
✔ Bash Powered  
✔ Beginner Friendly  
✔ Automated Reports  
✔ Multiple Target Support  
✔ Easy Installation  
✔ Clean Interface  
✔ Fast Recon Workflow  

---

# Author

## 👤 Gehna Maheshwari

- GitHub: https://github.com/YOUR_USERNAME
- LinkedIn: https://linkedin.com/in/YOUR_PROFILE

---

# Disclaimer

ReconX is intended for:

- Educational Purposes
- Authorized Security Assessments
- Internal Testing Environments
- Ethical Hacking Practice

Do not use this tool against systems you do not own or do not have explicit authorization to test.

Unauthorized usage may violate laws and regulations in your jurisdiction.

---

# License

Copyright © 2026 Gehna Maheshwari.

This project is released for educational and authorized security research purposes only.

---

<p align="center">
  <b>RECON. ENUMERATE. ANALYZE.</b><br>
  <i>Built with Bash. Designed for Ethical Hackers.</i>
</p>
