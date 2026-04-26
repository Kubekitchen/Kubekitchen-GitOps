{{/*
Expand the name of the chart
*/}}
{{- define "order-service.name" -}}
{{- "order-service" }}
{{- end }}

{{/*
Full name with release
*/}}
{{- define "order-service.fullname" -}}
{{- printf "%s-%s" .Release.Name "order-service" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "order-service.labels" -}}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version }}
app.kubernetes.io/name: order-service
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/component: order
app.kubernetes.io/part-of: kubekitchen
project: {{ .Values.global.project }}
environment: {{ .Values.global.environment }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "order-service.selectorLabels" -}}
app: order-service
{{- end }}

{{/*
Image tag - use service specific or fall back to global
*/}}
{{- define "order-service.imageTag" -}}
{{- if .Values.image.tag -}}
{{- .Values.image.tag -}}
{{- else -}}
{{- .Values.global.imageTag -}}
{{- end -}}
{{- end }}

{{/*
Image pull policy - use service specific or fall back to global
*/}}
{{- define "order-service.imagePullPolicy" -}}
{{- if .Values.image.pullPolicy -}}
{{- .Values.image.pullPolicy -}}
{{- else -}}
{{- .Values.global.imagePullPolicy -}}
{{- end -}}
{{- end }}

{{/*
Secret checksum helper
*/}}
{{- define "order-service.secretChecksum" -}}
{{- printf "%s-%s-%s" .Values.global.jwtSecret .Values.global.jwtExpiresIn .Values.global.nodeEnv | sha256sum }}
{{- end }}