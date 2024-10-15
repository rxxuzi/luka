#!/bin/bash

# デフォルト値の設定
work_dir=""
remain_active=false
skip_torch=false
skip_xformers=false
output_help=""

# ヘルプメッセージの表示関数
show_help() {
    local help_message="使用方法: $0 [-d <work_directory>] [-r] [-s] [-x] [-o <output_file>] [-h]
  -d <work_directory>  作業ディレクトリ名を指定
  -r                   仮想環境をアクティブなままにする
  -s                   PyTorchのインストールをスキップ
  -x                   xformersのインストールをスキップ
  -o <output_file>     ヘルプメッセージを指定されたファイルに出力
  -h                   このヘルプメッセージを表示"

    if [ -n "$output_help" ]; then
        echo "$help_message" > "$output_help"
        echo "ヘルプメッセージを '$output_help' に出力しました。"
    else
        echo "$help_message"
    fi
}

# オプションの解析
while getopts ":d:rsxo:h" opt; do
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
        o )
            output_help=$OPTARG
            ;;
        h )
            show_help
            exit 0
            ;;
        \? )
            echo "無効なオプション: $OPTARG" 1>&2
            show_help
            exit 1
            ;;
        : )
            echo "オプション -$OPTARG には引数が必要です。" 1>&2
            show_help
            exit 1
            ;;
    esac
done

if [ -n "$output_help" ]; then
    exit 0
fi

if [ -z "$work_dir" ]; then
    read -p "作業ディレクトリ名を入力してください: " work_dir
fi

if [ ! -d "$work_dir" ]; then
    mkdir "$work_dir"
    echo "作業ディレクトリ '$work_dir' を作成しました。"
else
    echo "作業ディレクトリ '$work_dir' は既に存在します。"
fi

# 仮想環境ディレクトリを設定
venv_dir="$work_dir/venv"

# 仮想環境ディレクトリが存在しない場合は作成
if [ ! -d "$venv_dir" ]; then
    # Python仮想環境の作成
    python3 -m venv "$venv_dir"
    echo "Python仮想環境を '$venv_dir' に作成しました。"
else
    echo "仮想環境ディレクトリ '$venv_dir' は既に存在します。"
fi

# 仮想環境のアクティベート
source "$venv_dir/bin/activate"
echo "仮想環境をアクティベートしました。"

# pipのアップグレード
pip install --upgrade pip
echo "pipをアップグレードしました。"

if [ "$skip_torch" = false ]; then
    # 既存のPyTorchパッケージを削除し、キャッシュをクリア
    pip uninstall -y torch torchvision torchaudio
    pip cache purge
    echo "既存のPyTorchパッケージを削除し、キャッシュをクリアしました。"

    # CUDA バージョンの検出と選択
    detect_cuda_version() {
        local cuda_version=$(nvidia-smi | grep -oP "CUDA Version: \K[0-9]+\.[0-9]+")
        echo $cuda_version
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

        echo $pytorch_version
    }

    # CUDA バージョンの検出
    detected_cuda=$(detect_cuda_version)
    detected_pytorch=$(select_pytorch_version $detected_cuda)

    echo "検出された CUDA バージョン: $detected_cuda"
    echo "推奨される PyTorch バージョン: $detected_pytorch"
    echo "推奨: adeliae = cu118 , dumont = cu121"

    # ユーザーに確認
    if [[ -z "$detected_cuda" ]]; then
        echo "CUDA バージョンを検出できませんでした。"
        echo "利用可能な PyTorch バージョン:"
        echo "1) CUDA 11.8 (cu118) - adeliae 推奨"
        echo "2) CUDA 12.1 (cu121) - dumont 推奨"
        echo "3) CPU のみ (cpu)"
        read -p "使用する PyTorch バージョンを選択してください (1-3): " version_choice
        case $version_choice in
            1) pytorch_version="cu118" ;;
            2) pytorch_version="cu121" ;;
            3) pytorch_version="cpu" ;;
            *) echo "無効な選択です。CPU のみのバージョンを使用します。"; pytorch_version="cpu" ;;
        esac
    else
        read -p "検出された PyTorch バージョン ($detected_pytorch) を使用しますか? [Y/n]: " user_choice
        if [[ $user_choice =~ ^[Nn]$ ]]; then
            echo "利用可能な PyTorch バージョン:"
            echo "1) CUDA 11.8 (cu118) - adeliae 推奨"
            echo "2) CUDA 12.1 (cu121) - dumont 推奨"
            echo "3) CPU のみ (cpu)"
            read -p "使用する PyTorch バージョンを選択してください (1-3): " version_choice
            case $version_choice in
                1) pytorch_version="cu118" ;;
                2) pytorch_version="cu121" ;;
                3) pytorch_version="cpu" ;;
                *) echo "無効な選択です。デフォルトの $detected_pytorch を使用します。"; pytorch_version=$detected_pytorch ;;
            esac
        else
            pytorch_version=$detected_pytorch
        fi
    fi

    # PyTorch のインストール
    case $pytorch_version in
        cu118)
            pip install torch==2.3.0 torchvision==0.18.0 torchaudio==2.3.0 --index-url https://download.pytorch.org/whl/cu118
            echo "PyTorch 2.3.0 (CUDA 11.8) をインストールしました。"
            ;;
        cu121)
            pip install torch==2.3.0 torchvision==0.18.0 torchaudio==2.3.0 --index-url https://download.pytorch.org/whl/cu121
            echo "PyTorch 2.3.1 (CUDA 12.1) をインストールしました。"
            ;;
        cpu)
            pip install torch==2.3.1 torchvision==0.18.1 torchaudio==2.3.1 --index-url https://download.pytorch.org/whl/cpu
            echo "PyTorch 2.3.1 (CPU のみ) をインストールしました。"
            ;;
    esac
else
    echo "PyTorchのインストールをスキップしました。"
fi

if [ "$skip_xformers" = false ]; then
    # xformersをインストール
    pip install xformers
    echo "xformersをインストールしました。"
else
    echo "xformersのインストールをスキップしました。"
fi

# インストールの確認
if [ "$skip_torch" = false ]; then
    python -c "import torch; print('PyTorch version:', torch.__version__); print('CUDA available:', torch.cuda.is_available())"
    python -c "import torchvision; print('torchvision version:', torchvision.__version__)"
    python -c "import torchaudio; print('torchaudio version:', torchaudio.__version__)"
fi
if [ "$skip_xformers" = false ]; then
    python -c "import xformers; print('xformers version:', xformers.__version__)"
fi

# -r オプションが指定されていない場合は仮想環境を終了
if [ "$remain_active" = false ]; then
    deactivate
    echo "仮想環境を終了しました。"
else
    echo "仮想環境がアクティブなままです。終了するには 'deactivate' を実行してください。"
fi

echo "セットアップが完了しました。"
echo "作業ディレクトリ: $work_dir"
echo "仮想環境ディレクトリ: $venv_dir"
