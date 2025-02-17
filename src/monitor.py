#!/usr/bin/env python3
import psutil
import platform
from datetime import datetime
from rich import print
from rich.layout import Layout
from rich.panel import Panel
from rich.live import Live
from rich.table import Table
from rich.progress_bar import ProgressBar
from rich.style import Style
from rich.text import Text
import time
import shutil
import getpass
import sys
import socket
import os

def get_size(bytes, suffix="B"):
    """Convert bytes to a human-readable format."""
    factor = 1024
    for unit in ["", "K", "M", "G", "T", "P"]:
        if bytes < factor:
            return f"{bytes:.2f}{unit}{suffix}"
        bytes /= factor
    return f"{bytes:.2f}P{suffix}"

def get_timezone():
    """Get the system's timezone."""
    try:
        return datetime.now().astimezone().tzinfo
    except Exception:
        return "Unknown"

def get_fqdn():
    """Get the Fully Qualified Domain Name."""
    try:
        return socket.getfqdn()
    except Exception:
        return "Unknown"

def create_system_panel() -> Panel:
    """Create the System Information panel."""
    try:
        uname = platform.uname()
        boot_time = datetime.fromtimestamp(psutil.boot_time())
        uptime = datetime.now() - boot_time
        current_time = datetime.now()
        timezone = get_timezone()
        user = getpass.getuser()
        python_version = sys.version.split()[0]
        fqdn = get_fqdn()

        system_info = Table.grid(padding=(0, 2))
        system_info.add_column(justify="left")
        system_info.add_column(justify="left")

        # 基本情報
        system_info.add_row("[b]Hostname:[/]", Text(uname.node, style="cyan"))
        system_info.add_row("[b]FQDN:[/]", Text(fqdn, style="cyan"))
        system_info.add_row("[b]OS:[/]", Text(f"{uname.system} {uname.release}", style="cyan"))
        system_info.add_row("[b]Architecture:[/]", Text(uname.machine, style="cyan"))
        system_info.add_row("[b]Processor:[/]", Text(uname.processor or "Unknown", style="cyan"))
        system_info.add_row("[b]Machine Type:[/]", Text(platform.machine(), style="cyan"))
        system_info.add_row("[b]Python Version:[/]", Text(python_version, style="cyan"))
        system_info.add_row("[b]Current User:[/]", Text(user, style="cyan"))
        system_info.add_row("[b]Timezone:[/]", Text(str(timezone), style="cyan"))
        system_info.add_row("[b]Boot Time:[/]", Text(boot_time.strftime("%Y-%m-%d %H:%M:%S"), style="cyan"))
        system_info.add_row("[b]Current Time:[/]", Text(current_time.strftime("%Y-%m-%d %H:%M:%S"), style="cyan"))
        system_info.add_row("[b]Uptime:[/]", Text(str(uptime).split('.')[0], style="cyan"))

        return Panel(
            system_info,
            title="[bold yellow]System Information",
            border_style="bright_blue",
            padding=(1, 2)
        )
    except Exception as e:
        return Panel(
            f"[red]Error creating System Information panel: {e}[/]",
            title="[bold yellow]System Information",
            border_style="bright_red",
            padding=(1, 2)
        )

def create_cpu_panel() -> Panel:
    """Create the CPU Usage panel."""
    try:
        cpu_percent = psutil.cpu_percent(percpu=True)
        cpu_freq = psutil.cpu_freq()

        cpu_table = Table.grid(padding=(0, 1))
        cpu_table.add_row(
            Text(f"Total Usage: {psutil.cpu_percent()}%", style="bold"),
            Text(f"Frequency: {cpu_freq.current:.2f}MHz", style="bold"),
            Text(f"Cores: {psutil.cpu_count(logical=False)} Physical, {psutil.cpu_count()} Logical", style="bold")
        )

        for i, percent in enumerate(cpu_percent):
            color = "green" if percent < 50 else "yellow" if percent < 75 else "red"
            cpu_table.add_row(
                Text(f"Core {i}:"),
                ProgressBar(
                    total=100, 
                    completed=percent, 
                    width=20, 
                    style=color,
                    complete_style=Style(color=color, bold=True)
                ),
                Text(f"{percent}%", style=color)
            )

        return Panel(
            cpu_table,
            title="[bold yellow]CPU Usage",
            border_style="bright_blue",
            padding=(1, 2)
        )
    except Exception as e:
        return Panel(
            f"[red]Error creating CPU Usage panel: {e}[/]",
            title="[bold yellow]CPU Usage",
            border_style="bright_red",
            padding=(1, 2)
        )

def create_memory_panel() -> Panel:
    """Create the Memory Usage panel."""
    try:
        mem = psutil.virtual_memory()
        swap = psutil.swap_memory()

        mem_style = "green" if mem.percent < 70 else "yellow" if mem.percent < 90 else "red"
        swap_style = "cyan"

        memory_table = Table.grid(padding=(0, 2))
        memory_table.add_row(
            Text("[b]Total:[/]", style="bold"),
            Text(get_size(mem.total), style=mem_style),
            Text("[b]Available:[/]", style="bold"),
            Text(get_size(mem.available), style=mem_style)
        )
        memory_table.add_row(
            Text("[b]Used:[/]", style="bold"),
            Text(f"{get_size(mem.used)} ({mem.percent}%)", style=mem_style),
            Text("[b]Free:[/]", style="bold"),
            Text(get_size(mem.free), style=mem_style)
        )
        memory_table.add_row(
            ProgressBar(
                total=mem.total,
                completed=mem.used,
                width=50,
                style=mem_style,
                complete_style=Style(color=mem_style, bold=True)
            )
        )
        memory_table.add_row(Text("\n[b]SWAP:[/]", style="bold"))
        memory_table.add_row(
            ProgressBar(
                total=swap.total if swap.total > 0 else 1,
                completed=swap.used,
                width=50,
                style=swap_style,
                complete_style=Style(color=swap_style, bold=True)
            )
        )
        memory_table.add_row(
            Text("[b]Swap Used:[/]", style="bold"),
            Text(f"{get_size(swap.used)} ({swap.percent}%)", style=swap_style),
            Text("[b]Swap Free:[/]", style="bold"),
            Text(f"{get_size(swap.free)}", style=swap_style)
        )

        return Panel(
            memory_table,
            title="[bold yellow]Memory Usage",
            border_style="bright_blue",
            padding=(1, 2)
        )
    except Exception as e:
        return Panel(
            f"[red]Error creating Memory Usage panel: {e}[/]",
            title="[bold yellow]Memory Usage",
            border_style="bright_red",
            padding=(1, 2)
        )

def create_disk_panel() -> Panel:
    """Create the Disk Usage panel."""
    try:
        disks = []
        for part in psutil.disk_partitions(all=False):
            try:
                usage = psutil.disk_usage(part.mountpoint)
                style = "green" if usage.percent < 70 else "yellow" if usage.percent < 90 else "red"
                disks.append((
                    part.device,
                    part.mountpoint,
                    ProgressBar(
                        total=usage.total,
                        completed=usage.used,
                        width=30,
                        style=style,
                        complete_style=Style(color=style, bold=True)
                    ),
                    f"{usage.percent}%"
                ))
            except PermissionError:
                continue

        if not disks:
            disk_content = Text("[red]No disk information available[/]")
        else:
            disk_table = Table(show_header=True, header_style="bold magenta")
            disk_table.add_column("Device", overflow="fold")
            disk_table.add_column("Mountpoint", overflow="fold")
            disk_table.add_column("Usage")
            disk_table.add_column("%", justify="right")

            for disk in disks:
                disk_table.add_row(disk[0], disk[1], disk[2], disk[3])
            disk_content = disk_table

        return Panel(
            disk_content,
            title="[bold yellow]Disk Usage",
            border_style="bright_blue",
            padding=(1, 2)
        )
    except Exception as e:
        return Panel(
            f"[red]Error creating Disk Usage panel: {e}[/]",
            title="[bold yellow]Disk Usage",
            border_style="bright_red",
            padding=(1, 2)
        )

def create_network_panel() -> Panel:
    """Create the Network Information panel."""
    try:
        net = psutil.net_io_counters()
        network_table = Table.grid(padding=(0, 2))
        network_table.add_row(
            Text("[b]Sent:[/]", style="bold"), Text(get_size(net.bytes_sent), style="cyan"),
            Text("[b]Received:[/]", style="bold"), Text(get_size(net.bytes_recv), style="cyan")
        )
        return Panel(
            network_table,
            title="[bold yellow]Network Information",
            border_style="bright_blue",
            padding=(1, 2)
        )
    except Exception as e:
        return Panel(
            f"[red]Error creating Network Information panel: {e}[/]",
            title="[bold yellow]Network Information",
            border_style="bright_red",
            padding=(1, 2)
        )

def update_layout(layout: Layout) -> None:
    """Update all panels in the layout with the latest system information."""
    layout["system"].update(create_system_panel())      # 左上：System Info
    layout["cpu"].update(create_cpu_panel())            # 左下：CPU
    layout["disk"].update(create_disk_panel())          # 右上：Disk
    layout["memory"].update(create_memory_panel())      # 右下：Memory
    layout["footer"].update(create_network_panel())      # フッター：Network Info

def configure_layout() -> Layout:
    """Configure the layout structure dynamically based on terminal size."""
    terminal_width, terminal_height = shutil.get_terminal_size((80, 20))

    layout = Layout(name="root")

    # 主レイアウトを上下に分割：bodyとfooter
    layout.split(
        Layout(name="body", ratio=1),
        Layout(name="footer", size=7),
    )

    # bodyを左右に分割：左（4分割）
    layout["body"].split_row(
        Layout(name="left", ratio=2),
    )

    # leftを上下に分割：上（systemとdisk）と下（cpuとmemory）
    layout["left"].split(
        Layout(name="top", ratio=1),
        Layout(name="bottom", ratio=1),
    )

    # topを左右に分割：systemとdisk
    layout["left"]["top"].split_row(
        Layout(name="system", ratio=1),
        Layout(name="disk", ratio=1),
    )

    # bottomを左右に分割：cpuとmemory
    layout["left"]["bottom"].split_row(
        Layout(name="cpu", ratio=1),
        Layout(name="memory", ratio=1),
    )

    return layout

def main():
    """Main function to set up the layout and start the live display."""
    print("[bold green]Starting system monitor... (Press Ctrl+C to exit)[/]")

    # Initialize the root layout
    layout = configure_layout()

    # Start live display
    try:
        with Live(layout, refresh_per_second=1, screen=True):
            while True:
                update_layout(layout)
                time.sleep(1)
    except KeyboardInterrupt:
        print("\n[bold red]Exiting monitor...[/]")
    except Exception as e:
        print(f"[red]Unexpected error: {e}[/]")

if __name__ == "__main__":
    main()
