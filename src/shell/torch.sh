#!/bin/bash

# 色の定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
RESET='\033[0m'

echo -e "${BOLD}${CYAN}===== システム情報 =====${RESET}"

# 仮想環境の確認
echo -e "${BOLD}${CYAN}===== Python環境情報 =====${RESET}"
if [[ -n "$VIRTUAL_ENV" ]]; then
    echo -e "${GREEN}現在の仮想環境: $VIRTUAL_ENV${RESET}"
else
    echo -e "${RED}仮想環境は使用されていません${RESET}"
fi

echo -e "${BOLD}Pythonのパス:${RESET} $(which python3)"
echo -e "${BOLD}Pythonバージョン:${RESET} $(python3 --version)"
echo ""

# NVIDIAドライバのバージョンとCUDAの情報を表示
echo -e "${BOLD}${CYAN}===== NVIDIAドライバ情報 =====${RESET}"

if command -v nvidia-smi &> /dev/null; then
    # 全体の情報を一度取得し、加工して表示
    DRIVER_INFO=$(nvidia-smi | grep -E 'Driver Version|CUDA Version')
    GPU_INFO=$(nvidia-smi | grep -A 1 "GPU  Name")

    # ドライババージョンとCUDAバージョンを抽出
    DRIVER_VERSION=$(echo "$DRIVER_INFO" | awk -F "Driver Version: " '{print $2}' | awk '{print $1}')
    CUDA_VERSION=$(echo "$DRIVER_INFO" | awk -F "CUDA Version: " '{print $2}' | awk '{print $1}')
    
    # GPUの名称を抽出
    GPU_NAME=$(echo "$GPU_INFO" | grep -oP '(?<=\|\s{3})[^|]+' | head -n 1 | awk '{$1=$1;print}')
    
    # 取得した情報を表示
    echo -e "${BOLD}ドライババージョン:${RESET} ${GREEN}$DRIVER_VERSION${RESET}"
    echo -e "${BOLD}CUDAバージョン:${RESET} ${GREEN}$CUDA_VERSION${RESET}"
    echo -e "${BOLD}GPU名称:${RESET} ${GREEN}$GPU_NAME${RESET}"
else
    echo -e "${RED}nvidia-smiコマンドが見つかりません。スクリプトを終了します。${RESET}"
    exit 1
fi

echo ""


# CUDAのバージョンを表示
echo -e "${BOLD}${CYAN}===== CUDA情報 =====${RESET}"
CUDA_VERSION=$(nvcc --version | grep release | awk '{print $5}' | sed 's/,//')
if [[ -n "$CUDA_VERSION" ]]; then
    echo -e "${BOLD}CUDAバージョン:${RESET} ${GREEN}$CUDA_VERSION${RESET}"
else
    echo -e "${RED}nvccコマンドが見つからないか、CUDAがインストールされていません。${RESET}"
fi

echo ""

# PyTorchの情報を取得
echo -e "${BOLD}${CYAN}===== PyTorch情報 =====${RESET}"
python3 -c "
try:
    import torch
    print('${BOLD}PyTorchバージョン:${RESET} ${GREEN}' + torch.__version__ + '${RESET}')
    print('${BOLD}CUDA利用可否:${RESET} ' + ('${GREEN}利用可能${RESET}' if torch.cuda.is_available() else '${RED}利用不可${RESET}'))
    if torch.cuda.is_available():
        print('${BOLD}使用中のCUDAバージョン:${RESET} ${GREEN}' + str(torch.version.cuda) + '${RESET}')
except ImportError:
    print('${RED}PyTorchがインストールされていないか、インポートできません。${RESET}')
"

echo ""

# torchaudioの情報を取得
echo -e "${BOLD}${CYAN}===== torchaudio情報 =====${RESET}"
python3 -c "
try:
    import torchaudio
    print('${BOLD}torchaudioバージョン:${RESET} ${GREEN}' + torchaudio.__version__ + '${RESET}')
except ImportError:
    print('${RED}torchaudioがインストールされていないか、インポートできません。${RESET}')
"

echo ""

# xformersの情報を取得
echo -e "${BOLD}${CYAN}===== xformers情報 =====${RESET}"
python3 -c "
try:
    import xformers
    print('${BOLD}xformersバージョン:${RESET} ${GREEN}' + xformers.__version__ + '${RESET}')
except ImportError:
    print('${RED}xformersがインストールされていないか、インポートできません。${RESET}')
"

echo ""

# その他の情報
echo -e "${BOLD}${CYAN}===== その他の情報 =====${RESET}"
echo -e "${BOLD}インストールされているtorch関連のパッケージ:${RESET}"
pip list | grep torch || echo -e "${RED}torch関連のパッケージが見つかりません${RESET}"
echo ""

# PyTorchでのGPU利用可能性確認
echo -e "${BOLD}GPUがPyTorchで利用可能か確認:${RESET}"
python3 -c "
try:
    import torch
    print('${BOLD}GPU利用可能:${RESET} ' + ('${GREEN}はい${RESET}' if torch.cuda.is_available() else '${RED}いいえ${RESET}'))
    if torch.cuda.is_available():
        print('${BOLD}利用可能なGPUの数:${RESET} ' + str(torch.cuda.device_count()))
except ImportError:
    print('${RED}PyTorchがインストールされていないか、インポートできません。${RESET}')
"

echo ""
echo -e "${BOLD}${CYAN}スクリプトの実行が完了しました。${RESET}"