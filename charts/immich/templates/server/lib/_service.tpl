{{/*
Renders the Service objects required by the chart.
*/}}
{{- define "server.service" -}}
  {{- /* Generate named services as required */ -}}
  {{- range $name, $service := .Values.server.service }}
    {{- if $service.enabled -}}
      {{- $serviceValues := $service -}}

      {{/* set the default nameOverride to the service name */}}
      {{- if and (not $serviceValues.nameOverride) (ne $name (include "server.service.primary" $)) -}}
        {{- $_ := set $serviceValues "nameOverride" $name -}}
      {{ end -}}

      {{- $_ := set $ "ObjectValues" (dict "service" $serviceValues) -}}
      {{- include "server.classes.service" $ }}
    {{- end }}
  {{- end }}
{{- end }}

{{/*
Return the primary service object
*/}}
{{- define "server.service.primary" -}}
  {{- $enabledServices := dict -}}
  {{- range $name, $service := .Values.server.service -}}
    {{- if $service.enabled -}}
      {{- $_ := set $enabledServices $name . -}}
    {{- end -}}
  {{- end -}}

  {{- $result := "" -}}
  {{- range $name, $service := $enabledServices -}}
    {{- if and (hasKey $service "primary") $service.primary -}}
      {{- $result = $name -}}
    {{- end -}}
  {{- end -}}

  {{- if not $result -}}
    {{- $result = keys $enabledServices | first -}}
  {{- end -}}
  {{- $result -}}
{{- end -}}

{{/*
Return the primary port for a given Service object.
*/}}
{{- define "server.classes.service.ports.primary" -}}
  {{- $enabledPorts := dict -}}
  {{- range $name, $port := .values.ports -}}
    {{- if $port.enabled -}}
      {{- $_ := set $enabledPorts $name . -}}
    {{- end -}}
  {{- end -}}

  {{- if eq 0 (len $enabledPorts) }}
    {{- fail (printf "No ports are enabled for service \"%s\"!" .serviceName) }}
  {{- end }}

  {{- $result := "" -}}
  {{- range $name, $port := $enabledPorts -}}
    {{- if and (hasKey $port "primary") $port.primary -}}
      {{- $result = $name -}}
    {{- end -}}
  {{- end -}}

  {{- if not $result -}}
    {{- $result = keys $enabledPorts | first -}}
  {{- end -}}
  {{- $result -}}
{{- end -}}


{{/*
This saves the name of the service in a global variable
*/}}
{{- define "server.servicename" -}}
{{- $values := .Values.server.service -}}
{{- if hasKey . "ObjectValues" -}}
  {{- with .ObjectValues.service -}}
    {{- $values = . -}}
  {{- end -}}
{{ end -}}

{{- $serviceName := include "server.names.fullname" . -}}
{{- if and (hasKey $values "nameOverride") $values.nameOverride -}}
  {{- $serviceName = printf "%v-%v" $serviceName $values.nameOverride -}}
{{ end -}}
{{ $serviceName }}
{{- end -}}

{{/*
This template serves as a blueprint for all Service objects that are created
within the server.
*/}}
{{- define "server.classes.service" -}}
{{- $values := .Values.server.service -}}
{{- if hasKey . "ObjectValues" -}}
  {{- with .ObjectValues.service -}}
    {{- $values = . -}}
  {{- end -}}
{{ end -}}

{{- $serviceName := include "server.names.fullname" . -}}
{{- if and (hasKey $values "nameOverride") $values.nameOverride -}}
  {{- $serviceName = printf "%v-%v" $serviceName $values.nameOverride -}}
{{ end -}}
{{- $svcType := $values.type | default "" -}}
{{- $primaryPort := get $values.ports (include "server.classes.service.ports.primary" (dict "values" $values)) }}
---
apiVersion: v1
kind: Service
metadata:
  name: immich-server
  {{- with (merge ($values.labels | default dict) (include "server.labels" $ | fromYaml)) }}
  labels: {{- toYaml . | nindent 4 }}
  {{- end }}
  annotations:
  {{- if eq ( $primaryPort.protocol | default "" ) "HTTPS" }}
    traefik.ingress.kubernetes.io/service.serversscheme: https
  {{- end }}
  {{- with (merge ($values.annotations | default dict) (include "server.annotations" $ | fromYaml)) }}
    {{ toYaml . | nindent 4 }}
  {{- end }}
spec:
  {{- if (or (eq $svcType "ClusterIP") (empty $svcType)) }}
  type: ClusterIP
  {{- if $values.clusterIP }}
  clusterIP: {{ $values.clusterIP }}
  {{end}}
  {{- else if eq $svcType "LoadBalancer" }}
  type: {{ $svcType }}
  {{- if $values.loadBalancerIP }}
  loadBalancerIP: {{ $values.loadBalancerIP }}
  {{- end }}
  {{- if $values.loadBalancerSourceRanges }}
  loadBalancerSourceRanges:
    {{ toYaml $values.loadBalancerSourceRanges | nindent 4 }}
  {{- end -}}
  {{- else }}
  type: {{ $svcType }}
  {{- end }}
  {{- if $values.externalTrafficPolicy }}
  externalTrafficPolicy: {{ $values.externalTrafficPolicy }}
  {{- end }}
  {{- if $values.sessionAffinity }}
  sessionAffinity: {{ $values.sessionAffinity }}
  {{- if $values.sessionAffinityConfig }}
  sessionAffinityConfig:
    {{ toYaml $values.sessionAffinityConfig | nindent 4 }}
  {{- end -}}
  {{- end }}
  {{- with $values.externalIPs }}
  externalIPs:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- if $values.publishNotReadyAddresses }}
  publishNotReadyAddresses: {{ $values.publishNotReadyAddresses }}
  {{- end }}
  {{- if $values.ipFamilyPolicy }}
  ipFamilyPolicy: {{ $values.ipFamilyPolicy }}
  {{- end }}
  {{- with $values.ipFamilies }}
  ipFamilies:
    {{ toYaml . | nindent 4 }}
  {{- end }}
  ports:
  {{- range $name, $port := $values.ports }}
  {{- if $port.enabled }}
  - port: {{ $port.port }}
    targetPort: {{ $port.targetPort | default $name }}
    {{- if $port.protocol }}
    {{- if or ( eq $port.protocol "HTTP" ) ( eq $port.protocol "HTTPS" ) ( eq $port.protocol "TCP" ) }}
    protocol: TCP
    {{- else }}
    protocol: {{ $port.protocol }}
    {{- end }}
    {{- else }}
    protocol: TCP
    {{- end }}
    name: {{ $name }}
    {{- if (and (eq $svcType "NodePort") (not (empty $port.nodePort))) }}
    nodePort: {{ $port.nodePort }}
    {{ end }}
  {{- end }}
  {{- end }}
  selector:
    {{- include "server.labels.selectorLabels" . | nindent 4 }}
{{- end }}
