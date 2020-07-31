<#
.SYNOPSIS
    Functions for creating and using flash cards.
.DESCRIPTION
    Functions for creating and using flash cards.
.PARAMETER <Parameter_Name>
    N/A
.INPUTS
    None
.OUTPUTS
    None?
.NOTES
    VERSION 0.0.0
        Creation Date: 2020-07-28
        Author: John Trask
        Purpose/Change(s):
            Initial Script
.EXAMPLE
#>

[CmdletBinding()]
Param (
   
)


Function New-FlashCard {
    <#
    .SYNOPSIS
        Creates a new flash card.
    .DESCRIPTION
        Writes the "front" and "back" of the card to the specified .json file.
    .PARAMETER -FileName
        Name of the .json file
    .PARAMETER -Input
        Array listing the infomation for the front and back of the card.
    .INPUTS
        None
    .OUTPUTS
        Appends the information to the specified .json file.  The file will be created if it does not aleady exist.
    .NOTES
        VERSION 1.0.0
            Creation Date: 2020-07-28
            Author: John Trask
            Purpose/Change(s):
                Initial Script
    .EXAMPLE
        New-FlashCards -FileName .\Carnac.json -Input @('Astros','What is the worst tasting beer?')
    #>

    [CmdletBinding()]
    Param (
        [Parameter(
            Mandatory=$true, 
            ValueFromPipeLine=$true, 
            ValueFromPipelineByPropertyName=$True)
        ]
        [string]$Path,

        [Parameter(
            Mandatory = $False,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True)
        ]
        [switch]$Force,
        
        [Parameter(
            Mandatory = $True,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True)
        ]
        [string[]]$NewCard
    )

    Begin {
        Write-Verbose "Begin $($MyInvocation.MyCommand.Name)"

        If (Test-Path $Path) {
            Write-Verbose "The file [$Path] exists."
        } Else {
            $CreateFile = $Null
            If ($Force -eq $True) {
                $CreateFile = $True
            } Else {
                Do {
                    $Response = Read-Host -Prompt "The file $Path does not exist.  Create? <Y/N>"
                    If (($Response -eq 'Y') -or ($Response = 'Yes')) {
                        $CreateFile = $True
                    } Else {
                        If (($Response -eq 'N') -or (Response = 'No')) {
                            Throw "$Path does not exist!"
                        }
                    }
                } Until ($CreateFile -eq $True)    
            }

            If ($CreateFile -eq $True) {
                Try {
                    New-Item -Path $Path -ItemType File
                } Catch {
                    "Failed to create $Path"
                }    
            }
        }
    
        $Cards = @(Get-Content $Path | Out-String | ConvertFrom-Json)
    }


    Process {
        ForEach ($Card in $NewCard) {       
            $NewIndex = (($Cards.Index | Measure-Object -Maximum).Maximum) + 1

            $AddCard = New-Object PSObject
            $AddCard | Add-Member -MemberType NoteProperty -Name Index -Value $NewIndex
            $AddCard | Add-Member -MemberType NoteProperty -Name Front -Value $($Card.Split("|")[0])
            $AddCard | Add-Member -MemberType NoteProperty -Name Back -Value $($Card.Split("|")[1])
        
            $Cards = $Cards + $AddCard
        } 
    }
    End {
        #$Cards | (ConvertTo-Json).Replace('\\n','\n') | Set-Content $Path
        (ConvertTo-Json -InputObject $Cards ).Replace('\\n','\n') | Set-Content $Path
        Write-Verbose "End $($MyInvocation.MyCommand.Name)"
    }
}

Function Show-FlashCard {
    <#
    .SYNOPSIS
        Shows the flash cards.
    .DESCRIPTION
        Shows the flash cards stored in the specified .json file.
    .PARAMETER Path
        Path to the .json file storing the flash cards.
    .PARAMETER Repeat
        [int] Number of times to repeat the list of cards.  0 repeats indefinitely.
    .PARAMETER ShowSide
        Front|Back|Random [default: Random]
        Determines which side of the card is shown.
    .INPUTS
        None
    .OUTPUTS
        None
    .NOTES
        VERSION 1.0.0
            Creation Date: 2020-07-30
            Author: John Trask
            Purpose/Change(s):
                Initial Script
    .EXAMPLE
        Show-FlashCard -Path .\Carnac.json -Repeat 0 -ShowSide Random
    #>

    [CmdletBinding()]
    Param (
        [Parameter(
            Mandatory=$true, 
            ValueFromPipeLine=$true, 
            ValueFromPipelineByPropertyName=$True)
        ]
        [string]$Path,

        [Parameter(
            Mandatory=$False)
        ]
        [int]$Repeat = 0,

        [Parameter(
            Mandatory=$False)
        ]
        [ValidateSet(“Front”,”Back”,”Random”)]
        [string]$ShowSide = 'Random'
    )

    Begin {
        Write-Verbose "Begin $($MyInvocation.MyCommand.Name)"
        #$Cards = (Get-Content $Path | Out-String | ConvertFrom-Json).Replace('\\n','\n')
        $Cards = Get-Content $Path | Out-String | ConvertFrom-Json

        If ($ShowSide -eq 'Front') {
            $Show = 0
        } ElseIf ($ShowSide -eq 'Back') {
            $Show = 1
        } 

        $CardCounter = 1
        $RepeatCounter = 1
        $RepeatOK = $True

    }
    Process {
        Do {
            $Cards = $Cards | Sort-Object {Get-Random}
            ForEach ($Card in $Cards) {
                If ($ShowSide -eq 'Random') {
                    $Show = Get-Random @(0,1)
                }

                $Reveal = -bnot $Show

                If ($Show -eq 0) {
                    [System.Windows.MessageBox]::Show($Card.Front,"Card $CardCounter",'Ok','Question') | Out-Null
                    If ([System.Windows.MessageBox]::Show($Card.Back,"Card $CardCounter",'OKCancel','Information') -eq 'Cancel') {
                        Throw 'Thank you for playing.'    
                    } 
                } Else {
                    [System.Windows.MessageBox]::Show($Card.Back,"Card $CardCounter",'OK','Question') | Out-Null
                    If ([System.Windows.MessageBox]::Show($Card.Front,"Card $CardCounter",'OKCancel','Information') -eq 'Cancel') {
                        Throw 'Thank you for playing.'
                    }
                }
                $CardCounter++    
            }
            $RepeatCounter++

            If (($Repeat -ne 0) -and ($RepeatCounter -gt $Repeat)) {
                $RepeatOK = $False
            }
        } Until ($RepeatOK -eq $False)
    }
    End {
        Write-Verbose "End $($MyInvocation.MyCommand.Name)"
    }
}

