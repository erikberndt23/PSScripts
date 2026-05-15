# S1-MonthlyFullScan.ps1
# -----------------------------------------------------------------------
# Triggers a full disk scan on specified SentinelOne groups,
# polls for completion, and sends an email report with per-agent detail
# organised by group.
#
# Groups can be specified by ID, by name, or a mix of both.
# API token is retrieved at runtime from Windows Credential Manager.
#
# Configuration: edit the CONFIG block below before deploying.
# Logs are written to C:\logs\S1\s1_scan.log
#
# -----------------------------------------------------------------------

# ------------Config begin-----------------------------------------------
$S1BaseUrl    = "https://[UniqueDomain]}.sentinelone.net"

# Windows Credential Manager target name (set by Save-S1Token.ps1)
$S1CredTarget = "S1-MonthlyFullScan"

# Groups to scan — specify by ID, by name, or a mix of both.
# IDs are used as-is. Names are resolved to IDs at runtime via the API.
$GroupIds     = @(
    #"123456789101112131415",  # Example group ID (uncomment and replace with real IDs as needed)
)
$GroupNames   = @(
    "Windows Servers",
    "Windows Domain Controllers"
)

# Email config
$EmailFrom    = "[your-email]@domain.com"
$EmailTo      = @("[email-address1]@domain.com", "[email-address2]@domain.com", "[email-address3]@domain.com")
$SmtpHost     = "smtp.domain.com"
$SmtpPort     = 25

# Polling
$PollIntervalSeconds = 60
$TimeoutSeconds      = 7200

# Logging
$LogFile = "C:\logs\S1\s1_scan.log"

# ------------Config end-----------------------------------------------

function Write-Log {
    param([string]$Level = "INFO", [string]$Message)
    $null = New-Item -ItemType Directory -Path (Split-Path $script:LogFile) -Force
    $line = "{0} [{1}] {2}" -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss"), $Level.ToUpper(), $Message
    Add-Content -Path $script:LogFile -Value $line
    switch ($Level.ToUpper()) {
        "ERROR" { Write-Host $line -ForegroundColor Red }
        "WARN"  { Write-Host $line -ForegroundColor Yellow }
        default { Write-Host $line }
    }
}

# Windows Credential Manager retrieval
Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;

public class CredentialManager {

    [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
    private struct CREDENTIAL {
        public uint     Flags;
        public uint     Type;
        public string   TargetName;
        public string   Comment;
        public FILETIME LastWritten;
        public uint     CredentialBlobSize;
        public IntPtr   CredentialBlob;
        public uint     Persist;
        public uint     AttributeCount;
        public IntPtr   Attributes;
        public string   TargetAlias;
        public string   UserName;
    }

    [StructLayout(LayoutKind.Sequential)]
    private struct FILETIME {
        public uint dwLowDateTime;
        public uint dwHighDateTime;
    }

    [DllImport("advapi32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
    private static extern bool CredRead(
        string target, uint type, uint reservedFlag, out IntPtr credentialPtr);

    [DllImport("advapi32.dll")]
    private static extern void CredFree(IntPtr buffer);

    public static string GetSecret(string target) {
        IntPtr ptr;
        if (!CredRead(target, 1, 0, out ptr))
            throw new Exception(
                "CredRead failed for target '" + target +
                "'. Error code: " + Marshal.GetLastWin32Error());
        try {
            var cred = Marshal.PtrToStructure<CREDENTIAL>(ptr);
            return Marshal.PtrToStringUni(
                cred.CredentialBlob,
                (int)(cred.CredentialBlobSize / 2)
            );
        }
        finally {
            CredFree(ptr);
        }
    }
}
'@ -Language CSharp

function Get-CredManagerSecret {
    param([string]$Target)
    try {
        return [CredentialManager]::GetSecret($Target)
    }
    catch {
        throw "Failed to retrieve credential '$Target' from Windows Credential Manager: $_"
    }
}


# S1 API helpers
function Invoke-S1Api {
    param(
        [string]$Method,
        [string]$Path,
        [hashtable]$Query = @{},
        [object]$Body = $null,
        [hashtable]$Headers
    )

    $baseUrl = $script:S1BaseUrl
    $uri     = $baseUrl + $Path
    if ($Query.Count -gt 0) {
        $qs  = ($Query.GetEnumerator() | ForEach-Object { "$($_.Key)=$([string]$_.Value)" }) -join "&"
        $uri = $uri + "?" + $qs
    }

    Write-Log "INFO" "Request URI: $uri"
    $params = @{ Uri = $uri; Method = $Method; Headers = $Headers; ErrorAction = "Stop" }
    if ($Body) { $params.Body = ($Body | ConvertTo-Json -Depth 10) }

    try {
        return Invoke-RestMethod @params
    }
    catch {
        $detail = $_.ErrorDetails.Message
        Write-Log "ERROR" "API call failed [$Method $Path]: $_  $detail"
        throw
    }
}

function Resolve-GroupNameToId {
    # Returns a hashtable with Keys=IDs, Values=Names for all resolved groups
    param([string[]]$Names, [hashtable]$Headers)
    $resolvedMap = @{}
    foreach ($name in $Names) {
        Write-Log "INFO" "Resolving group name: $name"
        $result = Invoke-S1Api -Method GET -Path "/web/api/v2.1/groups" `
            -Query @{ name = $name } -Headers $Headers
        if ($result.data -ne $null) {
            $dataList = New-Object System.Collections.ArrayList
            foreach ($item in $result.data) { [void]$dataList.Add($item) }
            if ($dataList.Count -gt 0) {
                $id = $dataList[0].id
                Write-Log "INFO" "  Resolved '$name' to ID: $id"
                $resolvedMap[$id] = $name
            } else {
                Write-Log "WARN" "  Could not resolve group name '$name' — skipping."
            }
        }
    }
    return $resolvedMap
}

function Get-GroupDisplayNames {
    param([string[]]$Ids, [hashtable]$Headers)
    $map = @{}
    if ($Ids.Count -eq 0) { return $map }
    $result = Invoke-S1Api -Method GET -Path "/web/api/v2.1/groups" `
        -Query @{ id = ($Ids -join ",") } -Headers $Headers
    if ($result.data -ne $null) {
        foreach ($group in $result.data) {
            $map[$group.id] = $group.name
        }
    }
    return $map
}

function Start-S1Scan {
    param([string[]]$Ids, [hashtable]$Headers)
    $body   = @{ filter = @{ groupIds = $Ids }; data = @{} }
    $result = Invoke-S1Api -Method POST `
        -Path "/web/api/v2.1/agents/actions/initiate-scan" `
        -Body $body -Headers $Headers
    return $result
}

function Get-S1AgentDetails {
    param([string[]]$Ids, [hashtable]$Headers)
    $result  = Invoke-S1Api -Method GET -Path "/web/api/v2.1/agents" `
        -Query @{ groupIds = ($Ids -join ","); limit = 1000 } -Headers $Headers
    $agents = New-Object System.Collections.ArrayList
    if ($result.data -ne $null) {
        # PS 5.1 deserialises a single JSON object as PSCustomObject not an array.
        # Round-trip through JSON forces consistent array handling regardless of result count.
        $json = $result.data | ConvertTo-Json -Depth 10
        if ($json -ne $null -and $json.TrimStart().StartsWith("{")) {
            $json = "[" + $json + "]"
        }
        $items = $json | ConvertFrom-Json
        foreach ($item in $items) { [void]$agents.Add($item) }
    }
    Write-Log "INFO" "Get-S1AgentDetails returned $($agents.Count) agent(s)."
    return $agents
}

function Get-ScanSummary {
    param($Agents)
    $finished = 0
    $running  = 0
    $other    = 0
    foreach ($agent in $Agents) {
        $status = if ($agent.scanStatus) { $agent.scanStatus.ToLower() } else { "none" }
        if ($status -eq "finished") {
            $finished++
        } elseif ($status -eq "started" -or $status -eq "running") {
            $running++
        } else {
            $other++
        }
    }
    # Derive Total from counts rather than $Agents.Count which is unreliable in PS 5.1
    $total = $finished + $running + $other
    return @{ Total = $total; Finished = $finished; Running = $running; Other = $other }
}


# Polling
function Wait-ForScanCompletion {
    param([string[]]$Ids, [hashtable]$Headers)

    $deadline = (Get-Date).AddSeconds($script:TimeoutSeconds)
    Write-Log "INFO" "Polling every $($script:PollIntervalSeconds)s (timeout: $($script:TimeoutSeconds / 60) min)..."

    while ((Get-Date) -lt $deadline) {
        $agents = Get-S1AgentDetails -Ids $Ids -Headers $Headers
        foreach ($agent in $agents) {
            Write-Log "INFO" "Agent: $($agent.computerName) | scanStatus: [$($agent.scanStatus)]"
        }
        $summary = Get-ScanSummary -Agents $agents
        Write-Log "INFO" ("  Status -> total: {0}, finished: {1}, running: {2}, other: {3}" `
            -f $summary.Total, $summary.Finished, $summary.Running, $summary.Other)

        if ($summary.Running -eq 0 -and ($summary.Finished + $summary.Other) -gt 0) {
            Write-Log "INFO" "All agents finished scanning."
            return $agents
        }
        Start-Sleep -Seconds $script:PollIntervalSeconds
    }

    Write-Log "WARN" "Timeout reached before all agents finished."
    return Get-S1AgentDetails -Ids $Ids -Headers $Headers
}


# Report builder
function Build-Report {
    param($GroupDisplayNames, $Affected, $Agents, $StartedAt, $FinishedAt)

    $summary     = Get-ScanSummary -Agents $Agents
    $duration    = $FinishedAt - $StartedAt
    $durationStr = "{0:D2}h {1:D2}m {2:D2}s" -f $duration.Hours, $duration.Minutes, $duration.Seconds

    $header  = "{0,-30} {1,-25} {2,-10} {3}" -f "Hostname", "OS", "Scan Status", "Online"
    $divider = "-" * 90

    $groupedSection = ""
    $agentsByGroup  = $Agents | Group-Object { if ($_.groupName) { $_.groupName } else { "Unknown Group" } }

    foreach ($group in $agentsByGroup | Sort-Object Name) {
        $groupedSection += "`n  Group: $($group.Name)`n"
        $groupedSection += "  $header`n"
        $groupedSection += "  $divider`n"

        foreach ($agent in $group.Group | Sort-Object computerName) {
            $hostname = if ($agent.computerName) { $agent.computerName } else { "unknown" }
            $os       = if ($agent.osName)       { $agent.osName }       else { "unknown" }
            $status   = if ($agent.scanStatus)   { $agent.scanStatus }   else { "none" }
            $online   = if ($agent.isActive -eq $true) { "Yes" } else { "No (offline)" }
            # Flag agents that show finished but are offline
            if ($status -eq "finished" -and $agent.isActive -ne $true) {
                $status = "finished*"
            }
            $groupedSection += "  $("{0,-30} {1,-25} {2,-10} {3}" -f $hostname, $os, $status, $online)`n"
        }
    }

    return @"
SentinelOne Monthly Full Disk Scan - Report
================================================
Run date  : $($StartedAt.ToString("yyyy-MM-dd HH:mm:ss")) UTC
Duration  : $durationStr
Groups    : $($GroupDisplayNames -join ", ")

Scan trigger:
  Agents affected : $Affected

Summary:
  Total     : $($summary.Total)
  Finished  : $($summary.Finished)
  Running   : $($summary.Running)
  Other     : $($summary.Other)

Agent detail by group:
$groupedSection
* finished = last known status only. Agent was offline during scan.
"@
}


# Email
function Send-Email {
    param([string]$Subject, [string]$Body)

    $msg              = New-Object Net.Mail.MailMessage
    $msg.From         = $script:EmailFrom
    $script:EmailTo   | ForEach-Object { $msg.To.Add($_) }
    $msg.Subject      = $Subject
    $msg.Body         = $Body

    $smtp                       = New-Object Net.Mail.SmtpClient($script:SmtpHost, $script:SmtpPort)
    $smtp.EnableSsl             = $false
    $smtp.UseDefaultCredentials = $false
    $smtp.Send($msg)
    Write-Log "INFO" "Email notification sent."
}

function Send-Notification {
    param([string]$Subject, [string]$Body)
    try {
        Send-Email -Subject $Subject -Body $Body
    }
    catch {
        Write-Log "ERROR" "Notification failed: $_"
    }
}


# Main
Write-Log "INFO" "=== SentinelOne Monthly Full Disk Scan starting ==="

# 1. Load API token
try {
    $apiToken = Get-CredManagerSecret -Target $script:S1CredTarget
    Write-Log "INFO" "API token retrieved from Windows Credential Manager."
}
catch {
    Write-Log "ERROR" "Could not retrieve API token: $_"
    exit 1
}

$headers = @{
    "Authorization" = "ApiToken " + $apiToken
    "Content-Type"  = "application/json"
}

# 2. Resolve group names to IDs — builds a map of id -> name in one pass
$groupIdToName = @{}
if ($script:GroupNames.Count -gt 0) {
    try {
        $resolved = Resolve-GroupNameToId -Names $script:GroupNames -Headers $headers
        foreach ($id in $resolved.Keys) { $groupIdToName[$id] = $resolved[$id] }
    }
    catch {
        Write-Log "WARN" "Group name resolution failed: $_"
    }
}

# Merge with directly specified IDs (use ID as display name if no name known)
$allGroupIds = New-Object System.Collections.ArrayList
foreach ($id in $script:GroupIds) {
    if (-not $allGroupIds.Contains($id)) {
        [void]$allGroupIds.Add($id)
        if (-not $groupIdToName.ContainsKey($id)) { $groupIdToName[$id] = $id }
    }
}
foreach ($id in $groupIdToName.Keys) {
    if (-not $allGroupIds.Contains($id)) { [void]$allGroupIds.Add($id) }
}

if ($allGroupIds.Count -eq 0) {
    Write-Log "ERROR" "No valid group IDs to scan. Aborting."
    exit 1
}

# 3. Build display names list from the map
$groupDisplayNames = New-Object System.Collections.ArrayList
foreach ($id in $allGroupIds) {
    [void]$groupDisplayNames.Add($groupIdToName[$id])
}

Write-Log "INFO" "Target groups: $($groupDisplayNames -join ', ')"
$startedAt = [datetime]::UtcNow

# 4. Trigger scan
try {
    $triggerResult = Start-S1Scan -Ids $allGroupIds -Headers $headers
    $affected      = if ($triggerResult.data.affected) { $triggerResult.data.affected } else { "unknown" }
    Write-Log "INFO" "Scan initiated. Agents affected: $affected"
}
catch {
    Write-Log "ERROR" "Failed to initiate scan. Aborting."
    exit 1
}

# 5. Poll until complete
$finalAgents = Wait-ForScanCompletion -Ids $allGroupIds -Headers $headers
$finishedAt  = [datetime]::UtcNow

# 6. Build and send report
# Get affected count from final agent list
$finalSummary = Get-ScanSummary -Agents $finalAgents
$affected     = $finalSummary.Finished + $finalSummary.Running + $finalSummary.Other
$report = Build-Report `
    -GroupDisplayNames $groupDisplayNames `
    -Affected $affected `
    -Agents $finalAgents `
    -StartedAt $startedAt `
    -FinishedAt $finishedAt

$subject = "[SentinelOne] Monthly Full Disk Scan Complete - " +
           "$($groupDisplayNames -join ', ') - " +
           "$(Get-Date -Format 'yyyy-MM-dd')"

Write-Log "INFO" "`n$report"
Send-Notification -Subject $subject -Body $report

Write-Log "INFO" "=== Done ==="