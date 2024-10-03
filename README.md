# Nessus Agent Deployment Scripts

## Overview

A set of scripts for deploying a Nessus Agent for various operating systems. The scripts automate the process of downloading, installing and linking a Nessus Agent to a remote Nessus Manager installation, given that the endpoint the script is ran on can communicate with it. 

This script can be modified to work with an MDM solution for mass deployment. 

## Supported Operating Systems

This repository provides deployment scripts for the following platforms:

* MacOS
* Red Hat Enterprise Linux 7 (RHEL 7)/Amazon Linux 2 
* Red Hat Enterprise Linux 8 (RHEL 7)/Amazon Linux 3 
* Ubuntu 
* Windows 

## Installation

#### 0) Prerequisites

* Login to Nessus Manager
* Create a new agent group if needed
* Obtain linking key


<img width="395" alt="Agent Group" src="https://github.com/user-attachments/assets/9c1ae49a-e2c3-4f67-9a6a-31bbfa3abb83">

<img width="725" alt="Linking Key" src="https://github.com/user-attachments/assets/26c8ddaa-eb3f-46b5-8ab7-281ebb2ac31e">
