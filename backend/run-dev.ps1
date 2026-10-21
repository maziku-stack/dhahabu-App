$ErrorActionPreference = 'Stop'

# Local development only. DEBUG is set explicitly because inherited shell
# variables take precedence over values loaded from backend/.env.
$env:DEBUG = 'True'
$env:ALLOWED_HOSTS = '*'

$python = Join-Path $PSScriptRoot '.venv\Scripts\python.exe'
if (-not (Test-Path -LiteralPath $python)) {
    $python = 'python'
}

& $python (Join-Path $PSScriptRoot 'manage.py') runserver 0.0.0.0:8000
