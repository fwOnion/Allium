[CmdletBinding()] param([Parameter(Mandatory)][string[]]$Path,[string]$Output='SHA256SUMS.txt')
$rows=foreach($p in $Path){$r=Resolve-Path -LiteralPath $p;$h=Get-FileHash -LiteralPath $r -Algorithm SHA256;'{0}  {1}'-f $h.Hash.ToLowerInvariant(),(Split-Path $r -Leaf)}
[IO.File]::WriteAllLines($Output,$rows,[Text.UTF8Encoding]::new($false))
