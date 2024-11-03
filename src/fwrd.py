#!/usr/bin/env python3
import argparse
import socket
import threading
import sys
import errno
import time
import ipaddress

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

def get_lan_ip(prefer_ethernet=True):
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        # ダミーの接続で自身のLAN IPを取得
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

def check_ip_allowed(client_ip, allow_list, deny_list):
    try:
        client_ip_obj = ipaddress.ip_address(client_ip)
    except ValueError:
        return False  # 無効なIPアドレスは拒否

    # 拒否リストのチェック
    if deny_list:
        for cidr in deny_list:
            if client_ip_obj in cidr:
                return False
    # 許可リストのチェック
    if allow_list:
        for cidr in allow_list:
            if client_ip_obj in cidr:
                return True
        return False  # 許可リストが指定されている場合、リストにないものは拒否
    return True  # 許可リストが指定されていない場合、全て許可

def handle_client(source, destination, log_enabled, timeout, bandwidth, auth_password, allow_list, deny_list):
    client_ip = source.getpeername()[0]
    
    # IPフィルタリング
    if not check_ip_allowed(client_ip, allow_list, deny_list):
        if log_enabled:
            print(f"接続拒否: {client_ip} は許可されていません。")
        source.close()
        return
    
    # 認証
    if auth_password:
        try:
            source.settimeout(timeout)
            source.sendall(b"Password: ")
            received_password = source.recv(1024).decode().strip()
            if received_password != auth_password:
                if log_enabled:
                    print(f"認証失敗: {client_ip} からの接続が拒否されました。")
                source.sendall(b"Authentication failed.\n")
                source.close()
                return
            else:
                source.sendall(b"Authentication successful.\n")
                if log_enabled:
                    print(f"認証成功: {client_ip} が接続しました。")
        except Exception as e:
            if log_enabled:
                print(f"認証エラー: {e}", file=sys.stderr)
            source.close()
            return
    
    try:
        with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as src_sock:
            src_sock.settimeout(timeout)
            src_sock.connect(destination)
            if log_enabled:
                print(f"接続確立: {source.getpeername()} -> {destination}")
            close_flag = threading.Event()

            def forward(src, dst, direction):
                """データをsrcからdstへ転送します。帯域幅制限を適用します。"""
                try:
                    while not close_flag.is_set():
                        data = src.recv(4096)
                        if not data:
                            break
                        dst.sendall(data)
                        if bandwidth:
                            time.sleep(len(data) / (bandwidth * 1024))  # KB/sに基づく遅延
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

            # 双方向転送スレッドの作成
            thread1 = threading.Thread(target=forward, args=(source, src_sock, "S->D"), daemon=True)
            thread2 = threading.Thread(target=forward, args=(src_sock, source, "D->S"), daemon=True)
            thread1.start()
            thread2.start()
            thread1.join()
            thread2.join()
    except Exception as e:
        if log_enabled:
            print(f"接続エラー: {e}", file=sys.stderr)
        # 特定のエラーコードに基づくメッセージ
        if isinstance(e, OSError) and e.errno == 10049:
            print("エラー: 要求したアドレスのコンテキストが無効です。ソースサーバーが起動していることを確認してください。", file=sys.stderr)
    finally:
        try:
            source.close()
        except:
            pass

def start_forwarding(src_host, src_port, dst_host, dst_port, log_enabled, shutdown_event, timeout, bandwidth, auth_password, allow_list, deny_list):
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
                    server.settimeout(1.0)  # 1秒間隔でタイムアウト
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
                    args=(client, (src_host, src_port), log_enabled, timeout, bandwidth, auth_password, allow_list, deny_list),
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

def check_src_accessible(src_host, src_port, timeout):
    try:
        with socket.create_connection((src_host, src_port), timeout=timeout):
            return True
    except Exception as e:
        print(f"ソースアドレス {src_host}:{src_port} に接続できません: {e}", file=sys.stderr)
        return False

def show_help():
    help_text = """
Luka Forward - Port Forwarding Tool

Usage:
  luka forward <src> [dst] [options]

Source:
  <src>                 ソースアドレス (host:port または port)。port のみ指定時は localhost:port と解釈します。

Destination:
  [dst]                 デスティネーションアドレス (host:port または port)。省略時は0.0.0.0:10130を使用します。port のみ指定時は0.0.0.0:port と解釈します。

Options:
  --verbose, -v            詳細なログを表示します。
  --bandwidth <KB/s>       帯域幅制限をKB/s単位で指定します。
  --allow <IP/CIDR>        許可するクライアントのIPアドレスまたはサブネットを指定します。複数指定可能です。
  --deny <IP/CIDR>         拒否するクライアントのIPアドレスまたはサブネットを指定します。複数指定可能です。
  --auth <password>        クライアント認証のためのパスワードを指定します。
  --timeout <seconds>      接続のタイムアウト時間（秒）。デフォルトは5秒。
  --help, -h               このヘルプメッセージを表示します。

Examples:
  luka forward localhost:8080
  luka forward 8080 --verbose
  luka forward localhost:8080 0.0.0.0:9800 --verbose --bandwidth 100 --auth mypassword
  luka forward 8080 --verbose --allow 192.168.1.0/24 --deny 192.168.1.100
    """
    print(help_text)

def main():
    parser = argparse.ArgumentParser(add_help=False)
    parser.add_argument("src", nargs='?', help="ソースアドレス (host:port または port)")
    parser.add_argument("dst", nargs='?', default=None, help="デスティネーションアドレス (host:port または port)。省略時は0.0.0.0:10130を使用します。")
    parser.add_argument("--verbose", "-v", action="store_true", help="詳細なログを表示します。")
    parser.add_argument("--bandwidth", type=int, help="帯域幅制限をKB/s単位で指定します。")
    parser.add_argument("--allow", action='append', help="許可するクライアントのIPアドレスまたはサブネットを指定します。複数指定可能です。")
    parser.add_argument("--deny", action='append', help="拒否するクライアントのIPアドレスまたはサブネットを指定します。複数指定可能です。")
    parser.add_argument("--auth", type=str, help="クライアント認証のためのパスワードを指定します。")
    parser.add_argument("--timeout", type=int, default=5, help="接続のタイムアウト時間（秒）。デフォルトは5秒。")
    parser.add_argument("--help", "-h", action="store_true", help="このヘルプメッセージを表示します。")

    args = parser.parse_args()

    if args.help or not args.src:
        show_help()
        sys.exit(0)

    log_enabled = args.verbose
    bandwidth = args.bandwidth
    allow_list = []
    deny_list = []
    auth_password = args.auth
    timeout = args.timeout

    # IPフィルタリングの準備
    if args.allow:
        try:
            allow_list = [ipaddress.ip_network(entry) for entry in args.allow]
        except ValueError as e:
            print(f"許可リストのIPアドレスまたはサブネットが無効です: {e}", file=sys.stderr)
            sys.exit(1)
    if args.deny:
        try:
            deny_list = [ipaddress.ip_network(entry) for entry in args.deny]
        except ValueError as e:
            print(f"拒否リストのIPアドレスまたはサブネットが無効です: {e}", file=sys.stderr)
            sys.exit(1)

    # ソースアドレスの解析
    src_host, src_port = parse_address(args.src, default_host="localhost")

    # デスティネーションアドレスの設定
    if args.dst:
        dst_host, dst_port = parse_address(args.dst, default_host="0.0.0.0")
    else:
        dst_host, dst_port = "0.0.0.0", 10130

    # ソースアドレスが接続可能か確認
    if not check_src_accessible(src_host, src_port, timeout):
        sys.exit(1)

    # LAN IPの取得
    if dst_host == "0.0.0.0":
        lan_ip = get_lan_ip()
        accessible_url = f"http://{lan_ip}:{dst_port}"
    elif dst_host == "127.0.0.1":
        accessible_url = f"http://localhost:{dst_port}"
    else:
        accessible_url = f"http://{dst_host}:{dst_port}"

    print(f"アクセス可能なURL: {accessible_url}")

    shutdown_event = threading.Event()

    try:
        final_port = start_forwarding(
            src_host,
            src_port,
            dst_host,
            dst_port,
            log_enabled,
            shutdown_event,
            timeout,
            bandwidth,
            auth_password,
            allow_list,
            deny_list
        )
        # 実際に使用されたポートを再表示
        if dst_host == "0.0.0.0":
            accessible_url = f"http://{lan_ip}:{final_port}"
        elif dst_host == "127.0.0.1":
            accessible_url = f"http://localhost:{final_port}"
        else:
            accessible_url = f"http://{dst_host}:{final_port}"
        print(f"アクセス可能なURL: {accessible_url}")
    except KeyboardInterrupt:
        print("\nシャットダウン中...")
        shutdown_event.set()
    finally:
        print("ポートフォワーディングを停止しました。")

if __name__ == "__main__":
    main()
