param(
    [Parameter(Mandatory=$true)]
    [int]$old_percentage,

    [Parameter(Mandatory=$true)]
    [int]$new_percentage
)

$ErrorActionPreference = "Stop"

$patch1 = @"
[
  {"op": "add", "path": "/spec/http/1/route/0/weight", "value": ${old_percentage}},
  {"op": "add", "path": "/spec/http/1/route/1/weight", "value": ${new_percentage}}
]
"@
kubectl patch virtualservice product --type=json -p=$patch1

$patch2 = @"
[
  {"op": "add", "path": "/spec/http/1/route/0/weight", "value": ${old_percentage}},
  {"op": "add", "path": "/spec/http/1/route/1/weight", "value": ${new_percentage}}
]
"@
kubectl patch virtualservice recommendation --type=json -p=$patch2

$patch3 = @"
[
  {"op": "add", "path": "/spec/http/1/route/0/weight", "value": ${old_percentage}},
  {"op": "add", "path": "/spec/http/1/route/1/weight", "value": ${new_percentage}}
]
"@
kubectl patch virtualservice review --type=json -p=$patch3
