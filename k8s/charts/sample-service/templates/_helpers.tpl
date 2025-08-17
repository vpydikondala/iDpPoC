{{- define "sample-service.name" -}}{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}{{- end -}}
{{- define "sample-service.fullname" -}}{{- printf "%s-%s" (include "sample-service.name" .) .Release.Name | trunc 63 | trimSuffix "-" -}}{{- end -}}
{{- define "sample-service.labels" -}}
app.kubernetes.io/name: {{ include "sample-service.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: Helm
{{- end -}}
{{- define "sample-service.selectorLabels" -}}
app.kubernetes.io/name: {{ include "sample-service.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}
