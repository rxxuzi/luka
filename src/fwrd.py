#!/usr/bin/env python3
# -----------------------------------------------------------------------------
#  forward.py
#   - DESCRIPTION: Simple Port Forwarding Tool with optional public exposure via localhost.run
#   - AUTHOR      : github.com/rxxuzi
#   - LICENSE     : CC0
# -----------------------------------------------------------------------------

import argparse
import socket
import threading
import sys
import errno
import time
import subprocess
import re
import signal
import os

def parse_address(address, default_host=None):
    if address and ':' in address:
        try:
            host, port = address.rsplit(':', 1)
            port = int(port)
            return host, port
        except ValueError:
            print(f"アドレス '{address}' の形式が正しくありません。host:port または port の形式で指定してください。", file=sys.stderr)
            sys.exit(1)
    else:
        try:
            port = int(address) if address else None
            if port is not None:
                if default_host is not None:
                    return default_host, port
                else:
                    print(f"デスティネーションホストが指定されていません。ホスト:ポート または ポート の形式で指定してください。", file=sys.stderr)
                    sys.exit(1)
            else:
                print(f"ソースアドレスが指定されていません。", file=sys.stderr)
                sys.exit(1)
        except ValueError:
            print(f"ポート '{address}' が有効な整数ではありません。", file=sys.stderr)
            sys.exit(1)

def get_lan_ip():
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        s.connect(("8.8.8.8", 80))
        ip = s.getsockname()[0]
        s.close()
        return ip
    except Exception:
        return "127.0.0.1"

def find_available_port(host, port, log_enabled):
    current_port = port
    while current_port <= 65535:
        with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as sock:
            try:
                sock.bind((host, current_port))
                sock.listen(5)
                if log_enabled:
                    print(f"ポート {current_port} が使用可能です。")
                return current_port
            except OSError as e:
                if e.errno == errno.EADDRINUSE:
                    if log_enabled:
                        print(f"ポート {current_port} は既に使用されています。次のポートを試します。")
                    current_port += 1
                    continue
                else:
                    if log_enabled:
                        print(f"ポート {current_port} の確認中にエラーが発生しました: {e}", file=sys.stderr)
                    current_port += 1
                    continue
    return None

def handle_client(source, destination, log_enabled):
    try:
        with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as dst_sock:
            dst_sock.connect(destination)
            if log_enabled:
                print(f"接続確立: {source.getpeername()} -> {destination}")

            close_flag = threading.Event()

            def forward(src, dst, direction):
                try:
                    while not close_flag.is_set():
                        data = src.recv(4096)
                        if not data:
                            break
                        dst.sendall(data)
                except Exception as e:
                    if log_enabled:
                        print(f"転送エラー ({direction}): {e}", file=sys.stderr)
                finally:
                    close_flag.set()
                    try:
                        src.shutdown(socket.SHUT_RD)
                    except:
                        pass
                    try:
                        dst.shutdown(socket.SHUT_WR)
                    except:
                        pass

            thread1 = threading.Thread(target=forward, args=(source, dst_sock, "client->dst"), daemon=True)
            thread2 = threading.Thread(target=forward, args=(dst_sock, source, "dst->client"), daemon=True)
            thread1.start()
            thread2.start()
            thread1.join()
            thread2.join()

    except Exception as e:
        if log_enabled:
            print(f"接続エラー: {e}", file=sys.stderr)
    finally:
        try:
            source.close()
        except:
            pass

def start_forwarding(src_host, src_port, dst_host, dst_port, log_enabled, shutdown_event):
    final_dst_port = find_available_port(dst_host, dst_port, log_enabled)
    if final_dst_port is None:
        print(f"エラー: 使用可能なポートが見つかりませんでした。ポート範囲 {dst_port}-65535 を確認してください。", file=sys.stderr)
        sys.exit(1)

    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as server:
        try:
            server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
            server.bind((dst_host, final_dst_port))
            server.listen(5)
            if log_enabled:
                print(f"フォワーディング開始: {dst_host}:{final_dst_port} -> {src_host}:{src_port}")

            while not shutdown_event.is_set():
                try:
                    server.settimeout(1.0)
                    client, addr = server.accept()
                except socket.timeout:
                    continue
                except OSError as e:
                    if shutdown_event.is_set():
                        break
                    else:
                        raise e

                if log_enabled:
                    print(f"接続受信: {addr}")

                threading.Thread(
                    target=handle_client,
                    args=(client, (src_host, src_port), log_enabled),
                    daemon=True
                ).start()

        except OSError as e:
            if e.errno == errno.EADDRINUSE:
                print(f"エラー: ポート {final_dst_port} は既に使用されています。別のポートを指定してください。", file=sys.stderr)
            else:
                print(f"サーバーエラー: {e}", file=sys.stderr)
            sys.exit(1)
        except Exception as e:
            print(f"サーバーエラー: {e}", file=sys.stderr)
            sys.exit(1)

    return final_dst_port

def check_src_accessible(src_host, src_port):
    try:
        with socket.create_connection((src_host, src_port), timeout=3):
            return True
    except Exception as e:
        print(f"ソースアドレス {src_host}:{src_port} に接続できません: {e}", file=sys.stderr)
        return False

def show_help():
    help_text = """
Luka Tunnel - Simple Port Forwarding Tool

Usage:
  luka tunnel <src> [dst] [options]

Source:
  <src>               ソースアドレス (host:port または port)
                     ポートのみ指定の場合は localhost:port と解釈

Destination:
  [dst]               デスティネーションアドレス (host:port または port)
                     省略時は 0.0.0.0:10130
                     ポートのみ指定の場合は 0.0.0.0:port と解釈

Options:
  --public, -p        外部に公開するためのトンネルを開始します。
  --verbose, -v       詳細なログを表示します。
  --help, -h          このヘルプメッセージを表示します。

Examples:
  luka tunnel localhost:8080
  luka tunnel 8080 --verbose
  luka tunnel localhost:8080 0.0.0.0:9800 --verbose
  luka tunnel 8080 --public
    """
    print(help_text)

def is_port_in_use(port):
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        return s.connect_ex(('localhost', port)) == 0

def signal_handler(sig, frame):
    print("\nCtrl+C received. Terminating the tunnel...")
    if 'tunnel_process' in globals():
        os.killpg(os.getpgid(tunnel_process.pid), signal.SIGTERM)
        tunnel_process.wait()
    sys.exit(0)

def start_tunnel(port):
    global tunnel_process
    command = f'ssh -R 80:localhost:{port} ssh.localhost.run'  # ホスト名を明示的に指定
    signal.signal(signal.SIGINT, signal_handler)
    signal.signal(signal.SIGTERM, signal_handler)  # SIGTERMもハンドル

    while True:
        try:
            print(f"Starting tunnel for localhost:{port}")
            tunnel_process = subprocess.Popen(
                command,
                shell=True,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                universal_newlines=True,
                preexec_fn=os.setsid  # プロセスグループを設定
            )

            url_found = False
            for line in tunnel_process.stdout:
                print(line.strip())  # デバッグ用に出力
                # 'localhost.run' の出力からURLを抽出
                match = re.search(r'https?://[^\s]+', line)
                if match:
                    print(f"\nTunnel URL: {match.group(0)}\n")
                    url_found = True
                    break  # URLを見つけたらループを抜ける

            if not url_found:
                print("外部公開URLが見つかりませんでした。出力を確認してください。", file=sys.stderr)

            tunnel_process.wait()

        except subprocess.CalledProcessError as e:
            print(f"Error occurred: {e}")
        except KeyboardInterrupt:
            print("\nKeyboardInterrupt received. Terminating the tunnel...")
            os.killpg(os.getpgid(tunnel_process.pid), signal.SIGTERM)
            tunnel_process.wait()
            sys.exit(0)
        except Exception as e:
            print(f"Unexpected error: {e}", file=sys.stderr)

        print("Tunnel closed. Restarting in 5 seconds...")
        time.sleep(5)

def main():
    parser = argparse.ArgumentParser(add_help=False)
    parser.add_argument("src", nargs='?', help="ソースアドレス (host:port または port)")
    parser.add_argument("dst", nargs='?', default=None, help="デスティネーションアドレス (host:port または port)。省略時は0.0.0.0:10130を使用。")
    parser.add_argument("--public", "-p", action="store_true", help="外部に公開するためのトンネルを開始します。")
    parser.add_argument("--verbose", "-v", action="store_true", help="詳細なログを表示します。")
    parser.add_argument("--help", "-h", action="store_true", help="このヘルプメッセージを表示します。")

    args = parser.parse_args()

    if args.help or not args.src:
        show_help()
        sys.exit(0)

    log_enabled = args.verbose

    # ソースアドレスの解析
    src_host, src_port = parse_address(args.src, default_host="localhost")

    # デスティネーションアドレスの設定
    if args.dst:
        dst_host, dst_port = parse_address(args.dst, default_host="0.0.0.0")
    else:
        dst_host, dst_port = "0.0.0.0", 10130

    # ソースアドレスへの疎通をチェック
    if not check_src_accessible(src_host, src_port):
        sys.exit(1)

    # LAN IP取得
    if dst_host == "0.0.0.0":
        lan_ip = get_lan_ip()
        accessible_url = f"http://{lan_ip}:{dst_port}"
    elif dst_host == "127.0.0.1":
        accessible_url = f"http://localhost:{dst_port}"
    else:
        accessible_url = f"http://{dst_host}:{dst_port}"

    print(f"ローカルでのアクセスURL: {accessible_url}")

    shutdown_event = threading.Event()

    if args.public:
        # 公開モード: サーバーをバックグラウンドで起動し、トンネルを開始
        final_port_container = {}

        def server_func():
            port = start_forwarding(src_host, src_port, dst_host, dst_port, log_enabled, shutdown_event)
            final_port_container['port'] = port

        server_thread = threading.Thread(target=server_func, daemon=True)
        server_thread.start()

        # サーバーが利用可能なポートを取得するまで待機
        while 'port' not in final_port_container:
            time.sleep(0.1)
        final_port = final_port_container['port']

        # トンネル開始
        start_tunnel(final_port)
    else:
        # 公開モードでない場合、通常のフォワーディング開始
        final_port = start_forwarding(src_host, src_port, dst_host, dst_port, log_enabled, shutdown_event)
        if dst_host == "0.0.0.0":
            accessible_url = f"http://{lan_ip}:{final_port}"
        elif dst_host == "127.0.0.1":
            accessible_url = f"http://localhost:{final_port}"
        else:
            accessible_url = f"http://{dst_host}:{final_port}"
        print(f"アクセス可能なURL: {accessible_url}")
        try:
            # メインスレッドを待機（Ctrl+C で終了）
            while True:
                time.sleep(1)
        except KeyboardInterrupt:
            print("\nシャットダウン中...")
            shutdown_event.set()
            sys.exit(0)

if __name__ == "__main__":
    main()
