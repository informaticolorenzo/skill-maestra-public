param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('lint', 'diff', 'export-tailwind', 'export-dtcg', 'spec')]
    [string]$Action,

    [string]$File = 'DESIGN.md',
    [string]$SecondFile = '',
    [string]$OutputFile = ''
)

switch ($Action) {
    'lint' {
        npx @google/design.md lint $File
    }
    'diff' {
        if (-not $SecondFile) {
            throw 'SecondFile es obligatorio para diff.'
        }
        npx @google/design.md diff $File $SecondFile
    }
    'export-tailwind' {
        if (-not $OutputFile) {
            $OutputFile = 'tailwind.theme.json'
        }
        npx @google/design.md export --format tailwind $File | Out-File -FilePath $OutputFile -Encoding utf8
    }
    'export-dtcg' {
        if (-not $OutputFile) {
            $OutputFile = 'tokens.json'
        }
        npx @google/design.md export --format dtcg $File | Out-File -FilePath $OutputFile -Encoding utf8
    }
    'spec' {
        npx @google/design.md spec
    }
}
