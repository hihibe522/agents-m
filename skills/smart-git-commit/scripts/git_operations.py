#!/usr/bin/env python3
"""
git_operations.py
智能 Git 操作模組
負責：分支管理、diff 分析、commit、push
"""

import subprocess
import sys


def run_cmd(cmd: list[str], cwd: str | None = None, env: dict | None = None) -> tuple[int, str, str]:
    """執行命令並回傳 (return_code, stdout, stderr)"""
    import os
    cmd_env = os.environ.copy()
    if env:
        cmd_env.update(env)

    result = subprocess.run(
        cmd,
        capture_output=True,
        text=True,
        cwd=cwd,
        env=cmd_env
    )
    return result.returncode, result.stdout.strip(), result.stderr.strip()


# ─── 分支管理 ─────────────────────────────────

def get_current_branch() -> str:
    """取得目前所在分支"""
    _, stdout, _ = run_cmd(["git", "rev-parse", "--abbrev-ref", "HEAD"])
    return stdout


def branch_exists(branch_name: str) -> bool:
    """檢查分支是否存在（本地）"""
    _, stdout, _ = run_cmd(["git", "branch", "--list", branch_name])
    return branch_name in stdout


def remote_branch_exists(branch_name: str, remote: str = "origin") -> bool:
    """檢查分支是否存在（remote）"""
    _, stdout, _ = run_cmd(["git", "branch", "-r", "--list", f"{remote}/{branch_name}"])
    return f"{remote}/{branch_name}" in stdout


def get_default_branch(remote: str = "origin") -> tuple[bool, str]:
    """
    動態取得 remote 的 default branch 名稱。
    先試本地快速方式，失敗再從 remote 查。
    """
    # 方式一：symbolic-ref（本地、快）
    code, stdout, _ = run_cmd(["git", "symbolic-ref", f"refs/remotes/{remote}/HEAD"])
    if code == 0 and stdout:
        # 輸出: refs/remotes/origin/main → 截取 main
        return True, stdout.split("/")[-1]

    # 方式二：remote show（網路、慢、但穩定）
    # 強制使用英文輸出以避免 i18n 問題
    code, stdout, _ = run_cmd(["git", "remote", "show", remote], env={"LC_ALL": "C"})
    if code == 0:
        for line in stdout.split("\n"):
            if "HEAD branch:" in line:
                return True, line.split(":")[-1].strip()

    return False, "無法取得 default branch"


def create_branch(branch_name: str, remote: str = "origin") -> tuple[bool, str]:
    """從 remote 的 default branch 開出新分支並切換"""
    # 取得 default branch
    ok, default_branch = get_default_branch(remote)
    if not ok:
        return False, default_branch  # default_branch 裡是 error message

    # fetch 確保本地 ref 最新
    code, _, stderr = run_cmd(["git", "fetch", remote, default_branch])
    if code != 0:
        return False, f"fetch {remote}/{default_branch} 失敗: {stderr}"

    # 從 origin/<default> 開新分支
    code, _, stderr = run_cmd(["git", "checkout", "-b", branch_name, f"{remote}/{default_branch}"])
    if code != 0:
        return False, stderr

    return True, f"已從 {remote}/{default_branch} 建立並切換到分支: {branch_name}"


def switch_branch(branch_name: str) -> tuple[bool, str]:
    """切換到指定分支"""
    code, _, stderr = run_cmd(["git", "checkout", branch_name])
    if code != 0:
        return False, stderr
    return True, f"已切換到分支: {branch_name}"


# ─── Diff 分析 ────────────────────────────────

def get_staged_diff() -> str:
    """取得已 stage 的變更 (git diff --cached)"""
    _, stdout, _ = run_cmd(["git", "diff", "--cached"])
    return stdout


def get_unstaged_diff() -> str:
    """取得未 stage 的變更 (git diff)"""
    _, stdout, _ = run_cmd(["git", "diff"])
    return stdout


def get_staged_files() -> list[str]:
    """取得已 stage 的檔案列表"""
    _, stdout, _ = run_cmd(["git", "diff", "--cached", "--name-only"])
    return [f for f in stdout.split("\n") if f]


def get_unstaged_files() -> list[str]:
    """取得未 stage 的檔案列表"""
    _, stdout, _ = run_cmd(["git", "diff", "--name-only"])
    return [f for f in stdout.split("\n") if f]


def get_untracked_files() -> list[str]:
    """取得未追蹤的檔案列表"""
    _, stdout, _ = run_cmd(["git", "ls-files", "--others", "--exclude-standard"])
    return [f for f in stdout.split("\n") if f]


def get_status_summary() -> str:
    """取得 git status 摘要"""
    _, stdout, _ = run_cmd(["git", "status", "--short"])
    return stdout


def get_diff_stats() -> str:
    """取得 staged 變更的統計（新增/刪除行數）"""
    _, stdout, _ = run_cmd(["git", "diff", "--cached", "--stat"])
    return stdout


# ─── Commit & Push ────────────────────────────

def stage_all() -> tuple[bool, str]:
    """將所有變更 stage"""
    code, _, stderr = run_cmd(["git", "add", "-A"])
    if code != 0:
        return False, stderr
    return True, "已將所有變更加入 staging"


def commit(message: str) -> tuple[bool, str]:
    """執行 commit"""
    code, stdout, stderr = run_cmd(["git", "commit", "-m", message])
    if code != 0:
        return False, stderr
    return True, stdout


def push(branch_name: str, remote: str = "origin") -> tuple[bool, str]:
    """推送分支到 remote"""
    code, stdout, stderr = run_cmd(["git", "push", "-u", remote, branch_name])
    if code != 0:
        return False, stderr

    # 驗證 upstream tracking 是否設定成功
    _, tracking_info, _ = run_cmd(["git", "config", "--get", f"branch.{branch_name}.remote"])
    upstream_set = tracking_info == remote

    # git push 的訊息在 stderr（這是正常行為）
    push_output = stderr or stdout

    if upstream_set:
        return True, f"{push_output}\n✓ Upstream tracking 已設定: {remote}/{branch_name}"
    else:
        return True, f"{push_output}\n⚠ 警告: Upstream tracking 未設定成功"


# ─── CLI 入口 ─────────────────────────────────

def main():
    """
    CLI 使用方式:
        python git_operations.py status
        python git_operations.py get-default-branch
        python git_operations.py check-branch <branch_name>
        python git_operations.py create-branch <branch_name>
        python git_operations.py diff
        python git_operations.py stage-all
        python git_operations.py commit <message>
        python git_operations.py push <branch_name>
    """
    if len(sys.argv) < 2:
        print("Usage: python git_operations.py <command> [args]")
        print("Commands: status, get-default-branch, check-branch, create-branch, diff, stage-all, commit, push")
        sys.exit(1)

    command = sys.argv[1]

    if command == "status":
        print("=== 目前分支 ===")
        print(get_current_branch())
        print("\n=== 變更狀態 ===")
        print(get_status_summary() or "無變更")
        print("\n=== Staged 檔案 ===")
        staged = get_staged_files()
        print("\n".join(staged) if staged else "無 staged 檔案")
        print("\n=== Unstaged 檔案 ===")
        unstaged = get_unstaged_files()
        print("\n".join(unstaged) if unstaged else "無 unstaged 檔案")
        print("\n=== Untracked 檔案 ===")
        untracked = get_untracked_files()
        print("\n".join(untracked) if untracked else "無 untracked 檔案")

    elif command == "get-default-branch":
        ok, result = get_default_branch()
        print(result)
        sys.exit(0 if ok else 1)

    elif command == "check-branch":
        branch = sys.argv[2]
        local = branch_exists(branch)
        remote = remote_branch_exists(branch)
        print(f"本地: {'存在' if local else '不存在'}")
        print(f"Remote: {'存在' if remote else '不存在'}")

    elif command == "create-branch":
        branch = sys.argv[2]
        success, msg = create_branch(branch)
        print(msg)
        sys.exit(0 if success else 1)

    elif command == "diff":
        staged = get_staged_diff()
        unstaged = get_unstaged_diff()
        if staged:
            print("=== Staged Diff ===")
            print(staged)
        if unstaged:
            print("=== Unstaged Diff ===")
            print(unstaged)
        if not staged and not unstaged:
            print("無 diff 內容")

    elif command == "stage-all":
        success, msg = stage_all()
        print(msg)
        sys.exit(0 if success else 1)

    elif command == "commit":
        message = sys.argv[2]
        success, msg = commit(message)
        print(msg)
        sys.exit(0 if success else 1)

    elif command == "push":
        branch = sys.argv[2]
        success, msg = push(branch)
        print(msg)
        sys.exit(0 if success else 1)

    else:
        print(f"Unknown command: {command}")
        sys.exit(1)


if __name__ == "__main__":
    main()
