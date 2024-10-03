# Nessus Agent Deployment Scripts

## Overview
A set of scripts for deploying a Nessus Agent for various operating systems. The scripts automate the process of downloading, installing, and linking a Nessus Agent to a remote Nessus Manager installation, provided that the endpoint on which the script is run can communicate with it. They also clean up previous installations, helping to remediate common issues with linking after reinstallation.

The scripts can be modified to work with an MDM solution for mass deployment.


## Supported Operating Systems

This repository provides deployment scripts for the following platforms:

* macOS
* Red Hat Enterprise Linux 7 (RHEL 7)/Amazon Linux 2 
* Red Hat Enterprise Linux 8 (RHEL 8)/Amazon Linux 3 
* Ubuntu 
* Windows 

## Installation

#### 0) Prerequisites

* Login to Nessus Manager
* Create a new agent group if needed
* Obtain linking key

<img width="720" alt="Agent Group" src="https://github.com/user-attachments/assets/9c1ae49a-e2c3-4f67-9a6a-31bbfa3abb83">

<img width="720" alt="Linking Key" src="https://github.com/user-attachments/assets/26c8ddaa-eb3f-46b5-8ab7-281ebb2ac31e">


#### 1) Clone this repository to your endpoint
```bash
git clone https://github.com/omerusmani/nessus-agent-scripts.git
```


#### 2) Navigate to the appropriate directory or folder for your OS
```bash
cd <OS-DIRECTORY>
```


#### 3) Edit Script
* Add Nessus Manager URL, Linking Key, and Agent Group.

* Linux & macOS
```bash
vim deploy_nessus_agent_<OS>.sh
```

* Windows
```bash
vim deploy_nessus_agent_<OS>.ps1
```

❗NOTE: VSCode was used for this example.
```bash
code deploy_nessus_agent_<OS>.ps1
```

<img width="720" alt="Edit Script" src="https://github.com/user-attachments/assets/cee24e6b-27fc-4a9f-8fb6-95c45447adad">


#### 4) Run Script
* Linux & macOS
```bash
chmod +x deploy_nessus_agent_<OS_NAME>.sh
./deploy_nessus_agent_<OS_NAME>.sh
```

* Windows
```bash
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope
.\deploy_nessus_agent_win.ps1
```

<img width="720" alt="Install Windows" src="https://github.com/user-attachments/assets/85cdb028-920c-41a9-9de5-8cfb4272e098">

❗NOTE: Download may take several minutes on Windows.


#### 5) Enter Agent Name & Confirm Linking
<img width="720" alt="Enter name   confirm" src="https://github.com/user-attachments/assets/1f6fd17c-7183-45d4-a4d7-473c06215772">



#### 6) Check Nessus Manager for Agent
<img width="720" alt="Screenshot 2024-09-20 at 10 47 28 PM" src="https://github.com/user-attachments/assets/2d76bd80-d31d-4ed4-a09d-17ca672470fa">


## Helpful Resources
* Official Tenable Nessus Agent Documentation:
https://docs.tenable.com/nessus-agent/10_7/Content/GettingStarted.htm
