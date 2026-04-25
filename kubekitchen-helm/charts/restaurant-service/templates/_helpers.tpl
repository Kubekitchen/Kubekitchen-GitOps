{{/*
Expand the name of the chart
*/}}
{{- define "restaurant-service.name" -}}
{{- "restaurant-service" }}
{{- end }}

{{/*
Full name with release
*/}}
{{- define "restaurant-service.fullname" -}}
{{- printf "%s-%s" .Release.Name "restaurant-service" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "restaurant-service.labels" -}}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version }}
app.kubernetes.io/name: restaurant-service
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/component: restaurant
app.kubernetes.io/part-of: kubekitchen
project: {{ .Values.global.project }}
environment: {{ .Values.global.environment }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "restaurant-service.selectorLabels" -}}
app: restaurant-service
app.kubernetes.io/name: restaurant-service
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Image tag - use service specific or fall back to global
*/}}
{{- define "restaurant-service.imageTag" -}}
{{- if .Values.image.tag -}}
{{- .Values.image.tag -}}
{{- else -}}
{{- .Values.global.imageTag -}}
{{- end -}}
{{- end }}

{{/*
Image pull policy - use service specific or fall back to global
*/}}
{{- define "restaurant-service.imagePullPolicy" -}}
{{- if .Values.image.pullPolicy -}}
{{- .Values.image.pullPolicy -}}
{{- else -}}
{{- .Values.global.imagePullPolicy -}}
{{- end -}}
{{- end }}

{{/*
Secret checksum helper
*/}}
{{- define "restaurant-service.secretChecksum" -}}
{{- printf "%s-%s-%s" .Values.global.jwtSecret .Values.global.jwtExpiresIn .Values.global.nodeEnv | sha256sum }}
{{- end }}