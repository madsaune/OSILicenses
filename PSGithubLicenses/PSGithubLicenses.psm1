<#
.SYNOPSIS
Get license information from Github License API.
.DESCRIPTION
Get a list of available licenses or full information for a specific license.
.PARAMETER Key
Name of license in SPDX format. E.g 'GNU General Public License v3.0' is 'gpl-3.0' in SPDX format.
Will get information for specific license.
.PARAMETER ListAvailable
Will list all available licenses.
.EXAMPLE
PS /> Get-GithubLicense

key          name                                    url
---          ----                                    ---
agpl-3.0     GNU Affero General Public License v3.0  https://api.github.com/licenses/a…
apache-2.0   Apache License 2.0                      https://api.github.com/licenses/a…
bsd-2-clause BSD 2-Clause "Simplified" License       https://api.github.com/licenses/b…
bsd-3-clause BSD 3-Clause "New" or "Revised" License https://api.github.com/licenses/b…
bsl-1.0      Boost Software License 1.0              https://api.github.com/licenses/b…
cc0-1.0      Creative Commons Zero v1.0 Universal    https://api.github.com/licenses/c…
epl-2.0      Eclipse Public License 2.0              https://api.github.com/licenses/e…
gpl-2.0      GNU General Public License v2.0         https://api.github.com/licenses/g…
gpl-3.0      GNU General Public License v3.0         https://api.github.com/licenses/g…
lgpl-2.1     GNU Lesser General Public License v2.1  https://api.github.com/licenses/l…
mit          MIT License                             https://api.github.com/licenses/m…
mpl-2.0      Mozilla Public License 2.0              https://api.github.com/licenses/m…
unlicense    The Unlicense                           https://api.github.com/licenses/u…

.EXAMPLE
PS /> Get-GithubLicense -Key mit

key            : mit
name           : MIT License
spdx_id        : MIT
url            : https://api.github.com/licenses/mit
node_id        : MDc6TGljZW5zZTEz
html_url       : http://choosealicense.com/licenses/mit/
description    : A short and simple permissive license with conditions only requiring 
                 preservation of copyright and license notices. Licensed works, 
                 modifications, and larger works may be distributed under different 
                 terms and without source code.
implementation : Create a text file (typically named LICENSE or LICENSE.txt) in the 
                 root of your source code and copy the text of the license into the file.
                 Replace [year] with the current year and [fullname] with the name (or
                 names) of the copyright holders.
permissions    : {commercial-use, modifications, distribution, private-use}
conditions     : {include-copyright}
limitations    : {liability, warranty}
body           : MIT License

                 Copyright (c) [year] [fullname]

                 Permission is hereby granted, free of charge, to any person obtaining a copy
                 of this software and associated documentation files (the "Software"), to deal
                 in the Software without restriction, including without limitation the rights
                 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
                 copies of the Software, and to permit persons to whom the Software is
                 furnished to do so, subject to the following conditions:

                 The above copyright notice and this permission notice shall be included in all
                 copies or substantial portions of the Software.

                 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
                 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
                 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
                 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
                 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
                 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
                 SOFTWARE.

featured       : True

#>
Function Get-GithubLicense {
    [CmdletBinding(DefaultParameterSetName="All")]
    param (
        [Parameter(
            ParameterSetName="Single",
            Mandatory=$true,
            Position=0
        )]
        [String[]]
        $Key,

        [Parameter(ParameterSetName="All")]
        [Switch]
        $ListAvailable
    )

    begin {
        $API_URL = "https://api.github.com/licenses"
    }

    process {
        if ($PSCmdlet.ParameterSetName -eq "Single") {
            foreach ($License in $Key) {
                
                try {
                    Invoke-RestMethod -Uri ("{0}/{1}" -f ($API_URL, $License))
                } catch {
                    throw "API Endpoint not available."
                }

            }
        }

        if ($PSCmdlet.ParameterSetName -eq "All") {
            try {
                $Licenses = Invoke-RestMethod -Uri $API_URL
                $Licenses | Select-Object key, name, url
            } catch {
                throw "API Endpoint not available."
            }
        }
    }
}

<#
.SYNOPSIS
Downloads specified license from Github License API.
.DESCRIPTION
Downloads license (specified by $Key in SPDX format) from Github License API.
It will try to replace name, year, project, if specified, where necessary.
.PARAMETER Key
Name of license in SPDX format. E.g 'GNU General Public License v3.0' is 'gpl-3.0' in SPDX format.
You can run Get-GithubLicense to get a list of available licenses.
.PARAMETER Path
Where to save the license file. Defaults to './LICENSE'
.PARAMETER Author
Name of the author for whom the project is licensed to.
Defaults to 'git config --get user.name'.
The function will try to replace author where applicable.
.PARAMETER Year
Copyright year.
Defaults to current local year.
The function will try to replace year where applicable.
.PARAMETER Company
Copyright company.
The function will try to replace company where applicable.
.PARAMETER Project
Copyright project.
The function will try to replace project where applicable.
.PARAMETER Base
If specified, the function will download license as-is and not try to replace anything.
.EXAMPLE
PS /> Install-GithubLicense -Key mit
PS /> Get-ChildItem

    Directory: /

Mode                 LastWriteTime         Length Name
----                 -------------         ------ ----
-----          10/30/2020    22:36           1079 LICENSE

.EXAMPLE
PS /> Install-GithubLicense -Key gpl-3.0 -Path ./COPYING
PS /> Get-ChildItem


    Directory: /

Mode                 LastWriteTime         Length Name
----                 -------------         ------ ----
-----          10/30/2020    22:37          35147 COPYING

.EXAMPLE
PS /> Install-GithubLicense -Key mit -Author "John Doe"
PS /> Get-Content ./LICENSE
MIT License

Copyright (c) 2020-present John Doe

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

.EXAMPLE
PS /> Install-GithubLicense -Key mit -Base
PS /> Get-Content ./LICENSE
MIT License

Copyright (c) [year] [fullname]

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

#>
Function Install-GithubLicense {
    [CmdletBinding(DefaultParameterSetName="Replace")]
    param (
        [Parameter(
            Mandatory=$true,
            Position=0
        )]
        [ValidateNotNullOrEmpty()]
        [String]
        $Key,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [String]
        $Path = "./LICENSE",

        [Parameter(ParameterSetName="Replace")]
        [String]
        $Author = $(git config --get user.name),

        [Parameter(ParameterSetName="Replace")]
        [String]
        $Year = "{0}-present" -f ((Get-Date -Format 'yyyy')),

        [Parameter(ParameterSetName="Replace")]
        [String]
        $Company,

        [Parameter(ParameterSetName="Replace")]
        [String]
        $Project,

        [Parameter(ParameterSetName="Base")]
        [Switch]
        $Base
    )

    begin {
        $API_URL = "https://api.github.com/licenses/"

        if ([String]::IsNullOrEmpty($Author)) {
            $Author = $env:USER
        }

        Write-Verbose "Name: $($Key)"
        Write-Verbose "Author: $($Author)"
        Write-Verbose "Year: $($Year)"
        Write-Verbose "Company: $($Company)"
    }

    process {
        $Name = $Key.ToLower()
        $LicenseText = ""
        
        try {
            Write-Verbose "Downloading license `"$($Name)`""
            $Response = Invoke-RestMethod -Uri "$($API_URL)$Name"
            $LicenseText = $Response.body
        } catch {
            throw "Could not retrieve license."
        }

        if (-not ($Base)) {
            if ($Name -in @(
                "agpl-3.0",
                "gpl-2.0",
                "gpl-3.0",
                "lgpl-2.1"
            )) {
                $LicenseText = $LicenseText -Replace '<year>', $Year
                $LicenseText = $LicenseText -Replace '<name of author>', $Author
                $LicenseText = $LicenseText -Replace '<program>', $Project
            }
    
            if ($Name -in @("apache-2.0")) {
                $LicenseText = $LicenseText -Replace '\[yyyy\]', $Year
                $LicenseText = $LicenseText -Replace '\[name of copyright owner\]', $Author
            }
    
            if ($Name -in @(
                "mit",
                "bsd-2-clause",
                "bsd-3-clause-clear",
                "bsd-3-clause"
            )) {
                $LicenseText = $LicenseText -Replace '\[year\]', $Year
                $LicenseText = $LicenseText -Replace '\[fullname\]', $Author
            }

        }

        $LicenseText | Out-File -FilePath $Path -Encoding utf8
        Write-Verbose "License `"$($Name)`" saved in $($Path)"
    }
}
