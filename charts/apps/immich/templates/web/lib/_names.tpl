{{/* Expand the name of the chart */}}
{{- define "web.names.name" -}}
  {{- $globalNameOverride := "" -}}
  {{- if hasKey .Values "global" -}}
    {{- $globalNameOverride = (default $globalNameOverride .Values.global.nameOverride) -}}
  {{- end -}}
  {{- default .Chart.Name (default .Values.nameOverride $globalNameOverride) | trunc 50 | trimSuffix "-" -}}-web
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "web.names.fullname" -}}
  {{- $name := include "web.names.name" . -}}
  {{- $globalFullNameOverride := "" -}}
  {{- if hasKey .Values "global" -}}
    {{- $globalFullNameOverride = (default $globalFullNameOverride .Values.global.fullnameOverride) -}}
  {{- end -}}
  {{- if or .Values.fullnameOverride $globalFullNameOverride -}}
    {{- $name = default .Values.fullnameOverride $globalFullNameOverride -}}
  {{- else -}}
    {{- if contains $name .Release.Name -}}
      {{- $name = .Release.Name -}}
    {{- else -}}
      {{- $name = printf "%s-%s" .Release.Name $name -}}
    {{- end -}}
  {{- end -}}
  {{- trunc 50 $name | trimSuffix "-" -}}
{{- end -}}


{{/* Create chart name and version as used by the chart label */}}
{{- define "web.names.chart" -}}
  {{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 50 | trimSuffix "-" -}}
{{- end -}}

{{/* Create the name of the ServiceAccount to use */}}
{{- define "web.names.serviceAccountName" -}}
  {{- if .Values.serviceAccount.create -}}
    {{- default (include "web.names.fullname" .) .Values.serviceAccount.name -}}
  {{- else -}}
    {{- default "default" .Values.serviceAccount.name -}}
  {{- end -}}
{{- end -}}

{{/* Return the properly cased version of the controller type */}}
{{- define "web.names.controllerType" -}}
  {{- if eq .Values.controller.type "deployment" -}}
    {{- print "Deployment" -}}
  {{- else if eq .Values.controller.type "daemonset" -}}
    {{- print "DaemonSet" -}}
  {{- else if eq .Values.controller.type "statefulset"  -}}
    {{- print "StatefulSet" -}}
  {{- else -}}
    {{- fail (printf "Not a valid controller.type (%s)" .Values.controller.type) -}}
  {{- end -}}
{{- end -}}

{{/* web labels shared across objects */}}
{{- define "web.labels" -}}
helm.sh/chart: {{ include "web.names.chart" . }}
{{ include "web.labels.selectorLabels" . }}
  {{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
  {{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
  {{- with .Values.global.labels }}
    {{- range $k, $v := . }}
      {{- $name := $k }}
      {{- $value := tpl $v $ }}
{{ $name }}: {{ quote $value }}
    {{- end }}
  {{- end }}
{{- end -}}

{{/* Selector labels shared across objects */}}
{{- define "web.labels.selectorLabels" -}}
app.kubernetes.io/name: {{ include "web.names.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}


{{/* Common annotations shared across objects */}}
{{- define "web.annotations" -}}
  {{- with .Values.global.annotations }}
    {{- range $k, $v := . }}
      {{- $name := $k }}
      {{- $value := tpl $v $ }}
{{ $name }}: {{ quote $value }}
    {{- end }}
  {{- end }}
{{- end -}}

{{/* Determine the Pod annotations used in the controller */}}
{{- define "web.podAnnotations" -}}
  {{- if .Values.podAnnotations -}}
    {{- tpl (toYaml .Values.podAnnotations) . | nindent 0 -}}
  {{- end -}}

  {{- $configMapsFound := false -}}
  {{- range $name, $configmap := .Values.configmap -}}
    {{- if $configmap.enabled -}}
      {{- $configMapsFound = true -}}
    {{- end -}}
  {{- end -}}
  {{- if $configMapsFound -}}
    {{- printf "checksum/config: %v" (include ("web.configmap") . | sha256sum) | nindent 0 -}}
  {{- end -}}
{{- end -}}