param(
    [Parameter(Mandatory=$true)]
    [Alias('ip')]
    [string]$HostName,

    [Parameter(Mandatory=$false)]
    [int]$port = 443,

    [Parameter(Mandatory=$false)]
    [string]$range
)

if ($range){
    $ports = $range -split '-'
    $start = [int]$ports[0]
    $end = [int]$ports[1]
    
    Write-Host "Started Scanning ..."
    Write-Output "Port`t State"

    $jobs = @()
    for($i=$start; $i -le $end; $i++){
        $jobs += Start-Job -ScriptBlock {
        param($port,$HostName)
            $results = Test-NetConnection -ComputerName $HostName -Port $port -WarningAction SilentlyContinue -ErrorAction SilentlyContinue

            if ($results){
            
                if($results.TcpTestSucceeded){
                    Write-Host "$port `t Open"
                }
                else{
                    Write-Host "$port `t closed"
                }
            }
        } -ArgumentList $i, $HostName
    }

    # Wait for jobs to complete and display results
    $jobs | ForEach-Object {
        $result = Receive-Job -Job $_ -Wait
        #Write-Host $result
        Remove-Job $_  # Clean up the job
    }

    <#for($i=$start; $i -le $end; $i++){
        $results = Test-NetConnection -ComputerName $HostName -Port $i -WarningAction SilentlyContinue -ErrorAction SilentlyContinue

        if ($results){
            
            if($results.TcpTestSucceeded){
                Write-Host "$i `t Open"
            }
            else{
                Write-Host "$i `t closed"
            }
        }
    }#>
}
else{
    Write-Host "Started Scanning ..."
    $results = Test-NetConnection -ComputerName $HostName -Port $port

    if ($results){
        Write-Output "Port`t State"
        if($results.TcpTestSucceeded){
            Write-Host "$port `t Open"
        }
        else{
            Write-Host "$port `t closed"
        }
    }
    else{
        Write-Host "There is nothing"
    }
}