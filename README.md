<div align="center">
<img width="1145" height="196" alt="hermesbanner" src="https://i.ibb.co/Xrs7njHT/image.png" />


# *☤ W8HermesAgentTermux — Hermes Agent for Android (Termux)*

### *Run a Self-Evolving AI Assistant on Your Phone*

[![License: MIT](https://img.shields.io/badge/License-MIT-9146ff.svg?style=for-the-badge)](https://opensource.org/licenses/MIT)
[![Termux](https://img.shields.io/badge/Termux-Android-ff6b6b.svg?style=for-the-badge)](https://termux.com/)
[![Version](https://img.shields.io/badge/version-v0.10.0-4ecdc4.svg?style=for-the-badge)](https://github.com/NousResearch/hermes-agent)
[![Credit](https://img.shields.io/badge/Credit-W8Team%2FW8SOJIB-ffd93d.svg?style=for-the-badge)](https://github.com/NousResearch/hermes-agent)

**Transform your Android device into a powerful, learning AI assistant**

<h3 align="center">
  <img src="https://readme-typing-svg.demolab.com?font=Fira+Code&weight=600&size=20&duration=2800&pause=500&color=9146FF&center=true&vCenter=true&multiline=false&width=520&height=40&lines=W8HermesAgentTermux;%E2%98%A4+Hermes+Agent+for+Android;Self-evolving+AI+in+your+pocket;W8Team+%2F+W8SOJIB" alt="Typing animation" />
</h3>
</div>

## ✨ What is Hermes Agent?

> **Hermes Agent** is an open-source, self-evolving AI framework developed by [Nous Research](https://github.com/NousResearch/hermes-agent). It's like having **Jarvis in your pocket** - an AI that learns, adapts, and grows smarter with every interaction.

<div align="center">

| 🧠 Self-Learning | 🔄 Cross-Platform | 💾 Persistent Memory | 🛠️ 70+ Tools |
|:----------------:|:------------------:|:-------------------:|:-------------:|
| Gets smarter over time | Works on 16+ apps | Remembers your preferences | Execute complex tasks |

</div>

---

## ⏱️ Installation takes ~5-10 minutes - Grab a coffee! ☕
</div>

## Installation Preview:
```mermaid
graph LR
    A[📱 Open Termux] --> B[📋 Copy Command]
    B --> C[⚡ Paste & Run]
    C --> D[🔄 Auto-Install]
    D --> E[✅ Ready to Use!]
```

# 🚀 **One-Line Installation**

### **Copy and paste this command in Termux:**

```bash
curl -fsSL https://raw.githubusercontent.com/W8SOJIB/W8HermesAgentTermux/main/install.sh | bash
```

## 🛠️ Manual Installation (Recommended)
Prefer to do it yourself? Here's the step-by-step:
```
pkg install git
```
```
# 1. Clone this repository
git clone https://github.com/W8SOJIB/W8HermesAgentTermux.git
cd W8HermesAgentTermux

# 2. Make the script executable
chmod +x install.sh

# 3. Run the installer
./install.sh
```

---

## 📱 Full Termux Step-by-Step Guide

Everything command-level, from a fresh Termux install to a working agent. Run these **one by one** in Termux.

### 1️⃣ Set up Termux (first time)
```bash
# Allow external storage access (where you'll put / download files)
termux-setup-storage
# Grant it, then accept the storage permission popup on your phone.
```

### 2️⃣ Update all packages
```bash
pkg update -y
pkg upgrade -y
```

### 3️⃣ Core packages (needed by Hermes)
```bash
pkg install -y proot-distro git openssh curl wget python nodejs npm
```

### 4️⃣ Build / Python toolchain
```bash
pkg install -y clang make rust pkg-config libffi openssl binutils build-essential
```
> `python` already comes with `pip`. Install these too for smooth Python builds:
```bash
pkg install -y python-pip python3-setuptools wheel
```

### 5️⃣ Useful extras (recommended)
```bash
pkg install -y nano vim ripgrep ffmpeg unzip zip tar which
```

### 6️⃣ (Optional) Proot-Distro Ubuntu
> `proot-distro` lets you run a full Ubuntu Linux inside Termux — this is what `install.sh` uses.
```bash
pkg install -y proot-distro
proot-distro install ubuntu
proot-distro login ubuntu
```
> If it says `container 'ubuntu' already exists`, just run `proot-distro login ubuntu` — it's already there. ✅

### 7️⃣ Run W8HermesAgentTermux (one command does it all)
```bash
curl -fsSL https://raw.githubusercontent.com/W8SOJIB/W8HermesAgentTermux/main/install.sh | bash
```

### 8️⃣ Start Hermes
```bash
# log into the container (uses 'ubuntu' by default)
proot-distro login ubuntu

# first-time setup
hermes setup

# start chatting
hermes
```

### 🔁 Every package the installer pulls in, at a glance

| Purpose | Command |
|:--------|:--------|
| Base update | `pkg update -y && pkg upgrade -y` |
| Storage access | `termux-setup-storage` |
| Git | `pkg install -y git` |
| proot-distro (Ubuntu) | `pkg install -y proot-distro` |
| Python | `pkg install -y python` |
| Node.js | `pkg install -y nodejs` |
| Compiler toolchain | `pkg install -y clang make rust pkg-config libffi openssl build-essential` |
| Search/copy/edit | `pkg install -y ripgrep ffmpeg nano unzip zip` |
| Inside Ubuntu | `apt install -y python3 python3-pip python3-venv git curl build-essential nodejs npm` |

> **Tip:** In Termux, `pkg` = `apt`. You can swap `pkg install X` for `apt install X` — both work.

---

## 🤖 Start Agent
Run these commands one by one after installing
```
cd
proot-distro login ubuntu
```
```
cd hermes-agent
source venv/bin/activate
```
Run for setting it up
```
hermes setup
```
Run for using it
```
hermes
```
## Start gateway
```
hermes gateway
```

## ⚙️ System Requirements

| Requirement | Minimum | Recommended |
|:------------|:-------:|-------------:|
| **Android Version** | 11  |  13,14 or 15 |
| **Storage Space** | 3GB | 5GB+ |
| **RAM** | 2GB | 4GB+ |
| **Internet** | Required | Fast connection |
| **Termux** | Latest | Latest from F-Droid |


## 🌍 Why Run Hermes on Android?

| Benefit |  Description |
|:------------|:-------------:|
| **📱 Portable AI** | Your assistant goes everywhere  |
| **🔒 Privacy** | Runs locally on your device |
| **💰 Cost-effective** | No server hosting fees |
| **⚡ Low latency** | Direct execution |
| **🔄 Always available** | Works offline (with local models) |



## 🎛️ AI Model Freedom
Compatible with 200+ AI models including:

• OpenAI (GPT-4, GPT-3.5)

• Anthropic (Claude)

• Google (Gemini)

• DeepSeek

• Alibaba (Qwen)

• Zhipu (GLM)

• Local models via Ollama

## 🦙 Running Local Models with [Ollama](https://ollama.com)

### 📋 Installation

#### Install Ollama on Termux:
```
pkg install ollama
ollama serve
```
#### Pull & Run Models
```
ollama run gemma4:31b-cloud
```

## 🙏 Acknowledgments
• Nous Research - For creating the amazing Hermes Agent

• Termux Team - For making Android development possible

• Open Source Community - For the countless tools and libraries

• [W8SOJIB](https://github.com/NousResearch/hermes-agent) / **W8Team** — Lead Developer of **W8HermesAgentTermux**

• You - For using and supporting this project! ❤️

---

## 🐍 Contribution Snake (animated)

<img align="right" width="400" src="https://raw.githubusercontent.com/W8SOJIB/W8HermesAgentTermux/output/github-contribution-grid-snake.svg" alt="Contribution snake animation" />

This little guy eats your contribution grid. It's generated automatically by a
GitHub Action (`.github/workflows/snake.yml`) and updates every day at midnight UTC.

To trigger it manually: **Actions** tab → **Generate Snake Animation** → **Run workflow**.

<hr>

<div align="center">
    
## **⭐ If this helped you, give it a star! ⭐**
</div>

