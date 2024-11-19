#!/usr/bin/env python3
import psutil
from prompt_toolkit.application import Application
from prompt_toolkit.key_binding import KeyBindings
from prompt_toolkit.layout import Layout, HSplit
from prompt_toolkit.layout.containers import Window
from prompt_toolkit.layout.controls import FormattedTextControl
from prompt_toolkit.formatted_text import FormattedText
from prompt_toolkit.styles import Style
import argparse
import sys
import locale

# ロケールの設定（日本語対応）
locale.setlocale(locale.LC_ALL, '')

def get_processes(sort_reverse):
    processes = []
    for proc in psutil.process_iter(['pid', 'name', 'memory_info', 'cpu_percent', 'memory_percent']):
        try:
            mem = proc.info['memory_info'].rss / (1024 * 1024)  # メモリ使用量 (MB)
            cpu = proc.info['cpu_percent']
            mem_percent = proc.info['memory_percent']
            try:
                swap = proc.memory_full_info().swap / (1024 * 1024)  # Swap使用量 (MB)
            except (psutil.AccessDenied, psutil.NoSuchProcess, AttributeError):
                swap = 0.0
            processes.append({
                'pid': proc.info['pid'],
                'name': proc.info['name'] or 'N/A',
                'memory': mem,
                'memory_percent': mem_percent,
                'swap': swap,
                'cpu': cpu
            })
        except (psutil.NoSuchProcess, psutil.AccessDenied, psutil.ZombieProcess):
            continue
    # メモリ使用量でソート
    processes = sorted(processes, key=lambda p: p['memory'], reverse=sort_reverse)
    return processes

class ProcessList:
    def __init__(self, sort_reverse, number):
        self.sort_reverse = sort_reverse
        self.number = number
        self.processes = get_processes(self.sort_reverse)
        self.selected_index = 0
        self.error_message = ""

    def get_formatted_text(self):
        result = []
        header = [
            ('class:header', f"{'PID':>7} "),
            ('class:header', f"{'プロセス名':30} "),
            ('class:header', f"{'メモリ(MB)':>12} "),
            ('class:header', f"{'メモリ%':>8} "),
            ('class:header', f"{'Swap(MB)':>10} "),
            ('class:header', f"{'CPU%':>6}")
        ]
        result.extend(header)
        result.append(('', '\n'))
        # プロセス一覧
        for idx, proc in enumerate(self.processes[:self.number]):
            if idx == self.selected_index:
                style = 'class:selected'
            else:
                style = ''
            pid = f"{proc['pid']:>7} "
            name = f"{proc['name'][:30]:30} "
            memory = f"{proc['memory']:12.2f} "
            mem_percent = f"{proc['memory_percent']:8.2f} "
            swap = f"{proc['swap']:10.2f} "
            cpu = f"{proc['cpu']:6.1f}"
            line = [
                (style, pid),
                (style, name),
                (style, memory),
                (style, mem_percent),
                (style, swap),
                (style, cpu)
            ]
            result.extend(line)
            result.append(('', '\n'))
        return result

    def move_up(self):
        if self.selected_index > 0:
            self.selected_index -= 1

    def move_down(self):
        if self.selected_index < min(len(self.processes), self.number) - 1:
            self.selected_index += 1

    def refresh(self):
        self.processes = get_processes(self.sort_reverse)
        if self.selected_index >= min(len(self.processes), self.number):
            self.selected_index = min(len(self.processes), self.number) - 1
        self.error_message = ""

    def get_selected_process(self):
        if self.processes:
            return self.processes[self.selected_index]
        return None

    def set_error(self, message):
        self.error_message = message

def parse_args():
    parser = argparse.ArgumentParser(
        description='Luka psm - process manager',
        formatter_class=argparse.RawTextHelpFormatter
    )
    parser.add_argument('-n', '--number', type=int, default=10, help='表示するプロセスの数 (デフォルト: 10)')
    parser.add_argument('-r', '--reverse', action='store_true', help='ソート順を逆順にします')
    return parser.parse_args()

def main():
    args = parse_args()
    sort_reverse = args.reverse
    number = args.number
    process_list = ProcessList(sort_reverse, number)

    def get_text():
        text = process_list.get_formatted_text()
        return FormattedText(text)

    process_control = FormattedTextControl(get_text)
    process_window = Window(content=process_control, wrap_lines=False, always_hide_cursor=True)

    # ステータスバー
    status_text = FormattedTextControl(lambda: [
        ('class:status', " ↑/↓: 選択, k: キル, r: リフレッシュ, q: 終了 "),
        ('class:status', f" | 表示数: {number} "),
        ('class:status', f" | ソート順: {'降順' if sort_reverse else '昇順'} ")
    ])
    status_window = Window(content=status_text, height=1, style='class:status')

    # エラーメッセージ
    error_text = FormattedTextControl(lambda: [
        ('class:error', process_list.error_message)
    ])
    error_window = Window(content=error_text, height=1, style='class:error')

    root_container = HSplit([
        process_window,
        error_window,
        status_window
    ])

    kb = KeyBindings()

    @kb.add('up')
    def on_up(event):
        process_list.move_up()

    @kb.add('down')
    def on_down(event):
        process_list.move_down()

    @kb.add('k')
    def on_kill(event):
        proc = process_list.get_selected_process()
        if proc:
            pid = proc['pid']
            try:
                p = psutil.Process(pid)
                p.kill()
                process_list.set_error(f"プロセス {pid} をキルしました。")
                process_list.refresh()
            except psutil.NoSuchProcess:
                process_list.set_error(f"プロセス {pid} は既に終了しています。")
            except psutil.AccessDenied:
                process_list.set_error(f"プロセス {pid} をキルする権限がありません。")
            except Exception as e:
                process_list.set_error(f"エラー: {str(e)}")

    @kb.add('r')
    def on_refresh(event):
        process_list.refresh()

    @kb.add('q')
    def on_quit(event):
        event.app.exit()

    style = Style.from_dict({
        'selected': 'reverse',
        'header': 'bold underline',
        'status': 'reverse',
        'error': 'bold red'
    })

    application = Application(
        layout=Layout(root_container),
        key_bindings=kb,
        style=style,
        full_screen=True
    )

    application.run()

if __name__ == '__main__':
    main()
