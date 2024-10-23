#!/usr/bin/env bash
## Author: honeok
## Copyright (c) 2024 honeok
## Blog: www.honeok.com
## Github: https://github.com/honeok/Shell

# =============== 全局变量 ==============
remote_host="remote_host"           # 远程主机地址
remote_port="remote_port"           # 远程主机端口
file_path="/localfile"              # 本地文件路径
concurrent_uploads=1                # 上传进程并发数量
password="remote_password"          # 登录密码

# =============== 通用函数 ===============
## 安装软件包
install() {
    if [ $# -eq 0 ]; then
        echo "未提供软件包参数"
        return 1
    fi

    for package in "$@"; do
        if ! command -v "$package" &>/dev/null; then
            echo "正在安装$package"
            if command -v dnf &>/dev/null; then
                dnf update -y
                dnf install epel-release -y
                dnf install "$package" -y
            elif command -v yum &>/dev/null; then
                yum update -y
                yum install epel-release -y
                yum install "$package" -y
            elif command -v apt &>/dev/null; then
                apt update -y
                apt install "$package" -y
            else
                echo "未知的包管理器"
                return 1
            fi
        else
            echo "$package已经安装！"
        fi
    done
    return 0
}

install sshpass

## uploads
upload_file() {
    scp -P "$remote_port" "$file_path" "$remote_host:/dev/null"
}

## Main
while true; do
    for ((i=0; i<concurrent_uploads; i++)); do
        upload_file & # 启动上传进程
    done
    wait              # 等待所有上传完成
done