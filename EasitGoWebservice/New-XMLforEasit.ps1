function New-XMLforEasit {
    [CmdletBinding()]
    param (
        [parameter(Mandatory=$false, Position=0, ParameterSetName="ping")]
        [switch] $Ping,

        [parameter(Mandatory=$false, Position=0, ParameterSetName="get")]
        [switch] $Get,

        [Parameter(Mandatory=$true, ParameterSetName="get")]
        [string] $ItemViewIdentifier,

        [Parameter(Mandatory=$false, ParameterSetName="get")]
        [int] $Page = 1,

        [Parameter(Mandatory=$true, ParameterSetName="get")]
        [string] $SortField,
        
        [Parameter(Mandatory=$true, ParameterSetName="get")]
        [string] $SortOrder,

        [Parameter(Mandatory=$true, ParameterSetName="get")]
        [string[]] $ColumnFilter,

        [parameter(Mandatory=$false, Position=0, ParameterSetName="import")]
        [switch] $Import,

        [Parameter(Mandatory=$true, ParameterSetName="import")]
        [hashtable] $Params
    )



    Write-Verbose "Defining xmlns:soapenv and xmlns:sch"
    $xmlnsSoapEnv = "http://schemas.xmlsoap.org/soap/envelope/"
    $xmlnsSch = "http://www.easit.com/bps/schemas"

    try {
        Write-Verbose "Creating xml object for payload"
        $payload = New-Object xml
        [System.Xml.XmlDeclaration] $xmlDeclaration = $payload.CreateXmlDeclaration("1.0", "UTF-8", $null)
        $payload.AppendChild($xmlDeclaration) | Out-Null
    } catch {
        Write-Error "Failed to create xml object for payload"
        Write-Error "$_"
        break
    }

    try {
        Write-Verbose "Creating xml element for Envelope"
        $soapEnvEnvelope = $payload.CreateElement("soapenv:Envelope","$xmlnsSoapEnv")
        $soapEnvEnvelope.SetAttribute("xmlns:sch","$xmlnsSch")
        $payload.AppendChild($soapEnvEnvelope) | Out-Null
    } catch {
        Write-Error "Failed to create xml element for Envelope"
        Write-Error "$_"
        break
    }

    try {
        Write-Verbose "Creating xml element for Header"
        $soapEnvHeader = $payload.CreateElement('soapenv:Header',"$xmlnsSoapEnv")
        $soapEnvEnvelope.AppendChild($soapEnvHeader) | Out-Null
    } catch {
        Write-Error "Failed to create xml element for Header"
        Write-Error "$_"
        break
    }

    try {
        Write-Verbose "Creating xml element for Body"
        $soapEnvBody = $payload.CreateElement("soapenv:Body","$xmlnsSoapEnv")
        $soapEnvEnvelope.AppendChild($soapEnvBody) | Out-Null
    } catch {
        Write-Error "Failed to create xml element for Body"
        Write-Error "$_"
        break
    }


    if ($import) {
        try {
            Write-Verbose "Creating xml element for ImportItemsRequest"
            $schImportItemsRequest = $payload.CreateElement("sch:ImportItemsRequest","$xmlnsSch")
            $soapEnvBody.AppendChild($schImportItemsRequest) | Out-Null
        } catch {
            Write-Error "Failed to create xml element for ImportItemsRequest"
            Write-Error "$_"
            break
        }
        try {
            Write-Verbose "Creating xml element for Importhandler"
            $envelopeImportHandlerIdentifier = $payload.CreateElement('sch:ImportHandlerIdentifier',"$xmlnsSch")
            $envelopeImportHandlerIdentifier.InnerText  = "$ImportHandlerIdentifier"
            $schImportItemsRequest.AppendChild($envelopeImportHandlerIdentifier) | Out-Null
        } catch {
            Write-Error "Failed to create xml element for Importhandler"
            Write-Error "$_"
            break
        }
    
        try {
            Write-Verbose "Creating xml element for ItemToImport"
            $schItemToImport = $payload.CreateElement("sch:ItemToImport","$xmlnsSch")
            $schItemToImport.SetAttribute("id","$uid")
            $schItemToImport.SetAttribute("uid","$uid")
            $schImportItemsRequest.AppendChild($schItemToImport) | Out-Null
        } catch {
            Write-Error "Failed to create xml element for ItemToImport"
            Write-Error "$_"
            break
        }
        try {
            Write-Verbose "Collecting list of used parameters"
            $CommandName = $PSCmdlet.MyInvocation.InvocationName
            $ParameterList = (Get-Command -Name $commandName).Parameters.Values
            Write-Verbose "Successfully collected list of used parameters"
        } catch {
            Write-Error 'Failed to get list of used parameters!'
            Write-Error "$_"
            break
        }
        Write-Verbose "Starting loop for creating xml element for each parameter"
        foreach ($parameter in $parameterList) {
            Write-Verbose "Starting loop for $($parameter.Name)"
            $ParameterSetToMatch = 'BPSAttribute'
            $parameterSets = $parameter.ParameterSets.Keys
            if ($parameterSets -contains $ParameterSetToMatch) {
                    Write-Verbose "$($parameter.Name) is part of BPS parameter set"
                    $parDetails = Get-Variable -Name $parameter.Name
                    if ($parDetails.Value) {
                        Write-Verbose "$($parameter.Name) have a value"
                        Write-Verbose "Creating xml element for $($parameter.Name) and will try to append it to payload!"
                        if ($parDetails.Name -ne "Attachment") {
                                try {
                                    $parName = $parDetails.Name
                                    $parValue = $parDetails.Value
                                    $envelopeItemProperty = $payload.CreateElement("sch:Property","$xmlnsSch")
                                    $envelopeItemProperty.SetAttribute('name',"$parName")
                                    $envelopeItemProperty.InnerText = $parValue
                                    $schItemToImport.AppendChild($envelopeItemProperty) | Out-Null
                                    Write-Verbose "Added property $parName to payload!"
                                } catch {
                                    Write-Error "Failed to add property $parName in SOAP envelope!"
                                    Write-Error "$_"
                                }
                        }
                        if ($parDetails.Name -eq "Attachment") {
                                try {
                                    $parName = $parDetails.Name
                                    $fileHeader = ""
                                    $separator = "\"
                                    $fileNametoHeader = $Attachment.Split($separator)
                                    $fileHeader = $fileNametoHeader[-1]
                                    $base64string = [Convert]::ToBase64String([System.IO.File]::ReadAllBytes("$Attachment"))
                                    $envelopeItemAttachment = $payload.CreateElement("sch:Attachment","$xmlnsSch")
                                    $envelopeItemAttachment.SetAttribute('name',"$fileHeader")
                                    $envelopeItemAttachment.InnerText = $base64string
                                    $schItemToImport.AppendChild($envelopeItemAttachment) | Out-Null
                                    Write-Verbose "Added property $parName to payload!"
                                } catch {
                                    Write-Error "Failed to add property $parName in SOAP envelope!"
                                    Write-Error "$_"
                                }
                        }
                    } else {
                        Write-Verbose "$($parameter.Name) does not have a value!"
                    }
            } else {
                    Write-Verbose "$($parameter.Name) is not part of BPS parameter set!"
            } Write-Verbose "Loop for $($parameter.Name) reached end!"
        }
    }

    if ($get) {
        try {
            Write-Verbose "Creating xml element for GetItemsRequest"
            $schGetItemsRequest = $payload.CreateElement("sch:GetItemsRequest","$xmlnsSch")
            $soapEnvBody.AppendChild($schGetItemsRequest) | Out-Null
        } catch {
            Write-Error "Failed to create xml element for GetItemsRequest"
            Write-Error "$_"
            break
        }

        try {
            Write-Verbose "Creating xml element for ItemViewIdentifier"
            $envelopeItemViewIdentifier = $payload.CreateElement('sch:ItemViewIdentifier',"$xmlnsSch")
            $envelopeItemViewIdentifier.InnerText  = "$ItemViewIdentifier"
            $schGetItemsRequest.AppendChild($envelopeItemViewIdentifier) | Out-Null
        } catch {
            Write-Error "Failed to create xml element for ItemViewIdentifier"
            Write-Error "$_"
            break
        }

        try {
            Write-Verbose "Creating xml element for Page"
            $envelopePage = $payload.CreateElement('sch:Page',"$xmlnsSch")
            $envelopePage.InnerText  = "$Page"
            $schGetItemsRequest.AppendChild($envelopePage) | Out-Null
        } catch {
            Write-Error "Failed to create xml element for Page"
            Write-Error "$_"
            break
        }

        try {
            Write-Verbose "Creating xml element for SortColumn order"
            $envelopeSortColumnOrder = $payload.CreateElement('sch:SortColumn',"$xmlnsSch")
            $envelopeSortColumnOrder.SetAttribute("order","$SortOrder")
            $envelopeSortColumnOrder.InnerText  = "$SortField"
            $schGetItemsRequest.AppendChild($envelopeSortColumnOrder) | Out-Null
        } catch {
            Write-Error "Failed to create xml element for Page"
            Write-Error "$_"
            break
        }

        try {
            $ColumnFilterValues = $ColumnFilter -split ','
            [int]$ColumnFilterValuesCount = $ColumnFilterValues.Count
            $i=0
            do {
                Write-Verbose "Creating xml element for Column filter"
                $envelopeColumnFilter = $payload.CreateElement('sch:ColumnFilter',"$xmlnsSch")
                $envelopeColumnFilter.SetAttribute("columnName","$uid")
                $envelopeColumnFilter.SetAttribute("comparator","$uid")
                $envelopeColumnFilter.InnerText  = "$ColumnFilter"
                $schGetItemsRequest.AppendChild($envelopeColumnFilter) | Out-Null
                $i+3
            } until ($i -le $ColumnFilterValuesCount)
        } catch {
            Write-Error "Failed to create xml element for Page"
            Write-Error "$_"
            break
        }
    }

    if ($ping) {
        try {
            Write-Verbose "Creating xml element for PingRequest"
            $envelopePingRequest = $payload.CreateElement('sch:PingRequest',"$xmlnsSch")
            $envelopePingRequest.InnerText  = '?'
            $soapEnvBody.AppendChild($envelopePingRequest) | Out-Null
      } catch {
            Write-Error "Failed to create xml element for PingRequest"
            Write-Error "$_"
            break
      }
    }
    
    Write-Verbose "Successfully updated property values in SOAP envelope for all parameters with input provided!"
}