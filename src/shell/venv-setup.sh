#!/bin/bash

# 色の定義
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # 色なし

# スピナーの定義
spin() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    while kill -0 "$pid" 2>/dev/null; do
        for char in ${spinstr}; do
            printf " [%c]  " "$char"
            sleep "$delay"
            printf "\b\b\b\b\b\b"
        done
    done
    printf "    \b\b\b\b"
}

# デフォルト値の設定
work_dir=""
remain_active=false
skip_torch=false
skip_xformers=false
verbose=false

# ヘルプメッセージの表示関数
show_help() {
    local help_message="使用方法: luka venv [-d <work_directory>] [-r] [-s] [-x] [-v] [-h]
  -d <work_directory>  作業ディレクトリ名を指定
  -r                   仮想環境をアクティブなままにする
  -s                   PyTorchのインストールをスキップ
  -x                   xformersのインストールをスキップ
  -v,                  詳細なログを表示
  -h                   このヘルプメッセージを表示"

    echo -e "$help_message"
}

# ログ出力関数
log() {
    local level=$1
    local message=$2
    if [ "$verbose" = true ]; then
        case $level in
            "info")
                echo -e "${BLUE}$message${NC}"
                ;;
            "success")
                echo -e "${GREEN}$message${NC}"
                ;;
            "warning")
                echo -e "${YELLOW}$message${NC}"
                ;;
            "error")
                echo -e "${RED}$message${NC}" >&2
                ;;
            *)
                echo "$message"
                ;;
        esac
    else
        case $level in
            "success")
                echo -e "${GREEN}$message${NC}"
                ;;
            "error")
                echo -e "${RED}$message${NC}" >&2
                ;;
            *)
                echo "$message"
                ;;
        esac
    fi
}

# オプションの解析
# サポートするオプション: d, r, s, x, v, h
while getopts ":d:rsxvh-:" opt; do
    case ${opt} in
        d )
            work_dir=$OPTARG
            ;;
        r )
            remain_active=true
            ;;
        s )
            skip_torch=true
            ;;
        x )
            skip_xformers=true
            ;;
        v )
            verbose=true
            ;;
        - )
            case "${OPTARG}" in
                verbose)
                    verbose=true
                    ;;
                *)
                    show_help
                    exit 1
                    ;;
            esac
            ;;
        h )
            show_help
            exit 0
            ;;
        \? )
            log "error" "無効なオプション: -$OPTARG"
            show_help
            exit 1
            ;;
        : )
            log "error" "オプション -$OPTARG には引数が必要です。"
            show_help
            exit 1
            ;;
    esac
done

shift $((OPTIND -1))

# -o オプションは削除されたため、その処理も削除

if [ -z "$work_dir" ]; then
    read -p "$(echo -e "${CYAN}作業ディレクトリ名を入力してください: ${NC}")" work_dir
fi

if [ ! -d "$work_dir" ]; then
    log "info" "作業ディレクトリ '$work_dir' を作成しています..."
    mkdir "$work_dir" &
    spin $!
    wait $!
    log "success" "作業ディレクトリ '$work_dir' を作成しました。"
else
    log "warning" "作業ディレクトリ '$work_dir' は既に存在します。"
fi

# 仮想環境ディレクトリを設定
venv_dir="$work_dir/venv"

# 仮想環境ディレクトリが存在しない場合は作成
if [ ! -d "$venv_dir" ]; then
    log "info" "Python仮想環境を '$venv_dir' に作成しています..."
    python3 -m venv "$venv_dir" &
    spin $!
    wait $!
    log "success" "Python仮想環境を '$venv_dir' に作成しました。"
else
    log "warning" "仮想環境ディレクトリ '$venv_dir' は既に存在します。"
fi

# 仮想環境のアクティベート
source "$venv_dir/bin/activate"
log "success" "仮想環境をアクティベートしました。"

# pipのアップグレード
log "info" "pipをアップグレードしています..."
pip install --upgrade pip &
spin $!
wait $!
log "success" "pipをアップグレードしました。"

if [ "$skip_torch" = false ]; then
    log "info" "PyTorchのセットアップを開始します..."

    # 既存のPyTorchパッケージを削除し、キャッシュをクリア
    log "info" "既存のPyTorchパッケージを削除し、キャッシュをクリアしています..."
    pip uninstall -y torch torchvision torchaudio &
    spin $!
    wait $!
    pip cache purge &
    spin $!
    wait $!
    log "success" "既存のPyTorchパッケージを削除し、キャッシュをクリアしました。"

    # CUDA バージョンの検出と選択
    detect_cuda_version() {
        if command -v nvcc &> /dev/null; then
            # nvcc が利用可能な場合
            nvcc_output=$(nvcc --version)
            cuda_version=$(echo "$nvcc_output" | grep -oP "release \K[0-9]+\.[0-9]+")
        elif command -v nvidia-smi &> /dev/null; then
            # nvidia-smi が利用可能な場合
            cuda_version=$(nvidia-smi | grep -oP "CUDA Version: \K[0-9]+\.[0-9]+")
        else
            cuda_version=""
        fi
        echo "$cuda_version"
    }

    select_pytorch_version() {
        local cuda_version=$1
        local pytorch_version

        if (( $(echo "$cuda_version >= 12.0" | bc -l) )); then
            pytorch_version="cu121"
        elif (( $(echo "$cuda_version >= 11.8" | bc -l) )); then
            pytorch_version="cu118"
        else
            pytorch_version="cpu"
        fi

        echo "$pytorch_version"
    }

    # CUDA バージョンの検出
    detected_cuda=$(detect_cuda_version)
    detected_pytorch=$(select_pytorch_version "$detected_cuda")

    if [ -n "$detected_cuda" ]; then
        log "info" "検出された CUDA バージョン: $detected_cuda"
        log "info" "推奨される PyTorch バージョン: $detected_pytorch"
    else
        log "warning" "CUDA バージョンを検出できませんでした。"
    fi

    # ユーザーに確認
    if [[ -z "$detected_cuda" ]]; then
        echo "利用可能な PyTorch バージョン:"
        echo "1) CUDA 11.8 (cu118)"
        echo "2) CUDA 12.1 (cu121)"
        echo "3) CPU のみ (cpu)"
        read -p "$(echo -e "${CYAN}使用する PyTorch バージョンを選択してください (1-3): ${NC}")" version_choice
        case $version_choice in
            1) pytorch_version="cu118" ;;
            2) pytorch_version="cu121" ;;
            3) pytorch_version="cpu" ;;
            *) 
                log "warning" "無効な選択です。CPU のみのバージョンを使用します。"
                pytorch_version="cpu" 
                ;;
        esac
    else
        read -p "$(echo -e "${CYAN}検出された PyTorch バージョン ($detected_pytorch) を使用しますか? [Y/n]: ${NC}")" user_choice
        if [[ $user_choice =~ ^[Nn]$ ]]; then
            echo "利用可能な PyTorch バージョン:"
            echo "1) CUDA 11.8 (cu118)"
            echo "2) CUDA 12.1 (cu121)"
            echo "3) CPU のみ (cpu)"
            read -p "$(echo -e "${CYAN}使用する PyTorch バージョンを選択してください (1-3): ${NC}")" version_choice
            case $version_choice in
                1) pytorch_version="cu118" ;;
                2) pytorch_version="cu121" ;;
                3) pytorch_version="cpu" ;;
                *) 
                    log "warning" "無効な選択です。デフォルトの $detected_pytorch を使用します。"
                    pytorch_version=$detected_pytorch 
                    ;;
            esac
        else
            pytorch_version=$detected_pytorch
        fi
    fi

    # PyTorch のインストール
    log "info" "PyTorch をインストールしています..."
    case $pytorch_version in
        cu118)
            pip install torch==2.3.0 torchvision==0.18.0 torchaudio==2.3.0 --index-url https://download.pytorch.org/whl/cu118 &
            ;;
        cu121)
            pip install torch==2.3.1 torchvision==0.18.1 torchaudio==2.3.1 --index-url https://download.pytorch.org/whl/cu121 &
            ;;
        cpu)
            pip install torch==2.3.1 torchvision==0.18.1 torchaudio==2.3.1 --index-url https://download.pytorch.org/whl/cpu &
            ;;
    esac
    spin $!
    wait $!
    case $pytorch_version in
        cu118)
            log "success" "PyTorch 2.3.0 (CUDA 11.8) をインストールしました。"
            ;;
        cu121)
            log "success" "PyTorch 2.3.1 (CUDA 12.1) をインストールしました。"
            ;;
        cpu)
            log "success" "PyTorch 2.3.1 (CPU のみ) をインストールしました。"
            ;;
    esac
fi

if [ "$skip_xformers" = false ]; then
    log "info" "xformersをインストールしています..."
    pip install xformers &
    spin $!
    wait $!
    log "success" "xformersをインストールしました。"
else
    log "warning" "xformersのインストールをスキップしました。"
fi

# インストールの確認
log "info" "インストールの確認を行っています..."
if [ "$skip_torch" = false ]; then
    python -c "import torch; print('${GREEN}PyTorch version:${NC}', torch.__version__); print('${GREEN}CUDA available:${NC}', torch.cuda.is_available())"
    python -c "import torchvision; print('${GREEN}torchvision version:${NC}', torchvision.__version__)"
    python -c "import torchaudio; print('${GREEN}torchaudio version:${NC}', torchaudio.__version__)"
fi
if [ "$skip_xformers" = false ]; then
    python -c "import xformers; print('${GREEN}xformers version:${NC}', xformers.__version__)"
fi

# -r オプションが指定されていない場合は仮想環境を終了
if [ "$remain_active" = false ]; then
    deactivate
    log "success" "仮想環境を終了しました。"
else
    log "warning" "仮想環境がアクティブなままです。終了するには 'deactivate' を実行してください。"
fi

log "success" "セットアップが完了しました。"
log "success" "作業ディレクトリ: $work_dir"
log "success" "仮想環境ディレクトリ: $venv_dir"
