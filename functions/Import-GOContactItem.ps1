function Import-GOContactItem {
      <#
      .SYNOPSIS
            Send data to BPS/GO with web services.
      .DESCRIPTION
            Update and create contacts in Easit BPS/GO. Returns ID for item in Easit BPS/GO.
            Specify 'ID' to update an existing contact.

      .NOTES
            Copyright 2019 Easit AB

            Licensed under the Apache License, Version 2.0 (the "License");
            you may not use this file except in compliance with the License.
            You may obtain a copy of the License at

                http://www.apache.org/licenses/LICENSE-2.0

            Unless required by applicable law or agreed to in writing, software
            distributed under the License is distributed on an "AS IS" BASIS,
            WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
            See the License for the specific language governing permissions and
            limitations under the License.

      .LINK
            https://github.com/easitab/EasitGoWebservice/blob/master/EasitGoWebservice/Import-GOContactItem.ps1

      .EXAMPLE
            Import-GOContactItem -url http://localhost/webservice/ -apikey a8d5eba7f4daa79ea6f1c17c6b453d17df9c27727610b142c70c51bb4eda3618 -ImportHandlerIdentifier CreateContact -OrganizationID "12" -Position "Manager" -Deparment "Support" -FirstName "Test" -Surname "Testsson" -Username "te12te" -SecId "97584621" -Verbose -ShowDetails
      .EXAMPLE
            Import-GOContactItem -url http://localhost/webservice/ -apikey a8d5eba7f4daa79ea6f1c17c6b453d17df9c27727610b142c70c51bb4eda3618 -ihi CreateContact -ID "649" -Inactive "true"
      .EXAMPLE
            Import-GOContactItem -url http://localhost/webservice/ -api a8d5eba7f4daa79ea6f1c17c6b453d17df9c27727610b142c70c51bb4eda3618 -ImportHandlerIdentifier CreateContact -ID "649" -Surname "Andersson" -Email "test.anders@company.com" -FQDN "$FQDN"
      .EXAMPLE
            Import-GOContactItem -url $url -apikey $api -ihi $identifier -ID "156" -Inactive "false" -Responsible_Manager "true"
      .PARAMETER url
            Address to BPS/GO webservice. Default = http://localhost/webservice/
      .PARAMETER apikey
            API-key for BPS/GO.
      .PARAMETER ImportHandlerIdentifier
            ImportHandler to import data with. Default = CreateContact
      .PARAMETER ID
            ID for contact in BPS/GO.
      .PARAMETER FirstName
            First name of contact in BPS/GO.
      .PARAMETER Surname
            Last name of contact in BPS/GO.
      .PARAMETER OrganizationID
            ID for organization to which the contact belongs to. Can be found on the organization in BPS/GO.
      .PARAMETER Category
            Contacts category.
      .PARAMETER Position
            Contacts position.
      .PARAMETER ManagerID
            ID of contact that should be used as Manager.
      .PARAMETER Impact
            Contacts impact level. 1. Minor, 2. Medium or 3. Major.
      .PARAMETER PreferredMethodForNotification
            Contacts preferred method for notification. Mail or Telephone.
      .PARAMETER Building
            Buildning that the contact is located in.
      .PARAMETER Checkbox_Authorized_Purchaser
            Can be set to true or false.
      .PARAMETER Checkbox_Responsible_Manager
            Can be set to true or false.
      .PARAMETER Deparment
            Department to which the contact belongs.
      .PARAMETER Email
            Contacts email.
      .PARAMETER ExternalId
            Contacts external id.
      .PARAMETER FQDN
            Contacts fully qualified domain name.
      .PARAMETER Inactive
            Used to set contact as inactive. Can be set to true or false.
      .PARAMETER MobilePhone
            Contacts mobilephone.
      .PARAMETER Note
            Notes regarding contact.
      .PARAMETER Phone
            Contacts phone.
      .PARAMETER Room
            Room in which contact is located.
      .PARAMETER SecId
            Contacts security id.
      .PARAMETER Title
            Contact title, eg CEO.
      .PARAMETER Username
            Contacts username.
      .PARAMETER Attachment
            Full path to file to be included in payload.
      .PARAMETER SSO
            Used if system is using SSO with IWA (Active Directory). Not need when using SAML2
      .PARAMETER ShowDetails
            If specified, the response, including ID, will be displayed to host.
      .PARAMETER dryRun
            If specified, payload will be save as payload.xml to your desktop instead of sent to BPS.
      #>
      [CmdletBinding()]
      param (
            [parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true)]
            [ValidateNotNullOrEmpty()]
            [Alias("uri")]
            [string] $url = "http://localhost/webservice/",

            [parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true)]
            [ValidateNotNullOrEmpty()]
            [Alias("api")]
            [string] $apikey,

            [parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true)]
            [ValidateNotNullOrEmpty()]
            [Alias("ihi")]
            [string] $ImportHandlerIdentifier = "CreateContact",

            [parameter(ParameterSetName='BPSAttribute',ValueFromPipelineByPropertyName=$true)]
            [string] $FirstName,

            [parameter(ParameterSetName='BPSAttribute',ValueFromPipelineByPropertyName=$true)]
            [string] $Surname,

            [parameter(ParameterSetName='BPSAttribute',ValueFromPipelineByPropertyName=$true)]
            [string] $Email,

            [parameter(ParameterSetName='BPSAttribute',ValueFromPipelineByPropertyName=$true)]
            [int] $ID,

            [parameter(ParameterSetName='BPSAttribute',ValueFromPipelineByPropertyName=$true)]
            [string] $SecId,

            [parameter(ParameterSetName='BPSAttribute',ValueFromPipelineByPropertyName=$true)]
            [string] $OrganizationID,

            [parameter(ParameterSetName='BPSAttribute',ValueFromPipelineByPropertyName=$true)]
            [string] $Category,

            [parameter(ParameterSetName='BPSAttribute',ValueFromPipelineByPropertyName=$true)]
            [string] $Position,

            [parameter(ParameterSetName='BPSAttribute',ValueFromPipelineByPropertyName=$true)]
            [string] $ManagerID,

            [parameter(ParameterSetName='BPSAttribute',ValueFromPipelineByPropertyName=$true)]
            [string] $Impact,

            [parameter(ParameterSetName='BPSAttribute',ValueFromPipelineByPropertyName=$true)]
            [string] $PreferredMethodForNotification,

            [parameter(ParameterSetName='BPSAttribute',ValueFromPipelineByPropertyName=$true)]
            [string] $Building,

            [parameter(ParameterSetName='BPSAttribute',ValueFromPipelineByPropertyName=$true)]
            [string] $Checkbox_Authorized_Purchaser,

            [parameter(ParameterSetName='BPSAttribute',ValueFromPipelineByPropertyName=$true)]
            [string] $Checkbox_Responsible_Manager,

            [parameter(ParameterSetName='BPSAttribute',ValueFromPipelineByPropertyName=$true)]
            [string] $Deparment,

            [parameter(ParameterSetName='BPSAttribute',ValueFromPipelineByPropertyName=$true)]
            [string] $ExternalId,

            [parameter(ParameterSetName='BPSAttribute',ValueFromPipelineByPropertyName=$true)]
            [string] $FQDN,

            [parameter(ParameterSetName='BPSAttribute',ValueFromPipelineByPropertyName=$true)]
            [string] $Inactive,

            [parameter(ParameterSetName='BPSAttribute',ValueFromPipelineByPropertyName=$true)]
            [string] $MobilePhone,

            [parameter(ParameterSetName='BPSAttribute',ValueFromPipelineByPropertyName=$true)]
            [string] $Note,

            [parameter(ParameterSetName='BPSAttribute',ValueFromPipelineByPropertyName=$true)]
            [string] $Phone,

            [parameter(ParameterSetName='BPSAttribute',ValueFromPipelineByPropertyName=$true)]
            [string] $Room,

            [parameter(ParameterSetName='BPSAttribute',ValueFromPipelineByPropertyName=$true)]
            [string] $Title,

            [parameter(ParameterSetName='BPSAttribute',ValueFromPipelineByPropertyName=$true)]
            [string] $Username,

            [parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true)]
            [int] $uid = "1",

            [parameter(ParameterSetName='BPSAttribute',ValueFromPipelineByPropertyName=$true)]
            [Alias("File")]
            [string] $Attachment,

            [parameter(Mandatory=$false)]
            [switch] $SSO,

            [parameter(Mandatory=$false)]
            [switch] $dryRun,

            [parameter(Mandatory=$false)]
            [switch] $ShowDetails
      )

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

      Write-Verbose "Starting loop for creating hashtable of parameter..."
      $params = [ordered]@{}
      foreach ($parameter in $parameterList) {
            Write-Verbose "Starting loop for $($parameter.Name)"
            $ParameterSetToMatch = 'BPSAttribute'
            $parameterSets = $parameter.ParameterSets.Keys
            if ($parameterSets -contains $ParameterSetToMatch) {
                  Write-Verbose "$($parameter.Name) is part of BPS parameter set"
                  $parDetails = Get-Variable -Name $parameter.Name
                  if ($parDetails.Value) {
                        Write-Verbose "$($parameter.Name) have a value"
                        $parName = $parDetails.Name
                        $parValue = $parDetails.Value
                        $params.Add("$parName", "$parValue")
                  } else {
                        Write-Verbose "$($parameter.Name) does not have a value!"
                  }
            } else {
                  Write-Verbose "$($parameter.Name) is not part of BPS parameter set!"
            } Write-Verbose "Loop for $($parameter.Name) reached end!"
      }
      Write-Verbose "Successfully created hashtable of parameter!"
      $payload = New-XMLforEasit -Import -ImportHandlerIdentifier "$ImportHandlerIdentifier" -Params $Params

      if ($dryRun) {
            Write-Verbose "dryRun specified! Trying to save payload to file instead of sending it to BPS"
            $i = 1
            $currentUserProfile = [Environment]::GetEnvironmentVariable("USERPROFILE")
            $userProfileDesktop = "$currentUserProfile\Desktop"
            do {
                  $outputFileName = "payload_$i.xml"
                  if (Test-Path $userProfileDesktop\$outputFileName) {
                        $i++
                        Write-Host "$i"
                  }
            } until (!(Test-Path $userProfileDesktop\$outputFileName))
            if (!(Test-Path $userProfileDesktop\$outputFileName)) {
                  try {
                        $outputFileName = "payload_$i.xml"
                        $payload.Save("$userProfileDesktop\$outputFileName")
                        Write-Verbose "Saved payload to file, will now end!"
                        break
                  } catch {
                        Write-Error "Unable to save payload to file!"
                        Write-Error "$_"
                        break
                  }
            }
      }

      Write-Verbose "Creating header for web request!"
      try {
            $pair = "$($apikey): "
            $encodedCreds = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($pair))
            $basicAuthValue = "Basic $encodedCreds"
            $headers = @{SOAPAction = ""; Authorization = $basicAuthValue}
            Write-Verbose "Header created for web request!"
      } catch {
            Write-Error "Failed to create header!"
            Write-Error "$_"
            break
      }
      Write-Verbose "Calling web service and using payload as input for Body parameter"
      if ($SSO) {
            try {
                  Write-Verbose 'Using switch SSO. De facto UseDefaultCredentials for Invoke-WebRequest'
                  $r = Invoke-WebRequest -Uri $url -Method POST -ContentType 'text/xml' -Body $payload -Headers $headers -UseDefaultCredentials
                  Write-Verbose "Successfully connected to and imported data to BPS"
            } catch {
                  Write-Error "Failed to connect to BPS!"
                  Write-Error "$_"
                  return $payload
            }
      } else {
            try {
                  $r = Invoke-WebRequest -Uri $url -Method POST -ContentType 'text/xml' -Body $payload -Headers $headers
                  Write-Verbose "Successfully connected to and imported data to BPS"
            } catch {
                  Write-Error "Failed to connect to BPS!"
                  Write-Error "$_"
                  return $payload
            }
      }
      
      New-Variable -Name functionout
      [xml]$functionout = $r.Content
      Write-Verbose 'Casted content of reponse as [xml]$functionout'

      if ($ShowDetails) {
            $responseResult = $functionout.Envelope.Body.ImportItemsResponse.ImportItemResult.result
            $responseID = $functionout.Envelope.Body.ImportItemsResponse.ImportItemResult.ReturnValues.ReturnValue.InnerXml
            Write-Host "Result: $responseResult"
            Write-Host "ID for created item: $responseID"
      }
      Write-Verbose "Function complete!"
}
