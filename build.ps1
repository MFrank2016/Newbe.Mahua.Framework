Framework "4.6"
Properties {
    $autoVersion = $false
}

Task Default -depends CI 

Task CI -depends NugetPack -Description  "持续集成" {

}
Task Nuget -Description  "Nuget还原" {
    Exec {
        .nuget/nuget.exe restore "Newbe.Mahua.sln"
    }
}
Task Build -depends Nuget -Description  "编译解决方案" {
    Exec {
        msbuild "Newbe.Mahua.sln" /p:Configuration=Release 
    }
}
Task NugetPack -depends Build -Description  "生成Nuget包" {
    [string]$version = [System.IO.File]::ReadAllText((Get-ChildItem nuget.version))
    $versionNext = $null
    if ($autoVersion) {
        $v = New-Object System.Version($version)
        $versionNext = New-Object System.Version($v.Major, $v.Minor, $v.Build , ($v.Revision + 1))
        [System.IO.File]::WriteAllText("nuget.version", $versionNext)
    }else{
        $versionNext = New-Object System.Version($version)
    }
    Exec {
        Get-ChildItem Nuspecs *.nuspec -File | ForEach-Object {
            .nuget/nuget.exe pack $_.FullName -Version $versionNext -OutputDirectory npks
        }
    }
}