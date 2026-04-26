{{/*
Expand the name of the chart
*/}}
{{- define "frontend.name" -}}
{{- "frontend" }}
{{- end }}

{{/*
Full name with release
*/}}
{{- define "frontend.fullname" -}}
{{- printf "%s-%s" .Release.Name "frontend" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "frontend.labels" -}}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version }}
app.kubernetes.io/name: frontend
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/component: frontend
app.kubernetes.io/part-of: kubekitchen
project: {{ .Values.global.project }}
environment: {{ .Values.global.environment }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "frontend.selectorLabels" -}}
app: frontend
{{- end }}

{{/*
Image tag - use service specific or fall back to global
*/}}
{{- define "frontend.imageTag" -}}
{{- if .Values.image.tag -}}
{{- .Values.image.tag -}}
{{- else -}}
{{- .Values.global.imageTag -}}
{{- end -}}
{{- end }}

{{/*
Image pull policy - use service specific or fall back to global
*/}}
{{- define "frontend.imagePullPolicy" -}}
{{- if .Values.image.pullPolicy -}}
{{- .Values.image.pullPolicy -}}
{{- else -}}
{{- .Values.global.imagePullPolicy -}}
{{- end -}}
{{- end }}

{{/*
Config checksum - restarts frontend pods when API URLs change
*/}}
{{- define "frontend.configChecksum" -}}
{{- printf "%s-%s-%s-%s" .Values.global.serviceUrls.auth .Values.global.serviceUrls.menu .Values.global.serviceUrls.restaurant .Values.global.serviceUrls.order | sha256sum }}
{{- end }}