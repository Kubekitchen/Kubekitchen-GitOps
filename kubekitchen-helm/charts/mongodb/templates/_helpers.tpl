{{/*
Common labels for mongodb
*/}}
{{- define "mongodb.labels" -}}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version }}
app.kubernetes.io/name: mongodb
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/component: database
app.kubernetes.io/part-of: kubekitchen
project: {{ .Values.global.project }}
environment: {{ .Values.global.environment }}
tier: database
{{- end }}

{{/*
Generate mongodb StatefulSet for a given database.

IMPORTANT: When called from statefulset.yaml inside the mongodb sub-chart,
the .Values scope is already the mongodb sub-chart values.
So we access .Values.image, .Values.resources, .Values.securityContext, etc.
(NOT .Values.mongodb.image — that would be double-nested and would fail)

Usage: {{ include "mongodb.statefulset" (dict "name" "auth" "database" "authdb" "Values" .Values "Release" .Release "Chart" .Chart) }}
*/}}
{{- define "mongodb.statefulset" -}}
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: mongodb-{{ .name }}
  namespace: {{ .Values.global.namespace }}
  labels:
    app: mongodb-{{ .name }}
    tier: database
    project: {{ .Values.global.project }}
    environment: {{ .Values.global.environment }}
    app.kubernetes.io/component: database
    app.kubernetes.io/part-of: kubekitchen
  annotations:
    argocd.argoproj.io/sync-wave: "1"
spec:
  serviceName: mongodb-{{ .name }}-headless
  replicas: 1
  selector:
    matchLabels:
      app: mongodb-{{ .name }}
  template:
    metadata:
      labels:
        app: mongodb-{{ .name }}
        tier: database
        project: {{ .Values.global.project }}
        environment: {{ .Values.global.environment }}
    spec:
      serviceAccountName: {{ .Values.global.serviceAccountName }}
      securityContext:
        runAsNonRoot: true
        runAsUser: {{ .Values.securityContext.runAsUser }}
        runAsGroup: {{ .Values.securityContext.runAsGroup }}
        fsGroup: {{ .Values.securityContext.fsGroup }}
      terminationGracePeriodSeconds: 30
      containers:
        - name: mongodb
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
          imagePullPolicy: {{ .Values.image.pullPolicy }}
          ports:
            - containerPort: 27017
              name: mongodb
          env:
            - name: MONGO_INITDB_DATABASE
              value: {{ .database }}
          resources:
            {{- toYaml .Values.resources | nindent 12 }}
          volumeMounts:
            - name: data
              mountPath: /data/db
          livenessProbe:
            exec:
              command:
                - mongosh
                - --eval
                - "db.adminCommand('ping')"
            initialDelaySeconds: {{ .Values.probes.liveness.initialDelaySeconds }}
            periodSeconds: {{ .Values.probes.liveness.periodSeconds }}
            timeoutSeconds: {{ .Values.probes.liveness.timeoutSeconds }}
            failureThreshold: 3
          readinessProbe:
            exec:
              command:
                - mongosh
                - --eval
                - "db.adminCommand('ping')"
            initialDelaySeconds: {{ .Values.probes.readiness.initialDelaySeconds }}
            periodSeconds: {{ .Values.probes.readiness.periodSeconds }}
            timeoutSeconds: {{ .Values.probes.readiness.timeoutSeconds }}
            failureThreshold: 3
      volumes:
        - name: data
          persistentVolumeClaim:
            claimName: mongodb-{{ .name }}-pvc
{{- end }}

{{/*
Generate headless service for mongodb
*/}}
{{- define "mongodb.headlessService" -}}
apiVersion: v1
kind: Service
metadata:
  name: mongodb-{{ .name }}-headless
  namespace: {{ .Values.global.namespace }}
  labels:
    app: mongodb-{{ .name }}
    tier: database
    app.kubernetes.io/part-of: kubekitchen
spec:
  clusterIP: None
  selector:
    app: mongodb-{{ .name }}
  ports:
    - port: 27017
      targetPort: 27017
      name: mongodb
{{- end }}

{{/*
Generate PVC for mongodb
*/}}
{{- define "mongodb.pvc" -}}
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mongodb-{{ .name }}-pvc
  namespace: {{ .Values.global.namespace }}
  labels:
    app: mongodb-{{ .name }}
    tier: database
    environment: {{ .Values.global.environment }}
  annotations:
    argocd.argoproj.io/sync-wave: "0"
spec:
  storageClassName: {{ .Values.global.storageClass }}
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: {{ .Values.storage.size }}
{{- end }}