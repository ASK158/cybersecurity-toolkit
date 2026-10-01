<#
.SYNOPSIS
    个人电脑网络安全监测脚本
.DESCRIPTION
    自动监测电脑网络安全状态，包括：
    - 网络连接状态（检测可疑外部连接）
    - 开放端口扫描
    - 可疑进程检测
    - 防火墙状态检查
    - 杀毒软件状态检查
    - 系统启动项审查
    - DNS 配置检查
    - 共享资源检查
    所有监测结果输出到日志文件，发现异常时发出告警。
.NOTES
    建议以管理员权限运行以获取完整信息
    日志文件保存在脚本同目录下的 SecurityLogs 文件夹中
#>

#Requires -Version 5.1

# ============================================================
# 配置区域
# ============================================================

# 日志目录
$LogDir = Join-Path $PSScriptRoot "SecurityLogs"
if (-not (Test-Path $LogDir)) {
    New-Item -ItemType Directory -Path $LogDir -Force | Out-Null
}

# 日志文件（按日期命名）
$LogFile = Join-Path $LogDir ("SecurityLog_{0}.txt" -f (Get-Date -Format "yyyy-MM-dd"))

# 可疑端口列表（常见恶意软件使用的端口）
$SuspiciousPorts = @(
    4444, 5555, 6666, 6667, 6668, 6669,  # IRC 相关（常见后门通道）
    31337,                                  # 经典后门端口
    12345, 12346, 12347,                   # 常见木马端口
    27374, 27665,                          # 木马端口
    54321,                                  # 常见后门端口
    9999, 1080,                             # SOCKS 代理 / 后门
    1337, 3127                              # 常见恶意端口
)

# 可疑进程名称（常见恶意软件进程）
$SuspiciousProcesses = @(
    "keylogger", "rat_", "backdoor", "trojan",
    "cryptominer", "xmrig", "minerd",
    "mimikatz", "lazagne"
)

# 内部网络范围（排除这些范围的连接）
$InternalPrefixes = @("10.", "172.16.", "172.17.", "172.18.", "172.19.",
    "172.20.", "172.21.", "172.22.", "172.23.", "172.24.", "172.25.",
    "172.26.", "172.27.", "172.28.", "172.29.", "172.30.", "172.31.",
    "192.168.", "127.", "0.0.0.0", "::1", "*")

# ============================================================
# 工具函数
# ============================================================

function Write-Log {
    <# 写入日志并输出到控制台 #>
    param(
        [string]$Message,
        [ValidateSet("INFO", "WARNING", "ALERT", "OK")]
        [string]$Level = "INFO"
    )

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $levelTag = switch ($Level) {
        "INFO"    { "[信息]" }
        "WARNING" { "[警告]" }
        "ALERT"   { "[!!警报]" }
        "OK"      { "[安全]" }
    }

    $logEntry = "$timestamp $levelTag $Message"

    # 控制台颜色输出
    $color = switch ($Level) {
        "INFO"    { "White" }
        "WARNING" { "Yellow" }
        "ALERT"   { "Red" }
        "OK"      { "Green" }
    }

    Write-Host $logEntry -ForegroundColor $color
    Add-Content -Path $LogFile -Value $logEntry -Encoding UTF8
}

function Write-Section {
    <# 输出分隔段落标题 #>
    param([string]$Title)

    $separator = "=" * 60
    Write-Host ""
    Write-Host $separator -ForegroundColor Cyan
    Write-Host "  $Title" -ForegroundColor Cyan
    Write-Host $separator -ForegroundColor Cyan
    Add-Content -Path $LogFile -Value "`n$separator`n  $Title`n$separator" -Encoding UTF8
}

function Test-IsInternalIP {
    <# 判断 IP 是否为内网地址 #>
    param([string]$IP)

    foreach ($prefix in $InternalPrefixes) {
        if ($IP.StartsWith($prefix)) { return $true }
    }
    return $false
}

# ============================================================
# 监测模块
# ============================================================

function Check-FirewallStatus {
    <# 检查 Windows 防火墙状态 #>
    Write-Section "防火墙状态检查"

    try {
        $profiles = Get-NetFirewallProfile -ErrorAction Stop
        $allEnabled = $true

        foreach ($profile in $profiles) {
            $status = if ($profile.Enabled) { "已启用" } else { "已禁用" }
            $level = if ($profile.Enabled) { "OK" } else { "ALERT" }

            Write-Log ("  {0} 防火墙: {1}" -f $profile.Name, $status) -Level $level

            if (-not $profile.Enabled) { $allEnabled = $false }
        }

        if ($allEnabled) {
            Write-Log "所有防火墙配置文件均已启用" -Level "OK"
        } else {
            Write-Log "警告: 存在未启用的防火墙配置文件！" -Level "ALERT"
        }
    }
    catch {
        Write-Log ("  无法检查防火墙状态: {0}" -f $_.Exception.Message) -Level "WARNING"
    }
}

function Check-AntivirusStatus {
    <# 检查杀毒软件状态 #>
    Write-Section "杀毒软件状态检查"

    try {
        $avProducts = Get-CimInstance -Namespace "root/SecurityCenter2" -ClassName "AntiVirusProduct" -ErrorAction Stop

        if ($avProducts) {
            foreach ($av in $avProducts) {
                $name = $av.displayName
                # 解析产品状态标志
                $productState = $av.productState
                $scannerStatus = ($productState -band 0x0000FF00) -shr 8

                $statusText = switch ($scannerStatus) {
                    0 { "已关闭" }
                    1 { "已扫描（可能过期）" }
                    2 { "正常运行" }
                    default { "未知状态 (代码: $scannerStatus)" }
                }

                $level = if ($scannerStatus -eq 2) { "OK" } else { "WARNING" }
                Write-Log ("  杀毒软件: {0} - {1}" -f $name, $statusText) -Level $level
            }
        } else {
            Write-Log "未检测到任何杀毒软件！" -Level "ALERT"
        }
    }
    catch {
        # 回退到检查 Windows Defender
        try {
            $defenderStatus = Get-MpComputerStatus -ErrorAction Stop
            $realTimeEnabled = $defenderStatus.RealTimeProtectionEnabled
            $level = if ($realTimeEnabled) { "OK" } else { "ALERT" }
            $statusText = if ($realTimeEnabled) { "实时保护已启用" } else { "实时保护已禁用" }
            Write-Log ("  Windows Defender: {0}" -f $statusText) -Level $level

            if ($defenderStatus.AntivirusSignatureLastUpdated) {
                $lastUpdate = $defenderStatus.AntivirusSignatureLastUpdated
                $daysSinceUpdate = ((Get-Date) - $lastUpdate).Days
                $level = if ($daysSinceUpdate -le 7) { "OK" } else { "WARNING" }
                Write-Log ("  病毒库最后更新: {0} ({1} 天前)" -f $lastUpdate.ToString("yyyy-MM-dd"), $daysSinceUpdate) -Level $level
            }
        }
        catch {
            Write-Log "无法检查杀毒软件状态: $($_.Exception.Message)" -Level "WARNING"
        }
    }
}

function Check-NetworkConnections {
    <# 检查活跃的网络连接，识别可疑外部连接 #>
    Write-Section "网络连接检查"

    try {
        $connections = Get-NetTCPConnection -State Established -ErrorAction Stop
        $suspiciousCount = 0

        foreach ($conn in $connections) {
            $remoteIP = $conn.RemoteAddress
            $remotePort = $conn.RemotePort
            $localPort = $conn.LocalPort
            $owningPid = $conn.OwningProcess

            # 跳过内网连接
            if (Test-IsInternalIP $remoteIP) { continue }

            # 获取进程信息
            $processName = "未知"
            try {
                $proc = Get-Process -Id $owningPid -ErrorAction SilentlyContinue
                $processName = $proc.ProcessName
            } catch {}

            $connInfo = "  {0}:{1} -> {2}:{3} (进程: {4}, PID: {5})" -f
                $conn.LocalAddress, $localPort, $remoteIP, $remotePort, $processName, $owningPid

            # 检查是否连接可疑端口
            if ($SuspiciousPorts -contains $remotePort) {
                Write-Log "$connInfo [可疑端口!]" -Level "ALERT"
                $suspiciousCount++
            }
            else {
                Write-Log $connInfo -Level "INFO"
            }
        }

        $externalConns = ($connections | Where-Object { -not (Test-IsInternalIP $_.RemoteAddress) })
        Write-Log ("  外部活跃连接总数: {0}" -f @($externalConns).Count) -Level "INFO"

        if ($suspiciousCount -gt 0) {
            Write-Log ("  发现 {0} 个可疑连接！" -f $suspiciousCount) -Level "ALERT"
        } else {
            Write-Log "未发现可疑的外部连接" -Level "OK"
        }
    }
    catch {
        Write-Log ("  无法检查网络连接: {0}" -f $_.Exception.Message) -Level "WARNING"
    }
}

function Check-OpenPorts {
    <# 检查本地监听端口 #>
    Write-Section "开放端口检查"

    try {
        $listeners = Get-NetTCPConnection -State Listen -ErrorAction Stop |
            Select-Object LocalAddress, LocalPort, OwningProcess, @{
                Name = "ProcessName"
                Expression = {
                    try { (Get-Process -Id $_.OwningProcess -ErrorAction SilentlyContinue).ProcessName }
                    catch { "未知" }
                }
            } | Sort-Object LocalPort

        foreach ($listener in $listeners) {
            $portInfo = "  监听端口: {0}:{1} (进程: {2}, PID: {3})" -f
                $listener.LocalAddress, $listener.LocalPort, $listener.ProcessName, $listener.OwningProcess

            if ($SuspiciousPorts -contains $listener.LocalPort) {
                Write-Log "$portInfo [可疑端口!]" -Level "ALERT"
            } else {
                Write-Log $portInfo -Level "INFO"
            }
        }

        Write-Log ("  监听端口总数: {0}" -f @($listeners).Count) -Level "INFO"
    }
    catch {
        Write-Log ("  无法检查开放端口: {0}" -f $_.Exception.Message) -Level "WARNING"
    }
}

function Check-SuspiciousProcesses {
    <# 检测可疑进程 #>
    Write-Section "可疑进程检测"

    try {
        $processes = Get-Process | Select-Object Id, ProcessName, Path, Company, CPU, WorkingSet64
        $found = $false

        foreach ($proc in $processes) {
            $procNameLower = $proc.ProcessName.ToLower()

            foreach ($suspName in $SuspiciousProcesses) {
                if ($procNameLower -match $suspName) {
                    Write-Log ("  发现可疑进程: {0} (PID: {1}, 路径: {2})" -f
                        $proc.ProcessName, $proc.Id, $proc.Path) -Level "ALERT"
                    $found = $true
                }
            }

            # 检查无路径的可疑进程（非系统进程但没有文件路径）
            if (-not $proc.Path -and
                $proc.ProcessName -notin @("Idle", "System", "Registry",
                    "Memory Compression", "Secure System")) {
                # 仅对占用较多 CPU 或内存的无路径进程发出警告
                if ($proc.CPU -gt 10 -or $proc.WorkingSet64 -gt 100MB) {
                    Write-Log ("  无文件路径的活跃进程: {0} (PID: {1}, CPU: {2:F1}s, 内存: {3:N0}MB)" -f
                        $proc.ProcessName, $proc.Id, $proc.CPU, ($proc.WorkingSet64 / 1MB)) -Level "WARNING"
                    $found = $true
                }
            }
        }

        if (-not $found) {
            Write-Log "未发现可疑进程" -Level "OK"
        }
    }
    catch {
        Write-Log ("  无法检查进程列表: {0}" -f $_.Exception.Message) -Level "WARNING"
    }
}

function Check-StartupItems {
    <# 检查系统启动项 #>
    Write-Section "启动项检查"

    try {
        # 注册表启动项
        $regPaths = @(
            "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run",
            "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce",
            "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run",
            "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce"
        )

        foreach ($path in $regPaths) {
            if (Test-Path $path) {
                $items = Get-ItemProperty $path -ErrorAction SilentlyContinue
                $props = $items.PSObject.Properties | Where-Object {
                    $_.Name -notin @("PSPath", "PSParentPath", "PSChildName", "PSDrive", "PSProvider")
                }

                foreach ($prop in $props) {
                    Write-Log ("  [{0}] {1} = {2}" -f ($path -replace ".*\\"), $prop.Name, $prop.Value) -Level "INFO"
                }
            }
        }

        # 启动文件夹
        $startupFolder = [System.Environment]::GetFolderPath("Startup")
        if (Test-Path $startupFolder) {
            $startupFiles = Get-ChildItem $startupFolder -ErrorAction SilentlyContinue
            foreach ($file in $startupFiles) {
                Write-Log ("  [启动文件夹] {0}" -f $file.Name) -Level "INFO"
            }
        }

        # 计划任务（非微软的）
        Write-Log "  --- 非微软计划任务 ---" -Level "INFO"
        $tasks = Get-ScheduledTask -ErrorAction SilentlyContinue | Where-Object {
            $_.Author -notlike "*Microsoft*" -and $_.Author -ne "" -and $_.State -eq "Ready"
        } | Select-Object -First 20 TaskName, Author, State

        foreach ($task in $tasks) {
            Write-Log ("  [计划任务] {0} (作者: {1})" -f $task.TaskName, $task.Author) -Level "INFO"
        }
    }
    catch {
        Write-Log ("  无法检查启动项: {0}" -f $_.Exception.Message) -Level "WARNING"
    }
}

function Check-DNSConfig {
    <# 检查 DNS 配置 #>
    Write-Section "DNS 配置检查"

    try {
        $adapters = Get-NetAdapter | Where-Object { $_.Status -eq "Up" }

        foreach ($adapter in $adapters) {
            $dnsServers = (Get-DnsClientServerAddress -InterfaceIndex $adapter.ifIndex -AddressFamily IPv4).ServerAddresses

            Write-Log ("  适配器: {0}" -f $adapter.Name) -Level "INFO"
            foreach ($dns in $dnsServers) {
                $level = "INFO"
                # 标记非主流 DNS
                $knownDNS = @("8.8.8.8", "8.8.4.4", "1.1.1.1", "1.0.0.1", "223.5.5.5", "114.114.114.114", "119.29.29.29")
                if ($dns -in $knownDNS) {
                    $level = "OK"
                }
                Write-Log ("    DNS 服务器: {0}" -f $dns) -Level $level
            }
        }

        # 检查 DNS 缓存中的可疑条目
        Write-Log "  --- 最近 DNS 查询（部分）---" -Level "INFO"
        $dnsCache = Get-DnsClientCache -ErrorAction SilentlyContinue | Select-Object -First 15 Name, Type, Data
        foreach ($entry in $dnsCache) {
            Write-Log ("    {0} -> {1}" -f $entry.Name, $entry.Data) -Level "INFO"
        }
    }
    catch {
        Write-Log ("  无法检查 DNS 配置: {0}" -f $_.Exception.Message) -Level "WARNING"
    }
}

function Check-SharedResources {
    <# 检查共享资源 #>
    Write-Section "共享资源检查"

    try {
        $shares = Get-SmbShare -ErrorAction Stop

        foreach ($share in $shares) {
            $level = "INFO"
            # 标记非默认共享
            if ($share.Name -notmatch '^\$$' -and $share.Name -notin @("ADMIN$", "IPC$", "C$")) {
                $level = "WARNING"
            }
            Write-Log ("  共享: {0} (路径: {1}, 描述: {2})" -f
                $share.Name, $share.Path, $share.Description) -Level $level
        }

        Write-Log ("  共享资源总数: {0}" -f @($shares).Count) -Level "INFO"
    }
    catch {
        Write-Log ("  无法检查共享资源: {0}" -f $_.Exception.Message) -Level "WARNING"
    }
}

function Check-WindowsUpdate {
    <# 检查 Windows 更新状态 #>
    Write-Section "Windows 更新检查"

    try {
        $session = New-Object -ComObject Microsoft.Update.Session
        $searcher = $session.CreateUpdateSearcher()
        $pending = $searcher.Search("IsInstalled=0").Updates

        if ($pending.Count -gt 0) {
            Write-Log ("  有 {0} 个待安装的安全更新！" -f $pending.Count) -Level "WARNING"
            foreach ($update in $pending | Select-Object -First 5) {
                Write-Log ("    - {0}" -f $update.Title) -Level "WARNING"
            }
        } else {
            Write-Log "所有安全更新已安装" -Level "OK"
        }

        # 检查最后安装时间
        $lastUpdate = $searcher.Search("IsInstalled=1 and Type='Software'").Updates |
            Sort-Object LastDeploymentChangeTime -Descending |
            Select-Object -First 1

        if ($lastUpdate) {
            $daysAgo = ((Get-Date) - $lastUpdate.LastDeploymentChangeTime).Days
            $level = if ($daysAgo -le 30) { "OK" } else { "WARNING" }
            Write-Log ("  最后更新安装时间: {0} ({1} 天前)" -f
                $lastUpdate.LastDeploymentChangeTime.ToString("yyyy-MM-dd"), $daysAgo) -Level $level
        }
    }
    catch {
        Write-Log ("  无法检查 Windows 更新状态: {0}" -f $_.Exception.Message) -Level "WARNING"
    }
}

function Check-RecentFileChanges {
    <# 检查近期被大量修改的文件（检测勒索软件活动） #>
    Write-Section "近期文件活动检查"

    try {
        $userProfile = $env:USERPROFILE
        $docFolders = @(
            (Join-Path $userProfile "Documents"),
            (Join-Path $userProfile "Desktop"),
            (Join-Path $userProfile "Pictures")
        )

        $recentThreshold = (Get-Date).AddHours(-1)
        $suspiciousExtensions = @(".encrypted", ".locked", ".crypted", ".crypt", ".ransom", ".wcry", ".wncry")

        foreach ($folder in $docFolders) {
            if (Test-Path $folder) {
                # 检查最近1小时内被修改的文件
                $recentFiles = Get-ChildItem -Path $folder -Recurse -File -ErrorAction SilentlyContinue |
                    Where-Object { $_.LastWriteTime -gt $recentThreshold } |
                    Measure-Object

                if ($recentFiles.Count -gt 50) {
                    Write-Log ("  {0}: 最近1小时内有 {1} 个文件被修改（异常！）" -f
                        (Split-Path $folder -Leaf), $recentFiles.Count) -Level "ALERT"
                } else {
                    Write-Log ("  {0}: 最近1小时内有 {1} 个文件被修改" -f
                        (Split-Path $folder -Leaf), $recentFiles.Count) -Level "OK"
                }

                # 检查可疑的加密文件扩展名
                $encryptedFiles = Get-ChildItem -Path $folder -Recurse -File -ErrorAction SilentlyContinue |
                    Where-Object { $_.Extension -in $suspiciousExtensions }

                if ($encryptedFiles.Count -gt 0) {
                    Write-Log ("  发现 {0} 个可疑加密文件！可能遭受勒索软件攻击！" -f
                        $encryptedFiles.Count) -Level "ALERT"
                }
            }
        }
    }
    catch {
        Write-Log ("  无法检查文件活动: {0}" -f $_.Exception.Message) -Level "WARNING"
    }
}

# ============================================================
# 主程序
# ============================================================

function Start-SecurityScan {
    <# 执行完整的安全扫描 #>

    Clear-Host
    Write-Host ""
    Write-Host "  ╔══════════════════════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "  ║          个人电脑网络安全监测系统 v1.0              ║" -ForegroundColor Green
    Write-Host "  ╚══════════════════════════════════════════════════════╝" -ForegroundColor Green
    Write-Host ""
    Write-Host "  扫描时间: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Gray
    Write-Host "  计算机名: $env:COMPUTERNAME" -ForegroundColor Gray
    Write-Host "  用户名:   $env:USERNAME" -ForegroundColor Gray
    Write-Host "  日志文件: $LogFile" -ForegroundColor Gray
    Write-Host ""

    # 记录到日志
    Add-Content -Path $LogFile -Value "`n`n$('=' * 60)" -Encoding UTF8
    Add-Content -Path $LogFile -Value "扫描开始: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -Encoding UTF8
    Add-Content -Path $LogFile -Value "计算机: $env:COMPUTERNAME | 用户: $env:USERNAME" -Encoding UTF8
    Add-Content -Path $LogFile -Value $('=' * 60) -Encoding UTF8

    $startTime = Get-Date

    # 执行各项检查
    Check-FirewallStatus
    Check-AntivirusStatus
    Check-NetworkConnections
    Check-OpenPorts
    Check-SuspiciousProcesses
    Check-StartupItems
    Check-DNSConfig
    Check-SharedResources
    Check-WindowsUpdate
    Check-RecentFileChanges

    # 扫描摘要
    $endTime = Get-Date
    $duration = ($endTime - $startTime).TotalSeconds

    Write-Section "扫描完成"
    Write-Log ("  扫描耗时: {0:F1} 秒" -f $duration) -Level "INFO"
    Write-Log ("  日志已保存至: {0}" -f $LogFile) -Level "INFO"
    Write-Host ""
    Write-Host "  提示: 如发现 [!!警报] 项，请参考《个人电脑网络安全识别与防范指南.md》进行处理" -ForegroundColor Yellow
    Write-Host ""
}

# 执行扫描
Start-SecurityScan
