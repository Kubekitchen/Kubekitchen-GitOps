{{/*
Expand the name of the chart
*/}}
{{- define "menu-service.name" -}}
{{- "menu-service" }}
{{- end }}

{{/*
Full name with release
*/}}
{{- define "menu-service.fullname" -}}
{{- printf "%s-%s" .Release.Name "menu-service" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "menu-service.labels" -}}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version }}
app.kubernetes.io/name: menu-service
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/component: menu
app.kubernetes.io/part-of: kubekitchen
project: {{ .Values.global.project }}
environment: {{ .Values.global.environment }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "menu-service.selectorLabels" -}}
app: menu-service
app.kubernetes.io/name: menu-service
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Image tag - use service specific or fall back to global
*/}}
{{- define "menu-service.imageTag" -}}
{{- if .Values.image.tag -}}
{{- .Values.image.tag -}}
{{- else -}}
{{- .Values.global.imageTag -}}
{{- end -}}
{{- end }}

{{/*
Image pull policy - use service specific or fall back to global
*/}}
{{- define "menu-service.imagePullPolicy" -}}
{{- if .Values.image.pullPolicy -}}
{{- .Values.image.pullPolicy -}}
{{- else -}}
{{- .Values.global.imagePullPolicy -}}
{{- end -}}
{{- end }}

{{/*
Secret checksum helper
*/}}
{{- define "menu-service.secretChecksum" -}}
{{- printf "%s-%s-%s" .Values.global.jwtSecret .Values.global.jwtExpiresIn .Values.global.nodeEnv | sha256sum }}
{{- end }}