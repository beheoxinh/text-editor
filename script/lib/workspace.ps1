
function ParseTextEditorWorkspace {
    $metadata = cargo metadata --no-deps --offline | ConvertFrom-Json
    $env:TEXTEDITOR_WORKSPACE = $metadata.workspace_root
    $env:GRAM_WORKSPACE = $metadata.workspace_root # legacy alias
    $env:RELEASE_VERSION = $metadata.packages | Where-Object { $_.name -eq "gram" } | Select-Object -ExpandProperty version
}
