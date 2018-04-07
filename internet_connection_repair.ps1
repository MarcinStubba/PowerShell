##################################################################################################################
######### The script checks the internet connection, when it finds a problem, it tries to solve it.###############
##################################################################################################################
################################# Author: Marcin Stubba ##########################################################
##################################################################################################################

function Internet_connection_repair
{
    function check_DNS
    {
        Clear-DnsClientCache
            try
            {
            Resolve-DnsName -Name microsoft.com -ErrorAction Stop > $null
             }
            catch 
            {
             set_DNS 

            }
    
    
    }
    function set_DNS
    {
        $control_varriable = 0
        if($control_varriable -eq 0)
        {
            $control_varriable = 1
            $default_gateway = (Get-NetRoute | Where-Object {$_.DestinationPrefix -like '0.0.0.0/0'}).NextHop
            $default_interface_id = (Get-NetRoute | Where-Object {$_.DestinationPrefix -like '0.0.0.0/0'}).ifIndex
            Set-DnsClientServerAddress -InterfaceIndex $default_interface_id -ServerAddresses "$default_gateway"
        }
        if($control_varriable -eq 1)
        {
            try
            {
            Resolve-DnsName -Name microsoft.com -ErrorAction Stop > $null
             }
            catch 
            {
               $default_interface_id = (Get-NetRoute | Where-Object {$_.DestinationPrefix -like '0.0.0.0/0'}).ifIndex 
               Set-DnsClientServerAddress -InterfaceIndex $default_interface_id -ServerAddresses "1.1.1.1", "1.0.0.1"
            }
        }

    }
    function restart_net_interface
    {
    $test_connection = (Test-NetConnection -CommonTCPPort HTTP -ComputerName MICROSOFT.COM).TcpTestSucceeded
        
        
        if ($test_connection -like '*False*')
        {
        $count_interface = (Get-NetAdapter).count
        $list_interface = (Get-NetAdapter).Name
        
            for($i=0;$i -lt $count_interface;$i++)
            {
                if($list_interface[$i] -like '*Loopback*')
                {
                }
                else
                {
                Disable-NetAdapter -Name $list_interface[$i] -AsJob
                Start-Sleep -Seconds 5
                Enable-NetAdapter -Name $list_interface[$i]

                }
            }
        
        }

    }
    function Clear_Teredo
    {
        Reset-Net6to4Configuration
        Reset-NetTeredoConfiguration
    }
    Clear_Teredo
    restart_net_interface
    check_DNS

}

Internet_connection_repair

