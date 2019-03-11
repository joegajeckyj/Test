
$server = $env:computername
$SMTPServer = $server
$EmailAddress = "joe.gajeckyj@centurylink.com","Mani.Baidwan@CenturyLink.com"

Function Get-Tickets() {
$SearchString = @()
$SearchString = "SM2", "ICSS", "SHSE", "GAPP", "DMZS", "ENSE", "CIPL", "DASE", "SAPP", "MCSG", "sulzer"
$Status = "All"
$ErrorActionPreference = 0
$Count = 0
<#
$credential = Get-Credential -Message "Enter Zendesk login"

$user = $credential.GetNetworkCredential().username
$pass = $credential.GetNetworkCredential().password
#>

$User = "{{ username }}"
$pass = "{{ password }}"

$pair = "$($user):$($pass)"

$encodedCreds = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($pair))

$basicAuthValue = "Basic $encodedCreds"

$Headers = @{
    Authorization = $basicAuthValue
}

$Tickets = @()
$aForm = @()
$Results = @()

$Session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = $null
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

Foreach ($Search in $SearchString) {
    $RequestURL = 'https://t3n.zendesk.com/api/v2/search.json?query=' + $Search + ' status<closed&sort_by=date'

    while ($RequestURL) {
        $Content = Invoke-WebRequest -Uri $RequestURL -Headers $Headers -Method GET -ContentType application/json -WebSession $Session -Verbose 
        $Search = $Content | ConvertFrom-Json
        $Result = $Search.results
        $TicketID = $Result.id
    
        if ($search.next_page) {
            #write $search.next_page
            $RequestURL = $search.next_page
        }
        else {
            $RequestURL = $Null
        }
        If (!($TicketID -eq $null)) {
            $Tickets += $TicketID
            $Results += $Result
        }
    }
}
$Tickets = $Tickets | select -Unique
#$Count = $Tickets.Count
#Write "Ticket Count: $Count"

$GLOBAL:Results = $Results | select -Unique *

Foreach ($Result in $GLOBAL:Results) {
    <#
    $Ticket = 1324385
    $RequestURL = "https://t3n.zendesk.com/api/v2/tickets/$Ticket.json?include=comment_count"
    $Content = Invoke-WebRequest -Uri $RequestURL -Headers $Headers -Method GET -ContentType application/json 
    $Ticket = $Content | ConvertFrom-Json
    #>
    $Type = $Null
    $Description = $Null
    $Summary = $Null
    #$TicketId
    $TicketId = $Result.id
    $Requestor = $null
    <#Audits
    $RequestURL = "https://t3n.zendesk.com/api/v2/tickets/$TicketId/audits.json"
    $Content = Invoke-WebRequest -Uri $RequestURL -Headers $Headers -Method GET -ContentType application/json 
    $Ticket = $Content | ConvertFrom-Json
    $Ticket.audits.via[0].source.from.original_recipients
    If ($Ticket.audits.via.source.from.original_recipients -imatch "chat.transcript@boldchat.com") {$VIA = "Chat"}
    #>
    $AccountAlias = $Result.fields | where {$_.id -eq 20321291} | select -expandproperty value
    $ServiceType = $Result.fields | where {$_.id -eq 21619801} | select -expandproperty value
    $Product = $Result.fields | where {$_.id -eq 24305619} | select -expandproperty value
    
    If ($AccountAlias -in $SearchString) {
        $Count++
        If ($ServiceType) { 
            If ($ServiceType -eq "problem") {
                $Type = "problem"
            }
            Else {
                [string]$ServiceType = $ServiceType.split("_")
                <#
                [array]$ServiceType = $ServiceType.split("_")
                $MaxServiceType = ($ServiceType.count | measure -Maximum).Maximum
                If ($MaxServiceType -gt 1) {
                    $Num = [int]$MaxServiceType - 1
                    [string]$ServiceType = $ServiceType[$Num]
                }
                #>
            }
        }
        If ($Product) {
            [array]$Product = $Product.split("_")
            $MaxProductType = ($Product.count | measure -Maximum).Maximum
            If ($MaxProductType -gt 1) {
                $Num = [int]$MaxProductType - 1
                [string]$Product = $Product[$Num]
            }
        }

        $RequestURL = "https://t3n.zendesk.com/api/v2/tickets/$TicketId/comments.json"
        $Content = Invoke-WebRequest -Uri $RequestURL -Headers $Headers -Method GET -ContentType application/json -WebSession $Session 

        $Comments = $Content | ConvertFrom-Json
    
        Foreach ($Comment in $Comments) {
            $CommentContent = $Comment.comments.plain_body
            [String]$Servers = ([regex]::matches($CommentContent, "\w*AU1.\w+|\w*DE1.\w+|\w*DE3.\w+|\w*IL1.\w+|\w*SG1.\w+|\w*GB3.\w+|\w*WA1.\w+") | %{$_.value} | select -Unique) -join ", "
            If (!($Servers)){
                $Servers = "-"
            }
            If ($Comment.comments.Public -eq "True") {
                #[String]$Description 
                If (!($Type -eq "problem")) {
                    If ($CommentContent -match "request|add\s|increase") {
                        $Type = "request"
                    }
                }
            }
            If ($CommentContent -match "Ticket Summary") {
                $Summary = $CommentContent | select-string 'Ticket Summary' -SimpleMatch
                [string]$Summary = $Summary.Trim()
            } 
            else {
                $Summary = "-"
            }
        }

        [string]$Tags = $Result.tags
        $Requestor = $Result.via.source.from.name
        If (!($Requestor)){
            $Requestor = $Result.submitter_id
            Switch($Requestor){
	            {$Requestor -eq "2238991986"}{  
		            $Requestor = "Mani Baidwan"
	            }
	            {$Requestor -eq "1142359835"}{  
 	   	            $Requestor = "Ben Heisel"
	            }
                {$Requestor -eq "1071256243"}{  
 	   	            $Requestor = "Pankaj Darekar"
	            }
                {$Requestor -eq "1181682735"}{  
 	   	            $Requestor = "Nishant Potdar"
	            }
                {$Requestor -eq "1519165039"}{  
 	   	            $Requestor = "Mikko Koskinen"
	            }
                {$Requestor -eq "1153468945"}{  
 	   	            $Requestor = "Subhash Mani"
	            }
		        {$Requestor -eq "613740270"}{  
 	   	            $Requestor = "Joe Gajeckyj"
	            }
		        {$Requestor -eq "366900062852"}{  
 	   	            $Requestor = "Nikhil Duraphe"
	            }
		        {$Requestor -eq "365228266211"}{  
 	   	            $Requestor = "Teemu Vinnikka"
	            }
		        {$Requestor -eq "376390407351"}{  
 	   	            $Requestor = "John Teepe"
	            }
	            Default {$Requestor = $Requestor}
            }
        }

        switch ($Tags) {
            {$Tags -imatch 'merge'}{
                $Type = "Merged Ticket"
                $MergedTicket = [regex]::matches($CommentContent, "#\w+" ) | %{$_.value} | select -Unique | ? {$_ -notmatch "#$Ticketid"}
                $Summary = "This ticket was merged in to ticket $MergedTicket"
                }
            {$Tags -imatch 'Customreq'}{
                $Type = "Custom Request"
                }
            Default{
                If (!($Type)) {$Type = $Result.type}
            }
        }

        If ($Tags -imatch "chat") {
            $VIA = "chat"
        }
        else {
            $VIA = $Result.via.channel
        }
    
        $oArray = @()

        $TicketID = $Result.Id

        $Hyperlink = "<a href='https://t3n.zendesk.com/agent/tickets/$TicketID'>$TicketID</a>"
        #$Hyperlink ="https://t3n.zendesk.com/agent/tickets/$TicketID"

        $oArray = New-Object System.Object
        $oArray | Add-Member -MemberType NoteProperty -Name 'Status' -Value $Result.status
        $oArray | Add-Member -MemberType NoteProperty -Name 'Ticket #' -Value $Hyperlink
        $oArray | Add-Member -MemberType NoteProperty -Name Date -Value $Result.created_at
        $oArray | Add-Member -MemberType NoteProperty -Name User -Value $Requestor
        $oArray | Add-Member -MemberType NoteProperty -Name Media -Value $VIA
        $oArray | Add-Member -MemberType NoteProperty -Name Type -Value $Type
        $oArray | Add-Member -MemberType NoteProperty -Name 'Service Type' -Value $ServiceType
        $oArray | Add-Member -MemberType NoteProperty -Name 'Account Alias' -Value $AccountAlias
        $oArray | Add-Member -MemberType NoteProperty -Name 'Impacted Product' -Value $Product
        #$oArray | Add-Member -MemberType NoteProperty -Name Priority -Value $Result.priority
        $oArray | Add-Member -MemberType NoteProperty -Name 'Impacted device' -Value $Servers
        $oArray | Add-Member -MemberType NoteProperty -Name Description -Value $Result.Subject
        $oArray | Add-Member -MemberType NoteProperty -Name Summary -Value $Summary
        #$oArray | Add-Member -MemberType NoteProperty -Name Tags -Value $Tags
 
        #$RequestURL = "https://t3n.zendesk.com/api/v2/tickets/$TicketId/metrics.json"
        #$Content = Invoke-WebRequest -Uri $RequestURL -Headers $Headers -Method GET -ContentType application/json  -WebSession $Session

        #$Metrics = $Content | ConvertFrom-Json

        $aForm += $oArray
    }
}
#Write "Ticket Count: $Count"
#$aForm | sort date | Export-Csv ".\Open-Tickets.csv" -NoType -Force
$aForm

}

# Set up HTML header
$Header = $Header = "<style>"
#$Header = $Header + "BODY{background-color:green;}"
$Header = $Header + "TABLE{border-width: 1px;border-style: solid;border-color: black;border-collapse: collapse;}"
$Header = $Header + "TH{border-width: 1px;padding: 4px;border-style: solid;border-color: black;background-color:green;}"
$Header = $Header + "TD{border-width: 1px;padding: 4px;border-style: solid;border-color: black;}"
$Header = $Header + "</style>"

$GetTickets = Get-Tickets 
$Body = $GetTickets | sort Date -Descending | ConvertTo-HTML -Head $Header| out-string

Add-Type -AssemblyName System.Web
$Body = [System.Web.HttpUtility]::HtmlDecode($Body)
 
$EmailParams = @{
To = $EmailAddress
From = "joegajeckyj@hotmail.com"    
Subject = "Sulzer Zendesk Report from $server"
SMTPServer = $SMTPServer
BodyAsHtml = $True
#Attachments = "C:\XFER\DomainGroups.csv", "C:\XFER\DomainUsers.csv"
}

$EmailParams.Body = $Body
Send-MailMessage @EmailParams

