{{/* Define the chart name */}}
{{- define "epic-crm.name" -}}
epicrm
{{- end }}

{{/* Define the chart full name (with release name) */}}
{{- define "epic-crm.fullname" -}}
{{ .Release.Name }}-epicrm
{{- end }}

{{/* Define the chart label */}}
{{- define "epic-crm.chart" -}}
{{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
{{- end }}
