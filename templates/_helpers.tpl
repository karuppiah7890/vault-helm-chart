{{/*
Expand the name of the chart.
*/}}
{{- define "vault.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "vault.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "vault.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "vault.labels" -}}
helm.sh/chart: {{ include "vault.chart" . }}
{{ include "vault.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- with .Values.commonLabels }}
{{ toYaml . }}
{{- end }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "vault.selectorLabels" -}}
app.kubernetes.io/name: {{ include "vault.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "vault.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "vault.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create the name of the cluster role binding to use for auth-delegator
*/}}
{{- define "vault.authDelegatorClusterRoleBindingName" -}}
{{- printf "%s-%s" (include "vault.fullname" .) "auth-delegator" | trunc 63 }}
{{- end }}

{{/*
Get the list of namespaces for distributing the generated CA certificate Secret to other namespaces.
*/}}
{{- define "vault.tlsCertDistributionNamespaces" -}}
{{- if and (hasKey .Values "tls") (hasKey .Values.tls "secretName") (ne .Values.tls.secretName "")}}
{{- list }}
{{- else if and (hasKey .Values "tls") (hasKey .Values.tls "caNamespaces") }}
{{- append .Values.tls.caNamespaces .Release.Namespace }}
{{- else }}
{{- list .Release.Namespace }}
{{- end }}
{{- end }}
