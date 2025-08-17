{{- define "{{name}}.fullname" -}}{{ include "{{name}}.name" . }}-{{ .Release.Name }}{{- end -}}
{{- define "{{name}}.name" -}}{{ .Chart.Name }}{{- end -}}
