#!/data/data/com.termux/files/usr/bin/bash
# ROHIT RAINBOW TERMUX SETUP
# Broad, practical package installer for Termux.
# It intentionally does NOT install every package in the repositories:
# doing so can consume huge storage, create conflicts, and break the environment.

set +e
LOG="$HOME/rohit-install.log"
: > "$LOG"

clear 2>/dev/null

rainbow_banner() {
  local frames=2 shift i color text
  text=" R O H I T "
  for ((frames=0; frames<2; frames++)); do
    printf "\r"
    for ((i=0; i<${#text}; i++)); do
      color=$((31 + ((i + frames) % 7)))
      printf '\033[1;%sm%s\033[0m' "$color" "${text:i:1}"
    done
    printf "  \033[1;36mTERMUX ALL-IN-ONE SETUP\033[0m\n"
    sleep 0.18
  done
  printf '\033[1;35m╔══════════════════════════════════════════════╗\033[0m\n'
  printf '\033[1;36m║\033[0m  \033[1;31mR\033[1;33mO\033[1;32mH\033[1;36mI\033[1;34mT\033[1;35m  \033[1;37mRAINBOW INSTALLER\033[1;36m             ║\033[0m\n'
  printf '\033[1;35m╚══════════════════════════════════════════════╝\033[0m\n'
  printf '\033[1;33mPackages are attempted one by one; failures are logged.\033[0m\n'
  printf '\033[1;33mThis installs a broad useful set, NOT every repository package.\033[0m\n\n'
}

rainbow_banner

if ! command -v pkg >/dev/null 2>&1; then
  echo "ERROR: Run this script inside Termux."
  exit 1
fi

run_logged() {
  echo
  printf '\033[1;36m>>> %s\033[0m\n' "$*"
  "$@" >>"$LOG" 2>&1
  local result=$?
  if [ "$result" -eq 0 ]; then
    printf '\033[1;32m[ OK ]\033[0m %s\n' "$*"
  else
    printf '\033[1;31m[ SKIP/FAIL ]\033[0m %s  (see %s)\n' "$*" "$LOG"
  fi
  return 0
}

install_termux_packages() {
  local package
  for package in "$@"; do
    run_logged pkg install -y "$package"
  done
}

echo -e "\033[1;35m[1/5] Updating Termux\033[0m"
run_logged pkg update -y
run_logged pkg upgrade -y

echo
echo -e "\033[1;35m[2/5] Installing common system, network, archive and developer packages\033[0m"
install_termux_packages \
  python python-pip git gh \
  curl wget aria2 rsync openssh \
  nano vim less micro \
  clang make cmake ninja rust golang nodejs \
  openssl libffi libxml2 libxslt \
  tar unzip zip p7zip gzip bzip2 xz-utils \
  coreutils findutils grep sed gawk diffutils file which \
  procps psmisc tree htop tmux screen \
  jq yq \
  dnsutils inetutils iproute2 net-tools \
  termux-tools termux-api \
  sqlite mariadb postgresql \
  perl ruby php \
  ffmpeg imagemagick \
  freetype libjpeg-turbo libpng zlib liblzma \
  man proot proot-distro \
  patch binutils pkg-config

echo
echo -e "\033[1;35m[3/5] Installing common Python libraries\033[0m"
if command -v python >/dev/null 2>&1; then
  # Do not upgrade pip separately; Termux manages it with python-pip.
  for package in \
    requests urllib3 certifi idna charset-normalizer \
    beautifulsoup4 html5lib lxml \
    rich colorama tqdm tabulate prettytable \
    pyyaml toml python-dotenv packaging setuptools wheel \
    six typing-extensions \
    aiohttp httpx websockets \
    flask fastapi uvicorn pydantic \
    attrs chardet dateparser python-dateutil \
    psutil platformdirs cryptography pyOpenSSL \
    dnspython validators tenacity retrying \
    jinja2 markupsafe typer click pytest \
    pillow numpy pandas \
    sqlalchemy aiosqlite \
    markdown pygments \
    loguru structlog \
    jsonschema \
    scikit-learn; do
      printf '\n\033[1;36m>>> pip package: %s\033[0m\n' "$package"
      python -m pip install --disable-pip-version-check "$package" >>"$LOG" 2>&1
      result=$?
      if [ "$result" -eq 0 ]; then
        printf '\033[1;32m[ OK ]\033[0m %s\n' "$package"
      else
        printf '\033[1;31m[ SKIP/FAIL ]\033[0m %s (see log)\n' "$package"
      fi
  done
else
  echo "Python not found; skipping pip packages."
fi

echo
echo -e "\033[1;35m[4/5] Repository discovery helpers\033[0m"
echo "To see ALL package names available from your configured Termux repos:"
echo "  pkg list-all"
echo "To see installed Termux packages:"
echo "  pkg list-installed"
echo "To see installed Python packages:"
echo "  python -m pip list"
echo
echo "The script deliberately does not install every available package or every PyPI project."
echo "That would be extremely large, may cause conflicts, and cannot guarantee compatibility."

echo
echo -e "\033[1;35m[5/5] Summary\033[0m"
python --version 2>&1
git --version 2>&1
python -m pip list 2>&1 | tee -a "$LOG"
echo
printf '\033[1;32mROHIT setup attempt finished.\033[0m\n'
printf 'Log saved to: %s\n' "$LOG"
printf 'If anything failed, inspect the log with: less %s\n' "$LOG"
